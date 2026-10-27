import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meter_state.dart';
import '../../providers/simulation_provider.dart';
import '../theme/app_theme.dart';

class PrepaidMeterCard extends StatelessWidget {
  const PrepaidMeterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SimulationProvider>();
    final meter = provider.meter;
    final isConnected = meter.relayStatus == RelayStatus.connected;

    return Card(
      color: const Color(0xFF161E27),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Meter Header Branding
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.electric_meter, color: AppTheme.accentGreen, size: 28),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NEPA / DISCO PREPAID METER',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.white),
                        ),
                        Text(
                          'NO: ${meter.meterSerial} | SGC: ${meter.sgc}',
                          style: const TextStyle(fontSize: 11, color: Colors.white38),
                        ),
                      ],
                    ),
                  ],
                ),
                // Status LED Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isConnected ? AppTheme.accentGreen.withValues(alpha: 0.15) : AppTheme.alertRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isConnected ? AppTheme.accentGreen : AppTheme.alertRed,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isConnected ? AppTheme.accentGreen : AppTheme.alertRed,
                          boxShadow: [
                            BoxShadow(
                              color: isConnected ? AppTheme.accentGreen : AppTheme.alertRed,
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isConnected ? 'RELAY CLOSED (ON)' : 'RELAY TRIPPED (OFF)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isConnected ? AppTheme.accentGreen : AppTheme.alertRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Retro LCD Display Screen
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.lcdBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.lcdTextMuted, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'LCD DISPLAY',
                        style: TextStyle(fontSize: 9, color: AppTheme.lcdTextMuted, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'TOTAL RECHARGED: ${meter.totalRechargedKwh.toStringAsFixed(1)} kWh',
                        style: const TextStyle(fontSize: 9, color: AppTheme.lcdTextMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      provider.lcdDisplayMessage,
                      style: AppTheme.lcdTextStyle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 12-Key Tactile Keypad Matrix
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F151C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                children: [
                  _buildKeypadRow(context, ['1', '2', '3'], provider),
                  const SizedBox(height: 12),
                  _buildKeypadRow(context, ['4', '5', '6'], provider),
                  const SizedBox(height: 12),
                  _buildKeypadRow(context, ['7', '8', '9'], provider),
                  const SizedBox(height: 12),
                  _buildKeypadRow(context, ['<', '0', '↵'], provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadRow(BuildContext context, List<String> keys, SimulationProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        final isSubmit = key == '↵';
        final isBackspace = key == '<';

        Color btnColor = const Color(0xFF1E2833);
        Color textColor = Colors.white;

        if (isSubmit) {
          btnColor = AppTheme.accentGreen;
          textColor = Colors.black;
        } else if (isBackspace) {
          btnColor = AppTheme.alertRed.withValues(alpha: 0.8);
          textColor = Colors.white;
        }

        return SizedBox(
          width: 70,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              foregroundColor: textColor,
              elevation: 4,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (isSubmit) {
                provider.keypadSubmitToken();
              } else if (isBackspace) {
                provider.keypadBackspace();
              } else {
                provider.keypadPressDigit(key);
              }
            },
            child: Text(
              key,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
