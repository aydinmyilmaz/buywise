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
}
