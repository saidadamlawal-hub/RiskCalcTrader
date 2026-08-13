import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'widgets/app_navigation.dart';

void main() {
  runApp(const RiskCalcTraderApp());
}

class RiskCalcTraderApp extends StatelessWidget {
  const RiskCalcTraderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: Consumer<AppState>(
        builder: (context, state, child) {
          if (!state.isInitialized) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          return MaterialApp(
            title: 'RiskCalc Trader',
            debugShowCheckedModeBanner: false,
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorSchemeSeed: Colors.blueAccent,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorSchemeSeed: Colors.blueAccent,
              scaffoldBackgroundColor: Colors.black,
            ),
            home: const AppNavigation(),
          );
        },
      ),
    );
  }
}
