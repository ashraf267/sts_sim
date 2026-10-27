import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/appliance_load.dart';
import '../models/meter_state.dart';
import '../models/sts_token.dart';
import '../models/vending_transaction.dart';
import '../services/sts_crypto_service.dart';
import '../services/tid_service.dart';

class SimulationProvider extends ChangeNotifier {
  late MeterState _meter;
  final List<ApplianceLoad> _appliances = [];
  final List<VendingTransaction> _vendingHistory = [];

  String _keypadInput = '';
  String _lcdDisplayMessage = '0.00 kWh';
  String _lastDebugLog = 'No cryptographic operations performed yet. Generate or enter a token to inspect the pipeline.';
  Timer? _loadTimer;
  Timer? _lcdResetTimer;

  SimulationProvider() {
    _initDefaults();
  }

  void _initDefaults() {
    _meter = MeterState(
      meterSerial: '01234567890',
      sgc: '100001',
      krn: 1,
      balanceKwh: 0.0,
      relayStatus: RelayStatus.disconnected,
    );

    _appliances.addAll([
      ApplianceLoad(id: 'bulb', name: 'LED Light Bulb', iconName: 'lightbulb', wattageWatts: 50.0),
      ApplianceLoad(id: 'fridge', name: 'Refrigerator', iconName: 'kitchen', wattageWatts: 250.0),
      ApplianceLoad(id: 'ac', name: 'Air Conditioner', iconName: 'ac_unit', wattageWatts: 1500.0),
      ApplianceLoad(id: 'heater', name: 'Water Heater', iconName: 'water_drop', wattageWatts: 2000.0),
    ]);
  }

  // Getters
  MeterState get meter => _meter;
  List<ApplianceLoad> get appliances => List.unmodifiable(_appliances);
  List<VendingTransaction> get vendingHistory => List.unmodifiable(_vendingHistory);
  String get keypadInput => _keypadInput;
  String get lcdDisplayMessage => _lcdDisplayMessage;
  String get lastDebugLog => _lastDebugLog;

  /// Total wattage draw in Watts from active appliances
  double get totalActiveWattage {
    if (_meter.relayStatus == RelayStatus.disconnected) return 0.0;
    return _appliances
        .where((a) => a.isActive)
        .fold(0.0, (sum, a) => sum + a.wattageWatts);
  }

  /// Total power draw in Kilowatts
  double get totalActiveKilowatts => totalActiveWattage / 1000.0;

  /// Estimated remaining time in minutes at current discharge rate
  double get estimatedMinutesRemaining {
    if (totalActiveKilowatts <= 0 || _meter.balanceKwh <= 0) return 0.0;
    return (_meter.balanceKwh / totalActiveKilowatts) * 60.0;
  }

  // Vending Actions
  VendingTransaction generateVendingToken({
    required double amountNaira,
    required double tariffNairaPerKwh,
  }) {
    final kwh = amountNaira / tariffNairaPerKwh;
    final tidMinutes = TidService.calculateTidMinutes();

    final digits = StsCryptoService.generateTokenDigits(
      masterKeyHex: _meter.masterKeyHex,
      sgc: _meter.sgc,
      meterSerial: _meter.meterSerial,
      tokenClassCode: TokenClass.credit.code,
      subClassCode: 0,
      tidMinutes: tidMinutes,
      amountKwh: kwh,
    );

    final stsToken = StsToken(
      rawDigits: digits,
      tokenClass: TokenClass.credit,
      subClass: 0,
      tidMinutes: tidMinutes,
      amountKwh: kwh,
      crc: 0,
    );

    final tx = VendingTransaction(
      id: 'TX-${DateTime.now().millisecondsSinceEpoch}',
      meterSerial: _meter.meterSerial,
      amountNaira: amountNaira,
      tariffNairaPerKwh: tariffNairaPerKwh,
      calculatedKwh: kwh,
      generatedToken: stsToken,
    );

    _vendingHistory.insert(0, tx);
    notifyListeners();
    return tx;
  }

  // Keypad Actions
  void keypadPressDigit(String digit) {
    if (_keypadInput.length < 20) {
      _keypadInput += digit;
      _lcdDisplayMessage = _formattedKeypadInput;
      notifyListeners();
    }
  }

  void keypadBackspace() {
    if (_keypadInput.isNotEmpty) {
      _keypadInput = _keypadInput.substring(0, _keypadInput.length - 1);
      _lcdDisplayMessage = _keypadInput.isEmpty ? _formattedBalanceMessage : _formattedKeypadInput;
      notifyListeners();
    }
  }

  void keypadClear() {
    _keypadInput = '';
    _lcdDisplayMessage = _formattedBalanceMessage;
    notifyListeners();
  }

  void autoKeyInAndSubmitToken(String rawDigits) {
    _keypadInput = rawDigits.replaceAll(RegExp(r'\D'), '');
    keypadSubmitToken();
  }

  void keypadSubmitToken() {
    if (_keypadInput.isEmpty) return;

    final result = StsCryptoService.validateToken(
      raw20Digits: _keypadInput,
      meter: _meter,
    );

    _lastDebugLog = result.debugLog;
    _keypadInput = '';

    if (result.isSuccess) {
      _meter.balanceKwh += result.creditedKwh;
      _meter.totalRechargedKwh += result.creditedKwh;
      if (result.token != null) {
        _meter.addAcceptedTid(result.token!.tidMinutes);
      }
      if (_meter.balanceKwh > 0) {
        _meter.relayStatus = RelayStatus.connected;
        _startLoadTickerIfNeeded();
      }
      _showLcdTemporaryMessage('${result.status.lcdCode} (+${result.creditedKwh.toStringAsFixed(1)} kWh)');
    } else {
      _showLcdTemporaryMessage('${result.status.lcdCode} (${result.status.description})');
    }

    notifyListeners();
  }

  // Appliance Load Control
  void toggleAppliance(String id) {
    final index = _appliances.indexWhere((a) => a.id == id);
    if (index != -1) {
      _appliances[index].isActive = !_appliances[index].isActive;
      _startLoadTickerIfNeeded();
      notifyListeners();
    }
  }

  void _startLoadTickerIfNeeded() {
    _loadTimer?.cancel();
    if (_meter.relayStatus == RelayStatus.connected && totalActiveKilowatts > 0) {
      _loadTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        // 1 second discharge: kW / 3600 = kWh consumed per second
        final kwhConsumed = totalActiveKilowatts / 3600.0;
        _meter.balanceKwh -= kwhConsumed;

        if (_meter.balanceKwh <= 0.0) {
          _meter.balanceKwh = 0.0;
          _meter.relayStatus = RelayStatus.disconnected;
          _loadTimer?.cancel();
          _showLcdTemporaryMessage('0.00 kWh (TRIPPED)');
        } else {
          if (_lcdResetTimer == null || !_lcdResetTimer!.isActive) {
            _lcdDisplayMessage = _formattedBalanceMessage;
          }
        }
        notifyListeners();
      });
    }
  }

  void _showLcdTemporaryMessage(String message) {
    _lcdResetTimer?.cancel();
    _lcdDisplayMessage = message;
    _lcdResetTimer = Timer(const Duration(seconds: 3), () {
      _lcdDisplayMessage = _formattedBalanceMessage;
      notifyListeners();
    });
  }

  String get _formattedBalanceMessage => '${_meter.balanceKwh.toStringAsFixed(2)} kWh';

  String get _formattedKeypadInput {
    final clean = _keypadInput;
    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(clean[i]);
    }
    return buffer.toString();
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    _lcdResetTimer?.cancel();
    super.dispose();
  }
}
