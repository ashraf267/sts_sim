enum TokenClass {
  credit(0, 'Electricity Credit'),
  keyChange(1, 'Key Change'),
  testClear(2, 'Clear / Test Token');

  final int code;
  final String label;
  const TokenClass(this.code, this.label);

  static TokenClass fromCode(int code) {
    return TokenClass.values.firstWhere(
      (c) => c.code == code,
      orElse: () => TokenClass.credit,
    );
  }
}

class StsToken {
  final String rawDigits;       // 20 numeric digits
  final TokenClass tokenClass;  // Class 0 = Credit, 1 = Key Change, 2 = Clear/Test
  final int subClass;
  final int tidMinutes;         // TID in minutes since STS Base Epoch (2014)
  final double amountKwh;
  final int crc;
  final DateTime timestamp;

  StsToken({
    required this.rawDigits,
    required this.tokenClass,
    required this.subClass,
    required this.tidMinutes,
    required this.amountKwh,
    required this.crc,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Formats the 20 raw digits into 5 blocks of 4 digits: `XXXX-XXXX-XXXX-XXXX-XXXX`
  String get formattedDigits {
    final clean = rawDigits.replaceAll(RegExp(r'\D'), '');
    if (clean.length != 20) return rawDigits;
    return '${clean.substring(0, 4)}-${clean.substring(4, 8)}-${clean.substring(8, 12)}-${clean.substring(12, 16)}-${clean.substring(16, 20)}';
  }

  @override
  String toString() => 'StsToken(digits: $formattedDigits, class: ${tokenClass.label}, kwh: $amountKwh, TID: $tidMinutes)';
}
