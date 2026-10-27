class ApplianceLoad {
  final String id;
  final String name;
  final String iconName;
  final double wattageWatts;
  bool isActive;

  ApplianceLoad({
    required this.id,
    required this.name,
    required this.iconName,
    required this.wattageWatts,
    this.isActive = false,
  });

  /// Kilowatts power draw
  double get kilowatts => wattageWatts / 1000.0;

  ApplianceLoad copyWith({
    String? id,
    String? name,
    String? iconName,
    double? wattageWatts,
    bool? isActive,
  }) {
    return ApplianceLoad(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      wattageWatts: wattageWatts ?? this.wattageWatts,
      isActive: isActive ?? this.isActive,
    );
  }
}
