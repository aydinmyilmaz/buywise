class ProductInfo {
  final String productName;
  final String? brand;
  final String category;
  final String qualityTier;
  final List<String>? features;
  final Map<String, dynamic>? estimatedPrice;
  final double confidence;

  ProductInfo({
    required this.productName,
    required this.category,
    required this.qualityTier,
    required this.confidence,
    this.brand,
    this.features,
    this.estimatedPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'brand': brand,
      'category': category,
      'qualityTier': qualityTier,
      'features': features,
      'estimatedPrice': estimatedPrice,
      'confidence': confidence,
    };
  }

  factory ProductInfo.fromMap(Map<String, dynamic> map) {
    return ProductInfo(
      productName: map['productName'] ?? '',
      brand: map['brand'],
      category: map['category'] ?? 'Other',
      qualityTier: map['qualityTier'] ?? 'budget',
      features: (map['features'] as List?)?.map((e) => e.toString()).toList(),
      estimatedPrice: map['estimatedPrice'] as Map<String, dynamic>?,
      confidence: (map['confidence'] ?? 0).toDouble(),
    );
  }
}
