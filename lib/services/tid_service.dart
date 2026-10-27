/// Service to handle STS Edition 2 Token Identifier (TID) calculations.
///
/// In STS Edition 2 (IEC 62055-41), TID is a 24-bit counter representing the number
/// of elapsed minutes since the Base Epoch: **2014-01-01 00:00:00 UTC**.
class TidService {
  /// Base Epoch for STS Edition 2
  static final DateTime baseEpoch = DateTime.utc(2014, 1, 1, 0, 0, 0);

  /// 24-bit max value for TID (16,777,215 minutes ≈ 31.9 years)
  static const int maxTidValue = 0xFFFFFF;

  /// Calculates TID in minutes from Base Epoch (2014-01-01) for a given DateTime.
  static int calculateTidMinutes([DateTime? timestamp]) {
    final target = (timestamp ?? DateTime.now()).toUtc();
    final difference = target.difference(baseEpoch);
    final minutes = difference.inMinutes;
    return minutes & maxTidValue;
  }

  /// Converts a 24-bit TID minute count back into a [DateTime] UTC object.
  static DateTime dateTimeFromTidMinutes(int tidMinutes) {
    return baseEpoch.add(Duration(minutes: tidMinutes));
  }

  /// Formats a TID minute count to a readable date/time string.
  static String formatTidDate(int tidMinutes) {
    final dt = dateTimeFromTidMinutes(tidMinutes).toLocal();
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}-$month-$day $hour:$minute';
  }
}
