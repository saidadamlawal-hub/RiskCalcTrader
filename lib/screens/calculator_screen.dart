import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/trade_calculation.dart';
import '../services/app_state.dart';
import '../services/calculator_engine.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _balanceController = TextEditingController();
  final _riskController = TextEditingController();
  final _entryController = TextEditingController();
  final _slController = TextEditingController();
  final _tpController = TextEditingController();
  final _contractSizeController = TextEditingController();

  String _direction = "BUY / LONG";
  String _instrument = "Forex";

  CalculationResult? _result;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppState>();
      _balanceController.text = state.defaultBalance.toString();
      _riskController.text = state.defaultRisk.toString();
      _instrument = state.defaultInstrument;
      _updateContractSizeDefault();
    });
  }

  void _updateContractSizeDefault() {
    switch (_instrument) {
      case "Forex":
        _contractSizeController.text = "100000";
        break;
      case "Crypto":
      case "Stocks":
      case "Custom":
        _contractSizeController.text = "1";
        break;
      case "Indices":
      case "Futures":
        _contractSizeController.text = "10";
        break;
    }
  }

  void _runCalculation() {
    setState(() {
      _validationError = null;
    });

    final double? balance = double.tryParse(_balanceController.text);
    final double? riskPercent = double.tryParse(_riskController.text);
    final double? entry = double.tryParse(_entryController.text);
    final double? sl = double.tryParse(_slController.text);
    final double? tp = double.tryParse(_tpController.text);
    final double? contractSize = double.tryParse(_contractSizeController.text);

    if (balance == null || balance <= 0) {
      setState(() => _validationError = "Invalid Account Balance");
      return;
    }
    if (riskPercent == null || riskPercent <= 0 || riskPercent > 100) {
      setState(() => _validationError = "Risk Percent must be between 0.1% and 100%");
      return;
    }
    if (entry == null || entry <= 0) {
      setState(() => _validationError = "Invalid Entry Price");
      return;
    }
    if (sl == null || sl <= 0) {
      setState(() => _validationError = "Invalid Stop-Loss Price");
      return;
    }
    if (entry == sl) {
      setState(() => _validationError = "Entry Price and Stop-Loss cannot be equal");
      return;
    }
    if (contractSize == null || contractSize <= 0) {
      setState(() => _validationError = "Contract Size is required");
      return;
    }

    if (_direction == "BUY / LONG" && sl > entry) {
      setState(() => _validationError = "Stop-Loss must be below Entry for LONG positions");
      return;
    }
    if (_direction == "SELL / SHORT" && sl < entry) {
      setState(() => _validationError = "Stop-Loss must be above Entry for SHORT positions");
      return;
    }

    final res = CalculatorEngine.calculate(
      balance: balance,
      riskPercent: riskPercent,
      entry: entry,
      sl: sl,
      tp: tp,
      direction: _direction,
      instrument: _instrument,
      contractSize: contractSize,
    );

    setState(() {
      _result = res;
    });

    final state = context.read<AppState>();
    state.saveCalculation(
      TradeCalculation(
        id: const Uuid().v4(),
        dateTime: DateTime.now(),
        instrument: _instrument,
        direction: _direction,
        accountBalance: balance,
        riskPercent: riskPercent,
        entryPrice: entry,
        stopLoss: sl,
        takeProfit: tp,
        positionSize: res.positionSize,
        riskAmount: res.riskAmount,
        potentialProfit: res.potentialProfit,
        riskRewardRatio: res.riskReward,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text("RiskCalc Trader")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _direction = "BUY / LONG"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _direction == "BUY / LONG" ? Colors.green : Colors.grey[800],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("BUY / LONG"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _direction = "SELL / SHORT"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _direction == "SELL / SHORT" ? Colors.red : Colors.grey[800],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("SELL / SHORT"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _instrument,
                decoration: const InputDecoration(labelText: "Instrument Asset Class", border: OutlineInputBorder()),
                items: ["Forex", "Crypto", "Stocks", "Indices", "Futures", "Custom"]
                    .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _instrument = val;
                      _updateContractSizeDefault();
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _balanceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: "Account Balance", border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _contractSizeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: "Contract Size", border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _riskController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: "Risk %", border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [0.25, 0.5, 1.0, 1.5, 2.0, 3.0, 5.0].map((val) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: Text("$val%"),
                        onPressed: () {
                          _riskController.text = val.toString();
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _entryController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Entry Price", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _slController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Stop-Loss Price", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _tpController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Take-Profit (Optional)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),

              if (_validationError != null)
                Card(
                  color: Colors.red[900],
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(_validationError!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),

              ElevatedButton(
                onPressed: _runCalculation,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text("Calculate Position", style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),

              if (_result != null) ...[
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text("CALCULATION RESULTS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2)),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Recommended Lot Size:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            Text("${_result!.positionSize.toStringAsFixed(3)} Lots", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Units Equivalent:", style: TextStyle(fontSize: 16)),
                            Text(_result!.units.toStringAsFixed(0), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total Money At Risk:"),
                            Text(state.formatCurrency(_result!.riskAmount), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("SL Price Distance:"),
                            Text("${_result!.slDistance.toStringAsFixed(5)} points"),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Potential Profit:"),
                            Text(state.formatCurrency(_result!.potentialProfit), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Risk/Reward Ratio:"),
                            Text(_result!.riskReward, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              const Text(
                "Trading involves substantial risk. This calculator is for educational and planning purposes only and does not guarantee trading results.",
                style: TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
