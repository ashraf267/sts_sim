import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/crypto_inspector_card.dart';
import 'widgets/load_simulator_card.dart';
import 'widgets/prepaid_meter_card.dart';
import 'widgets/vending_terminal_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryCyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt, color: AppTheme.primaryCyan, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('STS Prepaid Meter Simulator', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Standard Transfer Specification (IEC 62055-41) Demonstration', style: TextStyle(fontSize: 11, color: Colors.white54)),
              ],
            ),
          ],
        ),
        backgroundColor: AppTheme.cardBackground,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppTheme.cardBorder, height: 1),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Vending Terminal & Load Simulator
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: const [
                            VendingTerminalCard(),
                            SizedBox(height: 20),
                            LoadSimulatorCard(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Right Column: Prepaid Meter & Cryptographic Inspector
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: const [
                            PrepaidMeterCard(),
                            SizedBox(height: 20),
                            CryptoInspectorCard(),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: const [
                      PrepaidMeterCard(),
                      SizedBox(height: 20),
                      VendingTerminalCard(),
                      SizedBox(height: 20),
                      LoadSimulatorCard(),
                      SizedBox(height: 20),
                      CryptoInspectorCard(),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
