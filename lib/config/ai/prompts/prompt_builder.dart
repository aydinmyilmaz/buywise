class PromptBuilder {
  static String buildAnalysisPrompt({
    required Map<String, dynamic> userProfile,
    required String mood,
    required Map<String, dynamic> purchaseData,
    Map<String, dynamic>? productFromImage,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('=== USER PROFILE ===');
    buffer.writeln('Age Group: ${userProfile['ageGroup']}');
    buffer.writeln('Spending Style: ${userProfile['spendingStyle']}');
    buffer.writeln('Has Fun Budget: ${userProfile['hasFunBudget']}');
    buffer.writeln('Spending Guilt Level: ${userProfile['spendingGuilt']}');
    buffer.writeln('Last Self-Purchase: ${userProfile['lastSelfPurchase']}');
    buffer.writeln('Decision Style: ${userProfile['decisionStyle']}');
    buffer.writeln('Preferred Wait Time: ${userProfile['preferredWaitTime']}');
    buffer.writeln('');

    buffer.writeln('=== CURRENT STATE ===');
    buffer.writeln('Mood: $mood');
    buffer.writeln('');

    buffer.writeln('=== PURCHASE DETAILS ===');

    if (productFromImage != null) {
      buffer.writeln('Product (from image): ${productFromImage['productName']}');
      buffer.writeln('Brand: ${productFromImage['brand'] ?? 'Unknown'}');
      buffer.writeln('Category: ${productFromImage['category']}');
      buffer.writeln('Quality Tier: ${productFromImage['qualityTier']}');
      if (productFromImage['features'] != null) {
        buffer.writeln('Features: ${(productFromImage['features'] as List).join(', ')}');
      }
    } else {
      buffer.writeln('Product: ${purchaseData['productName']}');
      buffer.writeln('Category: ${purchaseData['category']}');
    }

    buffer.writeln('Price: ${purchaseData['price']} ${purchaseData['currency']}');
    buffer.writeln('How Long Wanted: ${purchaseData['wantDuration']}');
    buffer.writeln('Reasons: ${(purchaseData['reasons'] as List?)?.join(', ') ?? purchaseData['reason']}');

    if (purchaseData['additionalCosts'] != null) {
      buffer.writeln('Expected Additional Costs: ${(purchaseData['additionalCosts'] as List).join(', ')}');
    }

    if (purchaseData['affordabilityLevel'] != null) {
      buffer.writeln('Affordability: ${purchaseData['affordabilityLevel']}');
    }

    if (purchaseData['usageFrequency'] != null) {
      buffer.writeln('Expected Usage: ${purchaseData['usageFrequency']}');
    }

    if (purchaseData['isEmotionalBuy'] != null) {
      buffer.writeln('Emotional Factor: ${purchaseData['isEmotionalBuy']}');
    }

    if (purchaseData['hasCheckedDeals'] != null) {
      buffer.writeln('Deal Status: ${purchaseData['hasCheckedDeals']}');
    }

    if (purchaseData['necessity'] != null) {
      buffer.writeln('Necessity Level: ${purchaseData['necessity']}');
    }

    if (purchaseData['utility'] != null) {
      buffer.writeln('Self-Reported Utility: ${purchaseData['utility']}');
    }

    if (purchaseData['sentiment'] != null) {
      buffer.writeln('User Sentiment: ${purchaseData['sentiment']}');
    }

    if (purchaseData['resaleValue'] != null) {
      buffer.writeln('Expected Resale Value: ${purchaseData['resaleValue']}');
    }

    buffer.writeln('');
    buffer.writeln('Based on all this information, provide your analysis as JSON.');

    return buffer.toString();
  }
}
