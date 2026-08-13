import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _balanceController = TextEditingController();
  final _riskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _balanceController.text = state.defaultBalance.toString();
    _riskController.text = state.defaultRisk.toString();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text("Configuration Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Trading Profile Defaults", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          TextField(
            controller: _balanceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: "Default Account Balance", border: OutlineInputBorder()),
            onChanged: (val) {
              final double? d = double.tryParse(val);
              if (d != null) state.updateSettings(balance: d);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _riskController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: "Default Risk Percentage (%)", border: OutlineInputBorder()),
            onChanged: (val) {
              final double? d = double.tryParse(val);
              if (d != null) state.updateSettings(risk: d);
            },
          ),
          const Divider(height: 40),
          const Text("Localization & Currencies", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: state.defaultCurrency,
            decoration: const InputDecoration(labelText: "Account Currency Symbol", border: OutlineInputBorder()),
            items: ["USD", "EUR", "GBP", "NGN", "CAD", "AUD", "JPY"]
                .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                .toList(),
            onChanged: (val) {
              if (val != null) state.updateSettings(currency: val);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: state.defaultInstrument,
            decoration: const InputDecoration(labelText: "Default Instrument Type", border: OutlineInputBorder()),
            items: ["Forex", "Crypto", "Stocks", "Indices", "Futures", "Custom"]
                .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                .toList(),
            onChanged: (val) {
              if (val != null) state.updateSettings(instrument: val);
            },
          ),
          const Divider(height: 40),
          const Text("Visual Theme Mode", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text("Dark Theme Active"),
            subtitle: const Text("Enable dark layout interface styles"),
            value: state.isDarkMode,
            onChanged: (val) => state.updateSettings(dark: val),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: state.decimalPrecision,
            decoration: const InputDecoration(labelText: "Output Decimal Precision", border: OutlineInputBorder()),
            items: [2, 3, 4, 5, 8]
                .map((val) => DropdownMenuItem(value: val, child: Text("$val Decimal Places")))
                .toList(),
            onChanged: (val) {
              if (val != null) state.updateSettings(precision: val);
            },
          ),
          const Divider(height: 40),
          const Text("About App", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text("RiskCalc Trader App version 1.0.0. All local trading math operations are optimized offline for high-precision institutional trade management."),
        ],
      ),
    );
  }
}
