import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meter_state.dart';
import '../../providers/simulation_provider.dart';
import '../theme/app_theme.dart';

class LoadSimulatorCard extends StatelessWidget {
  const LoadSimulatorCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SimulationProvider>();
    final meter = provider.meter;
    final isConnected = meter.relayStatus == RelayStatus.connected;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.power, color: AppTheme.warningOrange, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appliance Load Simulator',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Text(
                      'Simulate household power consumption',
                      style: TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24, color: AppTheme.cardBorder),

            // Live Load Draw Gauge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D141C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isConnected && provider.totalActiveWattage > 0
                      ? AppTheme.warningOrange.withValues(alpha: 0.6)
                      : AppTheme.cardBorder,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ACTIVE POWER DRAW', style: TextStyle(fontSize: 10, color: Colors.white38)),
                      const SizedBox(height: 4),
                      Text(
                        '${provider.totalActiveWattage.toStringAsFixed(0)} W (${provider.totalActiveKilowatts.toStringAsFixed(2)} kW)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isConnected && provider.totalActiveWattage > 0 ? AppTheme.warningOrange : Colors.white38,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('EST. TIME REMAINING', style: TextStyle(fontSize: 10, color: Colors.white38)),
                      const SizedBox(height: 4),
                      Text(
                        provider.totalActiveKilowatts > 0 && meter.balanceKwh > 0
                            ? '${provider.estimatedMinutesRemaining.toStringAsFixed(1)} mins'
                            : '-- mins',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryCyan,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Appliance List Toggles
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.appliances.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final appliance = provider.appliances[index];
                final isWorking = appliance.isActive && isConnected;

                return InkWell(
                  onTap: () => provider.toggleAppliance(appliance.id),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: appliance.isActive
                          ? AppTheme.warningOrange.withValues(alpha: 0.12)
                          : const Color(0xFF0B1118),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: appliance.isActive ? AppTheme.warningOrange : AppTheme.cardBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getIconData(appliance.iconName),
                          color: isWorking ? AppTheme.warningOrange : Colors.white38,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appliance.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isWorking ? Colors.white : Colors.white60,
                                ),
                              ),
                              Text(
                                '${appliance.wattageWatts.toStringAsFixed(0)} Watts',
                                style: const TextStyle(fontSize: 11, color: Colors.white38),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: appliance.isActive,
                          activeTrackColor: AppTheme.warningOrange,
                          onChanged: (_) => provider.toggleAppliance(appliance.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'lightbulb':
        return Icons.lightbulb_outline;
      case 'kitchen':
        return Icons.kitchen;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'water_drop':
        return Icons.water_drop;
      default:
        return Icons.power;
    }
  }
}
