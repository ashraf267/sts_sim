import 'package:flutter_test/flutter_test.dart';
import 'package:sts_sim/models/meter_state.dart';
import 'package:sts_sim/services/sts_crypto_service.dart';
import 'package:sts_sim/services/tid_service.dart';

void main() {
  group('StsCryptoService Cryptographic Tests', () {
    late MeterState meter;

    setUp(() {
      meter = MeterState(
        meterSerial: '01234567890',
        sgc: '100001',
        masterKeyHex: '0123456789ABCDEF0123456789ABCDEF',
      );
    });

    test('Generates 20-digit token and validates successfully', () {
      final tid = TidService.calculateTidMinutes();
      final digits = StsCryptoService.generateTokenDigits(
        masterKeyHex: meter.masterKeyHex,
        sgc: meter.sgc,
        meterSerial: meter.meterSerial,
        tokenClassCode: 0,
        subClassCode: 0,
        tidMinutes: tid,
        amountKwh: 50.0,
      );

      expect(digits.length, equals(20));

      final result = StsCryptoService.validateToken(
        raw20Digits: digits,
        meter: meter,
      );

      expect(result.status, equals(ValidationStatus.success));
      expect(result.creditedKwh, equals(50.0));
      expect(result.token?.tidMinutes, equals(tid));
    });

    test('Re-using the same token fails with TID_REUSED (Replay Attack)', () {
      final tid = TidService.calculateTidMinutes();
      final digits = StsCryptoService.generateTokenDigits(
        masterKeyHex: meter.masterKeyHex,
        sgc: meter.sgc,
        meterSerial: meter.meterSerial,
        tokenClassCode: 0,
        subClassCode: 0,
        tidMinutes: tid,
        amountKwh: 100.0,
      );

      // First validation succeeds
      final res1 = StsCryptoService.validateToken(raw20Digits: digits, meter: meter);
      expect(res1.status, equals(ValidationStatus.success));

      // Mark TID as accepted in meter
      meter.addAcceptedTid(tid);

      // Second validation fails
      final res2 = StsCryptoService.validateToken(raw20Digits: digits, meter: meter);
      expect(res2.status, equals(ValidationStatus.tidReused));
    });

    test('Corrupted digit token fails CRC check with CRC_FAILED', () {
      final tid = TidService.calculateTidMinutes();
      final digits = StsCryptoService.generateTokenDigits(
        masterKeyHex: meter.masterKeyHex,
        sgc: meter.sgc,
        meterSerial: meter.meterSerial,
        tokenClassCode: 0,
        subClassCode: 0,
        tidMinutes: tid,
        amountKwh: 75.0,
      );

      // Corrupt the last digit
      final corruptedLastDigit = (int.parse(digits[19]) + 1) % 10;
      final corrupted = '${digits.substring(0, 19)}$corruptedLastDigit';

      final res = StsCryptoService.validateToken(raw20Digits: corrupted, meter: meter);
      expect(res.status, equals(ValidationStatus.crcFailed));
    });
  });
}
