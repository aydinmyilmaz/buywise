class DecisionQuestions {
  static const List<Map<String, dynamic>> coreQuestions = [
    {
      'id': 'productName',
      'type': 'text',
      'title': 'What are you thinking of buying?',
      'placeholder': 'e.g., iPhone 16 Pro, Vintage Jacket...',
      'icon': '🛍️',
      'required': true,
    },
    {
      'id': 'price',
      'type': 'currency',
      'title': 'How much is it?',
      'icon': '🏷️',
      'required': true,
    },
    {
      'id': 'category',
      'type': 'single_select',
      'title': 'Which category does it fall into?',
      'icon': '📂',
      'options': [
        'Tech & Gadgets',
        'Fashion & Apparel',
        'Beauty & Self-Care',
        'Home & Decor',
        'Hobbies & Gaming',
        'Travel & Experience',
        'Dining & Social',
        'Other',
      ],
    },
    {
      'id': 'emotionalState',
      'type': 'single_select',
      'title': 'How are you feeling right now?',
      'subtitle': 'Be honest—emotions drive 80% of purchases.',
      'icon': '❤️',
      'options': [
        'Calm & Rational',
        'Excited / Euphoric',
        'Stressed / Anxious',
        'Bored / Lonely',
        'Sad / Down',
        'Tired / Exhausted',
        'Hungry (literally)',
      ],
    },
    {
      'id': 'wantDuration',
      'type': 'single_select',
      'title': 'How long have you been wanting this?',
      'icon': '⏳',
      'options': [
        'Just saw it today (Impulse)',
        'Thinking about it for 24 hours',
        'A few days',
        'Over a week',
        'Over a month',
        '6+ months (Long-term goal)',
      ],
    },
  ];

  static const List<Map<String, dynamic>> conditionalQuestions = [
    // MARKETING TACTICS CHECK
    {
      'id': 'marketingTactics',
      'condition': {'field': 'wantDuration', 'operator': '==', 'value': 'Just saw it today (Impulse)'},
      'type': 'multi_select',
      'title': 'Is there any pressure to buy NOW?',
      'subtitle': 'Marketing often creates false urgency.',
      'icon': '📢',
      'options': [
        'Limited time offer / Countdown timer',
        'Low stock warning ("Only 2 left!")',
        'Flash sale / Black Friday',
        'Influencer recommended it',
        'Free shipping threshold',
        'No, just my own desire',
      ],
    },

    // UTILITY & SUBSTITUTION
    {
      'id': 'substitution',
      'condition': {'field': 'price', 'operator': '>', 'value': 50},
      'type': 'single_select',
      'title': 'Do you already own something similar?',
      'icon': '🔄',
      'options': [
        'Yes, and it works fine',
        'Yes, but this is an upgrade',
        'Yes, but I want variety',
        'No, I have nothing like this',
        'No, this replaces a broken item',
      ],
    },

    // FINANCIAL IMPACT & OPPORTUNITY COST
    {
      'id': 'laborCost',
      'condition': {'field': 'price', 'operator': '>', 'value': 100},
      'type': 'single_select',
      'title': 'Is it worth the work hours?',
      'subtitle': 'Think about how much you earn per hour.',
      'icon': '💼',
      'options': [
        'Yes, it\'s worth the grind',
        'It feels expensive for the effort',
        'I haven\'t thought about it that way',
        'It\'s a gift / using savings',
      ],
    },
    {
      'id': 'opportunityCost',
      'condition': {'field': 'price', 'operator': '>', 'value': 200},
      'type': 'single_select',
      'title': 'What else could you do with this money?',
      'icon': '💸',
      'options': [
        'Invest it / Save for a bigger goal',
        'Pay off debt',
        'Experience/Trip with friends',
        'Nothing specific',
      ],
    },

    // SOCIAL INFLUENCE
    {
      'id': 'socialProof',
      'condition': {'field': 'category', 'operator': 'in', 'value': ['Fashion & Apparel', 'Tech & Gadgets', 'Travel & Experience']},
      'type': 'single_select',
      'title': 'Who is this purchase really for?',
      'icon': '👀',
      'options': [
        '100% for me and my utility',
        'To impress others / fit in',
        'To post on social media',
        'A mix of me and others',
      ],
    },

    // USAGE REALITY CHECK
    {
      'id': 'usageReality',
      'condition': {'field': 'category', 'operator': '!=', 'value': 'Travel & Experience'},
      'type': 'single_select',
      'title': 'Where will this be in 6 months?',
      'icon': '📅',
      'options': [
        'Used daily/weekly',
        'Used occasionally',
        'Gathering dust in a closet',
        'Resold or given away',
      ],
    },
    
    // AFFORDABILITY - REFINED
    {
      'id': 'affordability',
      'condition': {'field': 'price', 'operator': '>', 'value': 30},
      'type': 'single_select',
      'title': 'The Affordability Test',
      'subtitle': 'Rule of thumb: If you can\'t buy it twice conveniently, you can\'t afford it once.',
      'icon': '💳',
      'options': [
        '✅ Safe: I could buy 3 of these with cash right now',
        '⚠️ Okay: I can pay in full, but it takes a chunk of cash',
        '😨 Stretch: I\'d have to dip into emergency savings',
        '🛑 Debt: putting it on credit / payment plan',
      ],
    },

    // MENTAL WELLBEING
    {
      'id': 'postPurchaseFeel',
      'condition': {'field': 'emotionalState', 'operator': 'in', 'value': ['Stressed / Anxious', 'Sad / Down', 'Bored / Lonely']},
      'type': 'single_select',
      'title': 'Will buying this fix your current mood?',
      'icon': '🧠',
      'options': [
        'No, it\'s a temporary distraction',
        'Maybe for a few hours',
        'Yes, it solves the root problem',
        'I don\'t know',
      ],
    },
    
    // FINAL CHECK
    {
      'id': 'waitRule',
      'condition': {'field': 'wantDuration', 'operator': 'in', 'value': ['Just saw it today (Impulse)', 'Thinking about it for 24 hours']},
      'type': 'single_select',
      'title': 'The 72-Hour Rule Check',
      'subtitle': 'Most impulses fade after 3 days. Can you wait?',
      'icon': '🛑',
      'options': [
        'I will wait 72 hours to decide',
        'I can\'t wait (Risk of regret)',
        'I\'ve already waited enough',
      ],
    },
  ];

  // Manual entry questions are now merged into Core for smoother flow
  static const List<Map<String, dynamic>> manualEntryQuestions = []; 
}
