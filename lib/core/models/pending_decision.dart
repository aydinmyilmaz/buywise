class PendingDecision {
  final String id;
  final String productName;
  final double price;
  final String currency;
  final String decision;
  final DateTime waitUntil;
  final DateTime createdAt;

  PendingDecision({
    required this.id,
    required this.productName,
    required this.price,
    required this.currency,
    required this.decision,
    required this.waitUntil,
    required this.createdAt,
  });

  bool get isReady {
    return DateTime.now().isAfter(waitUntil);
  }

  int get hoursRemaining {
    final diff = waitUntil.difference(DateTime.now());
    return diff.inHours;
  }

  String get timeRemainingText {
    final diff = waitUntil.difference(DateTime.now());
    if (diff.isNegative) return 'Ready to reconsider';

    final days = diff.inDays;
    if (days > 0) return '$days day${days > 1 ? 's' : ''} left';

    final hours = diff.inHours;
    if (hours > 0) return '$hours hour${hours > 1 ? 's' : ''} left';

    final minutes = diff.inMinutes;
    return '$minutes min${minutes > 1 ? 's' : ''} left';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'price': price,
      'currency': currency,
      'decision': decision,
      'waitUntil': waitUntil.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PendingDecision.fromMap(Map<String, dynamic> map) {
    return PendingDecision(
      id: map['id'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'USD',
      decision: map['decision'] ?? 'wait',
      waitUntil: DateTime.tryParse(map['waitUntil'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
