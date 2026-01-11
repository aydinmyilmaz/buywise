import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../config/env_config.dart';

class QuestionGeneratorService {
  static final _client = http.Client();

  static Map<String, String> get _headers => {
        'Authorization': 'Bearer ${EnvConfig.openAIApiKey}',
        'Content-Type': 'application/json',
      };

  /// Generates dynamic, context-aware questions based on product details
  static Future<List<Map<String, dynamic>>> generateQuestions({
    required String productName,
    required String category,
    required double price,
    required String currency,
    required Map<String, dynamic> userProfile,
  }) async {
    if (EnvConfig.openAIApiKey.isEmpty) {
      return _getFallbackQuestions();
    }

    try {
      final systemPrompt = _buildSystemPrompt();
      final userPrompt = _buildUserPrompt(
        productName: productName,
        category: category,
        price: price,
        currency: currency,
        userProfile: userProfile,
      );

      final response = await _client
          .post(
            Uri.parse('${EnvConfig.openAIBaseUrl}/chat/completions'),
            headers: _headers,
            body: jsonEncode({
              'model': 'gpt-4o-mini',
              'max_tokens': 2000,
              'temperature': 0.7,
              'response_format': {'type': 'json_object'},
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': userPrompt},
              ],
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        final result = jsonDecode(content) as Map<String, dynamic>;

        return (result['questions'] as List<dynamic>)
            .map((q) => q as Map<String, dynamic>)
            .toList();
      }

      debugPrint('Question Generator API Error: ${response.statusCode}');
      return _getFallbackQuestions();
    } catch (e) {
      debugPrint('Question Generator Error: $e');
      return _getFallbackQuestions();
    }
  }

  static String _buildSystemPrompt() {
    return '''You are an expert behavioral economics advisor specializing in purchase decisions. Your role is to generate personalized, contextually-relevant questions that help users make better buying decisions.

CRITICAL REQUIREMENTS:
1. Generate 5-8 questions specifically tailored to the product type, category, and price level
2. Questions should be insightful, psychology-based, and help reveal hidden motivations
3. Each question must be actionable and directly related to the specific product
4. Mix question types appropriately (single_select and multi_select)
5. Use behavioral economics principles: loss aversion, sunk cost, opportunity cost, social proof, etc.

QUESTION STRUCTURE:
Each question MUST include:
- id: unique snake_case identifier (e.g., "warranty_consideration", "fit_concerns")
- type: either "single_select" or "multi_select"
- title: The main question (clear, conversational, thought-provoking)
- subtitle: Optional context or psychology insight (e.g., "Most people overestimate usage by 3x")
- icon: Single emoji representing the question theme
- options: Array of 3-6 answer choices (clear, realistic, covering key scenarios)

QUESTION FOCUS AREAS BY CATEGORY:
- Tech & Gadgets: compatibility, warranty, obsolescence, existing devices, upgrade necessity
- Fashion & Apparel: fit, return policy, versatility, seasonal wear, wardrobe gaps
- Beauty & Self-Care: skin compatibility, usage frequency, existing products, ingredient concerns
- Home & Decor: space constraints, durability, maintenance, aesthetic fit, storage
- Hobbies & Gaming: skill level, time commitment, multiplayer needs, existing gear
- Travel & Experience: timing, weather, companions, alternatives, memory value
- Dining & Social: occasion frequency, dietary needs, convenience vs quality

PRICE-LEVEL ADJUSTMENTS:
- Under $50: Focus on necessity, alternatives, immediate regret potential
- $50-$200: Add questions about payment method, monthly budget impact, cost-per-use
- $200-$500: Include opportunity cost, waiting period willingness, resale value
- Over $500: Deep dive into affordability, financing concerns, long-term value, status motivations

OUTPUT FORMAT:
Return a JSON object with a "questions" array. Each question follows the structure above.

EXAMPLE OUTPUT:
{
  "questions": [
    {
      "id": "warranty_value",
      "type": "single_select",
      "title": "How important is warranty coverage for this device?",
      "subtitle": "Extended warranties often cost more than repairs",
      "icon": "🛡️",
      "options": [
        "Essential - I need peace of mind",
        "Nice to have, but not critical",
        "Not important - I'll handle repairs myself",
        "Haven't thought about it"
      ]
    }
  ]
}''';
  }

  static String _buildUserPrompt({
    required String productName,
    required String category,
    required double price,
    required String currency,
    required Map<String, dynamic> userProfile,
  }) {
    final priceRange = price < 50
        ? 'budget-friendly'
        : price < 200
            ? 'mid-range'
            : price < 500
                ? 'significant'
                : 'high-value';

    return '''Generate personalized purchase decision questions for this specific product:

PRODUCT DETAILS:
- Product: $productName
- Category: $category
- Price: $price $currency ($priceRange purchase)

USER CONTEXT:
- Country: ${userProfile['country'] ?? 'Unknown'}
- Monthly Income: ${userProfile['monthlyIncome'] ?? 'Unknown'}
- Primary Goal: ${userProfile['primaryGoal'] ?? 'Unknown'}
- Currency: ${userProfile['currency'] ?? 'USD'}

INSTRUCTIONS:
1. Analyze the specific product name to understand what it is (brand, model, type)
2. Generate 5-8 questions that are HIGHLY SPECIFIC to this exact product and price point
3. Don't ask generic questions - make them contextual and revealing
4. Include at least one question about:
   - Practical utility (will they actually use it?)
   - Financial impact (can they comfortably afford it?)
   - Emotional motivation (why now? why this specific product?)
   - Alternatives or substitutes (what else could work?)
5. For expensive items ($200+), include questions about:
   - Payment method and affordability
   - Opportunity cost (what else could this money do?)
   - Waiting period willingness
6. Make questions conversational and thought-provoking
7. Use psychology principles to help users discover their true motivations

Generate the questions now in JSON format.''';
  }

  /// Fallback questions if API fails or is unavailable
  static List<Map<String, dynamic>> _getFallbackQuestions() {
    return [
      {
        'id': 'emotional_state',
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
        ],
      },
      {
        'id': 'want_duration',
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
      {
        'id': 'usage_reality',
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
      {
        'id': 'affordability',
        'type': 'single_select',
        'title': 'The Affordability Test',
        'subtitle':
            'Rule of thumb: If you can\'t buy it twice conveniently, you can\'t afford it once.',
        'icon': '💳',
        'options': [
          '✅ Safe: I could buy 3 of these with cash right now',
          '⚠️ Okay: I can pay in full, but it takes a chunk of cash',
          '😨 Stretch: I\'d have to dip into emergency savings',
          '🛑 Debt: putting it on credit / payment plan',
        ],
      },
      {
        'id': 'wait_rule',
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
  }
}
