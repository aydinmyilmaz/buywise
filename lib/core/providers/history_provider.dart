import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/ai_response.dart';
import '../models/decision_record.dart';
import '../models/purchase_query.dart';
import '../services/storage_service.dart';
import '../../config/app_config.dart';

class HistoryProvider extends ChangeNotifier {
  final List<DecisionRecord> _items = [];

  List<DecisionRecord> get items => List.unmodifiable(_items);

  Future<void> load() async {
    final list = await StorageService.readList(AppConfig.storageHistoryKey);
    if (list != null) {
      _items
        ..clear()
        ..addAll(list.map(DecisionRecord.fromMap));
      notifyListeners();
    }
  }

  Future<void> add(PurchaseQuery purchase, AIResponse response) async {
    final record = DecisionRecord(
      id: const Uuid().v4(),
      productName: purchase.productName,
      price: purchase.price,
      currency: purchase.currency,
      decision: response.decision,
      headline: response.headline,
      createdAt: DateTime.now(),
    );
    _items.insert(0, record);
    await StorageService.saveList(
      AppConfig.storageHistoryKey,
      _items.map((e) => e.toMap()).toList(),
    );
    notifyListeners();
  }

  Future<void> clear() async {
    _items.clear();
    await StorageService.delete(AppConfig.storageHistoryKey);
    notifyListeners();
  }

  // ============ INSIGHTS CALCULATIONS ============

  /// Get decisions made this month
  int get decisionsThisMonth {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return _items.where((item) => item.createdAt.isAfter(startOfMonth)).length;
  }

  /// Calculate money saved by waiting or saying no
  double getMoneySaved(String currency) {
    return _items
        .where((item) =>
            item.currency == currency &&
            (item.decision.toLowerCase() == 'wait' ||
             item.decision.toLowerCase() == 'leaning_no' ||
             item.decision.toLowerCase() == 'no'))
        .fold(0.0, (sum, item) => sum + item.price);
  }

  /// Get count of impulse buys avoided (wait + no decisions)
  int get impulseBuysAvoided {
    return _items.where((item) =>
        item.decision.toLowerCase() == 'wait' ||
        item.decision.toLowerCase() == 'leaning_no' ||
        item.decision.toLowerCase() == 'no').length;
  }

  /// Get most common decision type
  String get mostCommonDecision {
    if (_items.isEmpty) return 'None';

    final counts = <String, int>{};
    for (final item in _items) {
      final decision = item.decision.toLowerCase();
      counts[decision] = (counts[decision] ?? 0) + 1;
    }

    var maxCount = 0;
    var mostCommon = 'None';
    counts.forEach((decision, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = decision;
      }
    });

    return mostCommon;
  }

  /// Get decisions breakdown by type
  Map<String, int> get decisionBreakdown {
    final breakdown = <String, int>{
      'yes': 0,
      'leaning_yes': 0,
      'wait': 0,
      'leaning_no': 0,
      'no': 0,
    };

    for (final item in _items) {
      final decision = item.decision.toLowerCase();
      if (breakdown.containsKey(decision)) {
        breakdown[decision] = breakdown[decision]! + 1;
      }
    }

    return breakdown;
  }

  // ============ BUDGET TRACKING ============

  /// Get total spent this month on approved purchases (yes/leaning_yes)
  double getMonthlySpending(String currency) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return _items
        .where((item) =>
            item.currency == currency &&
            item.createdAt.isAfter(startOfMonth) &&
            (item.decision.toLowerCase() == 'yes' ||
             item.decision.toLowerCase() == 'leaning_yes'))
        .fold(0.0, (sum, item) => sum + item.price);
  }

  /// Get budget progress percentage (0-100)
  double getBudgetProgress(String currency, double? budgetAmount) {
    if (budgetAmount == null || budgetAmount == 0) return 0;
    final spent = getMonthlySpending(currency);
    return (spent / budgetAmount * 100).clamp(0, 100);
  }

  /// Check if over budget
  bool isOverBudget(String currency, double? budgetAmount) {
    if (budgetAmount == null) return false;
    return getMonthlySpending(currency) > budgetAmount;
  }
}
