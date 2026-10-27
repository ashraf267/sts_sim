import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/simulation_provider.dart';
import 'ui/home_screen.dart';
import 'ui/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StsSimApp());
}

class StsSimApp extends StatelessWidget {
  const StsSimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SimulationProvider()),
      ],
      child: MaterialApp(
        title: 'STS Prepaid Meter Simulator',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
