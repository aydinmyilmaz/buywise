import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/ai_response.dart';
import '../models/product_info.dart';
import '../models/purchase_query.dart';
import '../services/image_service.dart';
import '../services/openai_service.dart';

class DecisionProvider extends ChangeNotifier {
  String? _moodId;
  PurchaseQuery? _purchase;
  ProductInfo? _productInfo;
  Uint8List? _imageBytes;
  AIResponse? _result;
  bool _loading = false;

  String? get moodId => _moodId;
  PurchaseQuery? get purchase => _purchase;
  ProductInfo? get productInfo => _productInfo;
  Uint8List? get imageBytes => _imageBytes;
  AIResponse? get result => _result;
  bool get isLoading => _loading;

  void setMood(String id) {
    _moodId = id;
    notifyListeners();
  }

  void setPurchase(PurchaseQuery purchase) {
    _purchase = purchase;
    notifyListeners();
  }

  Future<void> pickImage() async {
    _imageBytes = await ImageService.pickImage();
    notifyListeners();
  }

  void setProductInfo(ProductInfo? info) {
    _productInfo = info;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> analyzeImage() async {
    if (_imageBytes == null) return null;
    final data = await OpenAIService.analyzeProductImage(_imageBytes!);
    if (data != null) {
      _productInfo = ProductInfo.fromMap(data);
      notifyListeners();
    }
    return data;
  }

  Future<void> analyze(Map<String, dynamic> userProfile) async {
    if (_purchase == null || _moodId == null) return;
    _loading = true;
    _result = null;
    notifyListeners();

    try {
      final response = await OpenAIService.analyzePurchaseDecision(
        userProfile: userProfile,
        mood: _moodId!,
        purchaseData: _purchase!.toMap(),
        productFromImage: _productInfo?.toMap(),
      );

      _result = AIResponse.fromMap(response);
    } catch (e) {
      debugPrint('Analysis error: $e');
      _result = AIResponse.fromMap(_localFallback(_purchase!.toMap(), _moodId!));
    }
    _loading = false;
    notifyListeners();
  }

  void reset() {
    _moodId = null;
    _purchase = null;
    _productInfo = null;
    _imageBytes = null;
    _result = null;
    notifyListeners();
  }

  String generateDecisionId() => const Uuid().v4();

  Map<String, dynamic> _localFallback(Map<String, dynamic> purchaseData, String mood) {
    final price = (purchaseData['price'] ?? 0).toDouble();
    return {
      'decision': price <= 100 ? 'leaning_yes' : 'wait',
      'headline': price <= 100 ? 'Looks reasonable' : 'Sleep on it',
      'message': price <= 100
          ? 'This seems like a fair treat. Make sure it fits your week.'
          : 'Give it a little time. A short pause can confirm it is worth it.',
      'costAnalysis': {
        'costPerUse': price > 0 ? '${(price / 20).toStringAsFixed(2)} per use over ~20 uses' : null,
        'trueCostNote': null,
        'affordabilityNote': 'Based on a quick gut check.',
      },
      'peerInsight': 'Most people in your mood ($mood) weigh it against their week and budget.',
      'mindsetNote': 'Trust your pace—no rush decisions.',
      'alternatives': ['Wait 48 hours', 'Check a deal alert'],
      'waitSuggestion': {
        'shouldWait': price > 150,
        'days': price > 150 ? 2 : 0,
        'reason': 'Waiting helps curb impulse buys.'
      },
      'emotionalNote': 'Be kind to yourself—treats are okay when mindful.',
      'actionItems': ['Double-check price fits your budget', 'Decide after a short walk'],
    };
  }
}
