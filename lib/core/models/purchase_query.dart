class PurchaseQuery {
  final String productName;
  final String category;
  final double price;
  final String currency;
  final List<String> reasons;
  final String wantDuration;
  final List<String>? additionalCosts;
  final String? affordabilityLevel;
  final String? usageFrequency;
  final String? willingToWait;
  final String? hasCheckedDeals;

  PurchaseQuery({
    required this.productName,
    required this.category,
    required this.price,
    required this.currency,
    required this.reasons,
    required this.wantDuration,
    this.additionalCosts,
    this.affordabilityLevel,
    this.usageFrequency,
    this.willingToWait,
    this.hasCheckedDeals,
  });

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'category': category,
      'price': price,
      'currency': currency,
      'reasons': reasons,
      'wantDuration': wantDuration,
      'additionalCosts': additionalCosts,
      'affordabilityLevel': affordabilityLevel,
      'usageFrequency': usageFrequency,
      'willingToWait': willingToWait,
      'hasCheckedDeals': hasCheckedDeals,
    };
  }
}
