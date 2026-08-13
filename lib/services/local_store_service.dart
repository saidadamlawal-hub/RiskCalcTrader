import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trade_calculation.dart';

class LocalStoreService {
  static const _historyKey = 'calculation_history_v1';
  static const _settingsPrefix = 'settings_';

  Future<List<TradeCalculation>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => TradeCalculation.fromJson(e)).toList();
  }

  Future<void> saveHistory(List<TradeCalculation> history) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(history.map((h) => h.toJson()).toList());
    await prefs.setString(_historyKey, raw);
  }

  Future<void> saveSetting(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsPrefix + key, value);
  }

  Future<String?> loadSetting(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_settingsPrefix + key);
  }
}
