class DecisionRecord {
  final String id;
  final String productName;
  final double price;
  final String currency;
  final String decision;
  final String headline;
  final DateTime createdAt;

  DecisionRecord({
    required this.id,
    required this.productName,
    required this.price,
    required this.currency,
    required this.decision,
    required this.headline,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'price': price,
      'currency': currency,
      'decision': decision,
      'headline': headline,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DecisionRecord.fromMap(Map<String, dynamic> map) {
    return DecisionRecord(
      id: map['id'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'USD',
      decision: map['decision'] ?? 'wait',
      headline: map['headline'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
