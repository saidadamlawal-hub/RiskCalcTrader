import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/trade_calculation.dart';
import 'local_store_service.dart';

class AppState extends ChangeNotifier {
  final LocalStoreService _store = LocalStoreService();

  List<TradeCalculation> history = [];

  double defaultBalance = 10000.0;
  double defaultRisk = 1.0;
  String defaultCurrency = "USD";
  String defaultInstrument = "Forex";
  int decimalPrecision = 2;
  bool isDarkMode = true;

  bool isInitialized = false;

  Future<void> init() async {
    history = await _store.loadHistory();
    
    final b = await _store.loadSetting("defaultBalance");
    if (b != null) defaultBalance = double.tryParse(b) ?? 10000.0;

    final r = await _store.loadSetting("defaultRisk");
    if (r != null) defaultRisk = double.tryParse(r) ?? 1.0;

    defaultCurrency = await _store.loadSetting("defaultCurrency") ?? "USD";
    defaultInstrument = await _store.loadSetting("defaultInstrument") ?? "Forex";

    final p = await _store.loadSetting("decimalPrecision");
    if (p != null) decimalPrecision = int.tryParse(p) ?? 2;

    final m = await _store.loadSetting("isDarkMode");
    if (m != null) isDarkMode = m == "true";

    isInitialized = true;
    notifyListeners();
  }

  Future<void> updateSettings({
    double? balance,
    double? risk,
    String? currency,
    String? instrument,
    int? precision,
    bool? dark,
  }) async {
    if (balance != null) {
      defaultBalance = balance;
      await _store.saveSetting("defaultBalance", balance.toString());
    }
    if (risk != null) {
      defaultRisk = risk;
      await _store.saveSetting("defaultRisk", risk.toString());
    }
    if (currency != null) {
      defaultCurrency = currency;
      await _store.saveSetting("defaultCurrency", currency);
    }
    if (instrument != null) {
      defaultInstrument = instrument;
      await _store.saveSetting("defaultInstrument", instrument);
    }
    if (precision != null) {
      decimalPrecision = precision;
      await _store.saveSetting("decimalPrecision", precision.toString());
    }
    if (dark != null) {
      isDarkMode = dark;
      await _store.saveSetting("isDarkMode", dark.toString());
    }
    notifyListeners();
  }

  Future<void> saveCalculation(TradeCalculation calc) async {
    history.insert(0, calc);
    await _store.saveHistory(history);
    notifyListeners();
  }

  Future<void> deleteFromHistory(String id) async {
    history.removeWhere((h) => h.id == id);
    await _store.saveHistory(history);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    history.clear();
    await _store.saveHistory(history);
    notifyListeners();
  }

  String formatCurrency(double amount) {
    String sym = "";
    switch (defaultCurrency) {
      case "USD": sym = "\$"; break;
      case "EUR": sym = "€"; break;
      case "GBP": sym = "£"; break;
      case "NGN": sym = "₦"; break;
      case "CAD": sym = "CA\$"; break;
      case "AUD": sym = "A\$"; break;
      case "JPY": sym = "¥"; break;
      default: sym = "$defaultCurrency ";
    }
    return "$sym${amount.toStringAsFixed(decimalPrecision)}";
  }
}
