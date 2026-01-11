class WaitTimer {
  final int days;
  final DateTime createdAt;

  WaitTimer({required this.days, required this.createdAt});

  Map<String, dynamic> toMap() => {
        'days': days,
        'createdAt': createdAt.toIso8601String(),
      };

  factory WaitTimer.fromMap(Map<String, dynamic> map) {
    return WaitTimer(
      days: map['days'] ?? 0,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
