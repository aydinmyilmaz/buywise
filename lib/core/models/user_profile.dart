class UserProfile {
  final String gender;
  final String country;
  final String currency;
  final String ageGroup;
  final String spendingStyle;
  final String hasFunBudget;
  final String spendingGuilt;
  final String lastSelfPurchase;
  final String decisionStyle;
  final String preferredWaitTime;

  const UserProfile({
    required this.gender,
    required this.country,
    required this.currency,
    required this.ageGroup,
    required this.spendingStyle,
    required this.hasFunBudget,
    required this.spendingGuilt,
    required this.lastSelfPurchase,
    required this.decisionStyle,
    required this.preferredWaitTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'gender': gender,
      'country': country,
      'currency': currency,
      'ageGroup': ageGroup,
      'spendingStyle': spendingStyle,
      'hasFunBudget': hasFunBudget,
      'spendingGuilt': spendingGuilt,
      'lastSelfPurchase': lastSelfPurchase,
      'decisionStyle': decisionStyle,
      'preferredWaitTime': preferredWaitTime,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      gender: map['gender'] ?? 'neutral',
      country: map['country'] ?? 'United States',
      currency: map['currency'] ?? 'USD',
      ageGroup: map['ageGroup'] ?? '',
      spendingStyle: map['spendingStyle'] ?? '',
      hasFunBudget: map['hasFunBudget'] ?? '',
      spendingGuilt: map['spendingGuilt'] ?? '',
      lastSelfPurchase: map['lastSelfPurchase'] ?? '',
      decisionStyle: map['decisionStyle'] ?? '',
      preferredWaitTime: map['preferredWaitTime'] ?? '',
    );
  }
}
