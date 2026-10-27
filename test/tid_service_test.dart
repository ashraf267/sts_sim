import 'package:flutter_test/flutter_test.dart';
import 'package:sts_sim/services/tid_service.dart';

void main() {
  group('TidService Tests', () {
    test('Base epoch returns 0 TID minutes', () {
      final base = DateTime.utc(2014, 1, 1, 0, 0, 0);
      final tid = TidService.calculateTidMinutes(base);
      expect(tid, equals(0));
    });

    test('10 minutes after base epoch returns 10 TID minutes', () {
      final dt = DateTime.utc(2014, 1, 1, 0, 10, 0);
      final tid = TidService.calculateTidMinutes(dt);
      expect(tid, equals(10));
    });

    test('dateTimeFromTidMinutes roundtrip', () {
      final now = DateTime.now().toUtc();
      final tid = TidService.calculateTidMinutes(now);
      final restored = TidService.dateTimeFromTidMinutes(tid);

      // Difference should be within 1 minute due to minute rounding
      final diffSeconds = restored.difference(now).abs().inSeconds;
      expect(diffSeconds, lessThanOrEqualTo(60));
    });
  });
}
