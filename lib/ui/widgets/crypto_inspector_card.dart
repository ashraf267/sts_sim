import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/simulation_provider.dart';
import '../theme/app_theme.dart';

class CryptoInspectorCard extends StatelessWidget {
  const CryptoInspectorCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SimulationProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.security, color: AppTheme.primaryCyan, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cryptographic & TID Inspector',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Text(
                      'Behind-the-scenes offline validation pipeline',
                      style: TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24, color: AppTheme.cardBorder),

            // Accepted TIDs Counter Summary
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D141C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ACCEPTED TIDs COUNT', style: TextStyle(fontSize: 10, color: Colors.white38)),
                        const SizedBox(height: 4),
                        Text(
                          '${provider.meter.acceptedTids.length} tokens',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentGreen),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D141C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('LAST ACCEPTED TID', style: TextStyle(fontSize: 10, color: Colors.white38)),
                        const SizedBox(height: 4),
                        Text(
                          provider.meter.lastAcceptedTid != null ? '${provider.meter.lastAcceptedTid}' : 'None',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryCyan),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              'DECRYPTION & VALIDATION LOG',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white54),
            ),
            const SizedBox(height: 8),

            // Debug Terminal Output
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 220),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF070B0E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  provider.lastDebugLog,
                  style: GoogleFonts.firaCode(
                    fontSize: 12,
                    color: AppTheme.accentGreen,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
