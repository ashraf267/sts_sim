import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import '../models/meter_state.dart';
import '../models/sts_token.dart';
import 'tid_service.dart';

enum ValidationStatus {
  success('ACCEPT', 'Token validated successfully'),
  crcFailed('E-01', 'CRC checksum verification failed'),
  tidReused('USED', 'Token has already been used'),
  tidExpired('OLD', 'Token TID is expired'),
  invalidLength('REJECTED', 'Token must be exactly 20 digits');

  final String lcdCode;
  final String description;
  const ValidationStatus(this.lcdCode, this.description);
}

class ValidationResult {
  final ValidationStatus status;
  final StsToken? token;
  final double creditedKwh;
  final String debugLog;

  ValidationResult({
    required this.status,
    this.token,
    this.creditedKwh = 0.0,
    required this.debugLog,
  });

  bool get isSuccess => status == ValidationStatus.success;
}

class StsCryptoService {
  /// CRC-16 CCITT polynomial (0x1021)
  static int calculateCrc16(List<int> bytes) {
    int crc = 0xFFFF;
    for (int b in bytes) {
      crc ^= (b << 8);
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }
    return crc;
  }

  /// Derives 128-bit Decoder Key (DK) from Master Key (VK), SGC, and Meter Serial Number (PAN).
  /// DK = HMAC-SHA256(VK, SGC + PAN)[0..16]
  static Uint8List deriveDecoderKey({
    required String masterKeyHex,
    required String sgc,
    required String meterSerial,
  }) {
    final vkBytes = _hexToBytes(masterKeyHex);
    final inputString = '$sgc-$meterSerial';
    final hmac = Hmac(sha256, vkBytes);
    final digest = hmac.convert(utf8.encode(inputString));
    return Uint8List.fromList(digest.bytes.sublist(0, 16));
  }

  /// Generates 64-bit AES-128 keystream mask for CTR block mode
  static Uint8List generateKeystream({
    required Uint8List decoderKey,
    required String sgc,
    required String meterSerial,
  }) {
    final counterBlock = Uint8List(16);
    final sgcBytes = utf8.encode(sgc);
    final serialBytes = utf8.encode(meterSerial);

    for (int i = 0; i < sgcBytes.length && i < 6; i++) {
      counterBlock[i] = sgcBytes[i];
    }
    for (int i = 0; i < serialBytes.length && i < 10; i++) {
      counterBlock[6 + i] = serialBytes[i];
    }

    final key = enc.Key(decoderKey);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.ecb, padding: null));
    final encrypted = encrypter.encryptBytes(counterBlock);
    return Uint8List.fromList(encrypted.bytes.sublist(0, 8));
  }

  /// Encodes token parameters into 20 BCD Decimal Digits.
  static String generateTokenDigits({
    required String masterKeyHex,
    required String sgc,
    required String meterSerial,
    required int tokenClassCode,
    required int subClassCode,
    required int tidMinutes,
    required double amountKwh,
  }) {
    final amountUnits = (amountKwh * 10).round().clamp(0, 65535);

    // Assemble 6-byte unencrypted payload (48 bits)
    final payload = Uint8List(6);
    payload[0] = ((tokenClassCode & 0x03) << 6) | ((subClassCode & 0x0F) << 2) | ((tidMinutes >> 22) & 0x03);
    payload[1] = (tidMinutes >> 14) & 0xFF;
    payload[2] = (tidMinutes >> 6) & 0xFF;
    payload[3] = ((tidMinutes & 0x3F) << 2) | ((amountUnits >> 14) & 0x03);
    payload[4] = (amountUnits >> 6) & 0xFF;
    payload[5] = ((amountUnits & 0x3F) << 2);

    final crc = calculateCrc16(payload);

    // Combine 6 bytes payload + 2 bytes CRC = 8 bytes (64 bits)
    final block64 = Uint8List(8);
    for (int i = 0; i < 6; i++) {
      block64[i] = payload[i];
    }
    block64[6] = (crc >> 8) & 0xFF;
    block64[7] = crc & 0xFF;

    // Derive DK & generate AES-128 keystream
    final dk = deriveDecoderKey(
      masterKeyHex: masterKeyHex,
      sgc: sgc,
      meterSerial: meterSerial,
    );
    final keystream = generateKeystream(decoderKey: dk, sgc: sgc, meterSerial: meterSerial);

    // Cipher: XOR 64-bit block with keystream
    final cipher64 = Uint8List(8);
    for (int i = 0; i < 8; i++) {
      cipher64[i] = block64[i] ^ keystream[i];
    }

    // Convert 64-bit cipher bytes to BigInt -> 20 decimal digits
    BigInt bigVal = BigInt.zero;
    for (int i = 0; i < 8; i++) {
      bigVal = (bigVal << 8) | BigInt.from(cipher64[i]);
    }

    return bigVal.toString().padLeft(20, '0');
  }

  /// Decrypts a 20-digit STS token and validates CRC, TID, and Meter Key match.
  static ValidationResult validateToken({
    required String raw20Digits,
    required MeterState meter,
  }) {
    final cleanDigits = raw20Digits.replaceAll(RegExp(r'\D'), '');
    final logs = StringBuffer();

    logs.writeln('=== STS TOKEN DECRYPTION ENGINE ===');
    logs.writeln('1. Received Digits: $cleanDigits');

    if (cleanDigits.length != 20) {
      logs.writeln('FAILED: Token length is ${cleanDigits.length}, expected 20 digits.');
      return ValidationResult(
        status: ValidationStatus.invalidLength,
        debugLog: logs.toString(),
      );
    }

    // 1. Convert 20 decimal digits string to BigInt -> 8 cipher bytes
    final bigVal = BigInt.parse(cleanDigits);
    final cipher64 = Uint8List(8);
    BigInt temp = bigVal;
    for (int i = 7; i >= 0; i--) {
      cipher64[i] = (temp & BigInt.from(0xFF)).toInt();
      temp = temp >> 8;
    }

    logs.writeln('2. Mapped 20 digits to 64-bit cipher bytes.');

    // 2. Derive Decoder Key (DK) & generate Keystream
    final dk = deriveDecoderKey(
      masterKeyHex: meter.masterKeyHex,
      sgc: meter.sgc,
      meterSerial: meter.meterSerial,
    );
    final keystream = generateKeystream(decoderKey: dk, sgc: meter.sgc, meterSerial: meter.meterSerial);
    logs.writeln('3. Derived Meter Decoder Key (DK): ${_bytesToHex(dk)}');

    // 3. Decrypt: XOR cipher bytes with keystream
    final block64 = Uint8List(8);
    for (int i = 0; i < 8; i++) {
      block64[i] = cipher64[i] ^ keystream[i];
    }

    // Extract payload & CRC
    final payload = Uint8List(6);
    for (int i = 0; i < 6; i++) {
      payload[i] = block64[i];
    }
    final extractedCrc = (block64[6] << 8) | block64[7];

    final tokenClassCode = (payload[0] >> 6) & 0x03;
    final subClassCode = (payload[0] >> 2) & 0x0F;
    final tidMinutes = ((payload[0] & 0x03) << 22) | (payload[1] << 14) | (payload[2] << 6) | ((payload[3] >> 2) & 0x3F);
    final amountUnits = ((payload[3] & 0x03) << 14) | (payload[4] << 6) | ((payload[5] >> 2) & 0x3F);
    final amountKwh = amountUnits / 10.0;

    logs.writeln('4. Decrypted Payload:');
    logs.writeln('   - Class: $tokenClassCode (${TokenClass.fromCode(tokenClassCode).label})');
    logs.writeln('   - TID Minutes: $tidMinutes (${TidService.formatTidDate(tidMinutes)})');
    logs.writeln('   - Amount: $amountKwh kWh');
    logs.writeln('   - CRC in Token: 0x${extractedCrc.toRadixString(16).padLeft(4, '0').toUpperCase()}');

    // 4. Calculate CRC over 6-byte payload
    final computedCrc = calculateCrc16(payload);
    logs.writeln('   - Computed CRC: 0x${computedCrc.toRadixString(16).padLeft(4, '0').toUpperCase()}');

    if (extractedCrc != computedCrc) {
      logs.writeln('FAILED: CRC Checksum Mismatch! (Corrupted digits or wrong Meter DK).');
      return ValidationResult(
        status: ValidationStatus.crcFailed,
        debugLog: logs.toString(),
      );
    }
    logs.writeln('5. CRC Check PASSED ✓');

    // 5. TID Replay Attack Check
    if (meter.isTidAccepted(tidMinutes)) {
      logs.writeln('FAILED: TID $tidMinutes has ALREADY been accepted by this meter! (Replay Attack Blocked).');
      return ValidationResult(
        status: ValidationStatus.tidReused,
        debugLog: logs.toString(),
      );
    }

    if (meter.lastAcceptedTid != null && tidMinutes < meter.lastAcceptedTid!) {
      logs.writeln('FAILED: TID $tidMinutes is older than last accepted TID ${meter.lastAcceptedTid}! (Expired Token).');
      return ValidationResult(
        status: ValidationStatus.tidExpired,
        debugLog: logs.toString(),
      );
    }

    logs.writeln('6. TID Replay & Epoch Check PASSED ✓');
    logs.writeln('=== TOKEN ACCEPTED SUCCESSFULLY (+ $amountKwh kWh) ===');

    final token = StsToken(
      rawDigits: cleanDigits,
      tokenClass: TokenClass.fromCode(tokenClassCode),
      subClass: subClassCode,
      tidMinutes: tidMinutes,
      amountKwh: amountKwh,
      crc: computedCrc,
    );

    return ValidationResult(
      status: ValidationStatus.success,
      token: token,
      creditedKwh: amountKwh,
      debugLog: logs.toString(),
    );
  }

  static List<int> _hexToBytes(String hex) {
    final clean = hex.replaceAll(' ', '');
    final bytes = <int>[];
    for (int i = 0; i < clean.length; i += 2) {
      bytes.add(int.parse(clean.substring(i, i + 2), radix: 16));
    }
    return bytes;
  }

  static String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join();
  }
}
