import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/simulation_provider.dart';
import '../theme/app_theme.dart';

class VendingTerminalCard extends StatefulWidget {
  const VendingTerminalCard({super.key});

  @override
  State<VendingTerminalCard> createState() => _VendingTerminalCardState();
}

class _VendingTerminalCardState extends State<VendingTerminalCard> {
  final _amountController = TextEditingController(text: '5000');
  final _tariffController = TextEditingController(text: '100'); // ₦100/kWh

  @override
  void dispose() {
    _amountController.dispose();
    _tariffController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SimulationProvider>();
    final amountNaira = double.tryParse(_amountController.text) ?? 0.0;
    final tariff = double.tryParse(_tariffController.text) ?? 100.0;
    final calculatedKwh = tariff > 0 ? (amountNaira / tariff) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.point_of_sale, color: AppTheme.primaryCyan, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Utility Vending POS',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Text(
                      'STS Token Generator Terminal',
                      style: TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24, color: AppTheme.cardBorder),

            // Meter Serial & SGC Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1118),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TARGET METER NO.', style: TextStyle(fontSize: 10, color: Colors.white38)),
                      Text(
                        provider.meter.meterSerial,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryCyan),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('SUPPLY GROUP (SGC)', style: TextStyle(fontSize: 10, color: Colors.white38)),
                      Text(
                        provider.meter.sgc,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Amount Input
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Purchase Amount (₦)',
                prefixText: '₦ ',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Tariff Input
            TextField(
              controller: _tariffController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tariff Rate (₦ / kWh)',
                suffixText: '₦/kWh',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // kWh Calculation Preview
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryCyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Calculated Energy Units:', style: TextStyle(color: Colors.white70)),
                  Text(
                    '${calculatedKwh.toStringAsFixed(1)} kWh',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryCyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: amountNaira > 0
                    ? () {
                        provider.generateVendingToken(
                          amountNaira: amountNaira,
                          tariffNairaPerKwh: tariff,
                        );
                      }
                    : null,
                icon: const Icon(Icons.qr_code_2, color: Colors.black),
                label: const Text(
                  'GENERATE 20-DIGIT STS TOKEN',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ),

            // Latest Generated Token Banner
            if (provider.vendingHistory.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('LATEST GENERATED RECHARGE TOKEN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white54)),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final latestTx = provider.vendingHistory.first;
                  final token = latestTx.generatedToken;
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF09141B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: [
                        SelectableText(
                          token.formattedDigits,
                          style: AppTheme.lcdTextStyle.copyWith(fontSize: 22, color: AppTheme.accentGreen),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  side: const BorderSide(color: Colors.white24),
                                ),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: token.rawDigits));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Token digits copied to clipboard!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy, size: 16, color: Colors.white70),
                                label: const Text('Copy Token', style: TextStyle(fontSize: 12, color: Colors.white70)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentGreen,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: () {
                                  provider.autoKeyInAndSubmitToken(token.rawDigits);
                                },
                                icon: const Icon(Icons.dialpad, size: 16, color: Colors.black),
                                label: const Text('Auto-Key in Meter', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
