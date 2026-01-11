class DecisionQuestions {
  static const List<Map<String, dynamic>> coreQuestions = [
    {
      'id': 'price',
      'type': 'currency',
      'title': 'How much does it cost?',
      'icon': '💰',
      'required': true,
    },
    {
      'id': 'wantDuration',
      'type': 'single_select',
      'title': 'How long have you been wanting this?',
      'icon': '⏰',
      'options': [
        'Just discovered it today',
        'A few days',
        '1-2 weeks',
        'About a month',
        'Several months',
        'Over a year',
      ],
    },
    {
      'id': 'reasons',
      'type': 'multi_select',
      'title': 'Why do you want this?',
      'subtitle': 'Select all that apply',
      'icon': '✨',
      'options': [
        'It will make me happy',
        'It\'s practical / useful',
        'It supports a hobby',
        'It\'s for self-care',
        'It will save me time',
        'Upgrade from what I have',
        'Social pressure / everyone has it',
        'It\'s on sale',
        'No specific reason - I just want it',
      ],
    },
  ];

  static const List<Map<String, dynamic>> conditionalQuestions = [
    {
      'id': 'additionalCosts',
      'condition': {'field': 'price', 'operator': '>', 'value': 100},
      'type': 'multi_select',
      'title': 'Will this have additional costs?',
      'icon': '💸',
      'options': [
        'Accessories needed',
        'Maintenance / refills',
        'Subscription fees',
        'Insurance / warranty',
        'None that I know of',
      ],
    },
    {
      'id': 'affordabilityLevel',
      'condition': {'field': 'price', 'operator': '>', 'value': 200},
      'type': 'single_select',
      'title': 'Honestly, how comfortable is this purchase?',
      'icon': '🏦',
      'options': [
        'Very - I could buy this 3+ times',
        'Comfortable - I can afford it twice',
        'Fine - I can afford it once',
        'Stretch - but manageable',
      ],
    },
    {
      'id': 'usageFrequency',
      'condition': {'field': 'price', 'operator': '>', 'value': 100},
      'type': 'single_select',
      'title': 'How often would you use this?',
      'icon': '📅',
      'options': [
        'Daily',
        'Several times a week',
        'Weekly',
        'A few times a month',
        'Occasionally',
      ],
    },
    {
      'id': 'willingToWait',
      'condition': {'field': 'wantDuration', 'operator': '==', 'value': 'Just discovered it today'},
      'type': 'single_select',
      'title': 'Would you be okay waiting a bit to decide?',
      'icon': '⏳',
      'options': [
        'Yes, I\'ll wait 48 hours',
        'Yes, I\'ll wait a week',
        'I\'d rather decide now',
        'It\'s on sale - need to decide quickly',
      ],
    },
    {
      'id': 'hasCheckedDeals',
      'condition': {'field': 'price', 'operator': '>', 'value': 50},
      'type': 'single_select',
      'title': 'Have you checked for a better price?',
      'icon': '🔍',
      'options': [
        'Yes, this is the best price',
        'Not yet - I should look around',
        'It\'s already on sale',
      ],
    },
  ];

  static const List<Map<String, dynamic>> manualEntryQuestions = [
    {
      'id': 'productName',
      'type': 'text',
      'title': 'What\'s the product?',
      'placeholder': 'e.g., Dyson Airwrap, Nike Air Max 90...',
      'icon': '📝',
      'required': true,
    },
    {
      'id': 'category',
      'type': 'single_select',
      'title': 'What category is this?',
      'icon': '🏷️',
      'options': [
        'Beauty & Self-care',
        'Fashion & Accessories',
        'Tech & Gadgets',
        'Home & Living',
        'Health & Fitness',
        'Hobbies & Entertainment',
        'Travel & Experiences',
        'Other',
      ],
    },
  ];
}
