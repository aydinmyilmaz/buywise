import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/pending_decision.dart';
import '../services/storage_service.dart';
import '../../config/app_config.dart';

class PendingProvider extends ChangeNotifier {
  final List<PendingDecision> _items = [];

  List<PendingDecision> get items => List.unmodifiable(_items);

  List<PendingDecision> get activeItems {
    return _items.where((item) => !item.isReady).toList();
  }

  List<PendingDecision> get readyItems {
    return _items.where((item) => item.isReady).toList();
  }

  int get activeCount => activeItems.length;
  int get readyCount => readyItems.length;

  Future<void> load() async {
    final list = await StorageService.readList('pending_decisions');
    if (list != null) {
      _items
        ..clear()
        ..addAll(list.map(PendingDecision.fromMap));

      // Remove expired items older than 30 days
      final now = DateTime.now();
      _items.removeWhere((item) =>
        now.difference(item.waitUntil).inDays > 30
      );

      await _save();
      notifyListeners();
    }
  }

  Future<void> add({
    required String productName,
    required double price,
    required String currency,
    required String decision,
    required int waitHours,
  }) async {
    final pending = PendingDecision(
      id: const Uuid().v4(),
      productName: productName,
      price: price,
      currency: currency,
      decision: decision,
      waitUntil: DateTime.now().add(Duration(hours: waitHours)),
      createdAt: DateTime.now(),
    );

    _items.insert(0, pending);
    await _save();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _items.removeWhere((item) => item.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> clear() async {
    _items.clear();
    await StorageService.delete('pending_decisions');
    notifyListeners();
  }

  Future<void> _save() async {
    await StorageService.saveList(
      'pending_decisions',
      _items.map((e) => e.toMap()).toList(),
    );
  }
}
