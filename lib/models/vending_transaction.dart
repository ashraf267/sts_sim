import 'sts_token.dart';

class VendingTransaction {
  final String id;
  final String meterSerial;
  final double amountNaira;
  final double tariffNairaPerKwh;
  final double calculatedKwh;
  final StsToken generatedToken;
  final DateTime timestamp;

  VendingTransaction({
    required this.id,
    required this.meterSerial,
    required this.amountNaira,
    required this.tariffNairaPerKwh,
    required this.calculatedKwh,
    required this.generatedToken,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
