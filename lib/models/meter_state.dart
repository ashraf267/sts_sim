enum RelayStatus { connected, disconnected }

class MeterState {
  final String meterSerial; // PAN e.g., "01234567890"
  final String sgc;         // Supply Group Code e.g., "100001"
  final int krn;            // Key Revision Number e.g., 1
  final String masterKeyHex;// Vending Master Key Hex (128-bit)
  double balanceKwh;
  double totalRechargedKwh;
  RelayStatus relayStatus;
  final Set<int> acceptedTids;
  int? lastAcceptedTid;

  MeterState({
    required this.meterSerial,
    required this.sgc,
    this.krn = 1,
    this.masterKeyHex = '0123456789ABCDEF0123456789ABCDEF',
    this.balanceKwh = 0.0,
    this.totalRechargedKwh = 0.0,
    this.relayStatus = RelayStatus.disconnected,
    Set<int>? acceptedTids,
    this.lastAcceptedTid,
  }) : acceptedTids = acceptedTids ?? <int>{};

  bool isTidAccepted(int tid) {
    return acceptedTids.contains(tid);
  }

  void addAcceptedTid(int tid) {
    acceptedTids.add(tid);
    if (lastAcceptedTid == null || tid > lastAcceptedTid!) {
      lastAcceptedTid = tid;
    }
  }

  MeterState copyWith({
    String? meterSerial,
    String? sgc,
    int? krn,
    String? masterKeyHex,
    double? balanceKwh,
    double? totalRechargedKwh,
    RelayStatus? relayStatus,
    Set<int>? acceptedTids,
    int? lastAcceptedTid,
  }) {
    return MeterState(
      meterSerial: meterSerial ?? this.meterSerial,
      sgc: sgc ?? this.sgc,
      krn: krn ?? this.krn,
      masterKeyHex: masterKeyHex ?? this.masterKeyHex,
      balanceKwh: balanceKwh ?? this.balanceKwh,
      totalRechargedKwh: totalRechargedKwh ?? this.totalRechargedKwh,
      relayStatus: relayStatus ?? this.relayStatus,
      acceptedTids: acceptedTids ?? Set<int>.from(this.acceptedTids),
      lastAcceptedTid: lastAcceptedTid ?? this.lastAcceptedTid,
    );
  }
}
