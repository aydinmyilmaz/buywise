class UserProfile {
  final String gender;
  final String country;
  final String currency;
  final String ageGroup;
  final String spendingStyle;
  final String hasFunBudget;
  final double? funBudgetAmount; // Monthly fun budget amount
  final String spendingGuilt;
  final String lastSelfPurchase;
  final String decisionStyle;
  final String preferredWaitTime;
  final String monthlyIncome;
  final String primaryGoal;

  const UserProfile({
    required this.gender,
    required this.country,
    required this.currency,
    required this.ageGroup,
    required this.spendingStyle,
    required this.hasFunBudget,
    this.funBudgetAmount,
    required this.spendingGuilt,
    required this.lastSelfPurchase,
    required this.decisionStyle,
    required this.preferredWaitTime,
    required this.monthlyIncome,
    required this.primaryGoal,
  });

  Map<String, dynamic> toMap() {
    return {
      'gender': gender,
      'country': country,
      'currency': currency,
      'ageGroup': ageGroup,
      'spendingStyle': spendingStyle,
      'hasFunBudget': hasFunBudget,
      'funBudgetAmount': funBudgetAmount,
      'spendingGuilt': spendingGuilt,
      'lastSelfPurchase': lastSelfPurchase,
      'decisionStyle': decisionStyle,
      'preferredWaitTime': preferredWaitTime,
      'monthlyIncome': monthlyIncome,
      'primaryGoal': primaryGoal,
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
      funBudgetAmount: map['funBudgetAmount'] != null
          ? (map['funBudgetAmount'] as num).toDouble()
          : null,
      spendingGuilt: map['spendingGuilt'] ?? '',
      lastSelfPurchase: map['lastSelfPurchase'] ?? '',
      decisionStyle: map['decisionStyle'] ?? '',
      preferredWaitTime: map['preferredWaitTime'] ?? '',
      monthlyIncome: map['monthlyIncome'] ?? '',
      primaryGoal: map['primaryGoal'] ?? '',
    );
  }
}
