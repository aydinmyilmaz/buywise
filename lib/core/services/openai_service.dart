import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../config/ai/ai_config.dart';
import '../../config/ai/prompts/system_prompt.dart';
import '../../config/ai/prompts/vision_prompt.dart';
import '../../config/ai/prompts/prompt_builder.dart';
import '../../config/env_config.dart';

class OpenAIService {
  static final _client = http.Client();

  static Map<String, String> get _headers => {
        'Authorization': 'Bearer ${EnvConfig.openAIApiKey}',
        'Content-Type': 'application/json',
      };

  static Future<Map<String, dynamic>?> analyzeProductImage(Uint8List imageBytes) async {
    if (EnvConfig.openAIApiKey.isEmpty) return null;
    try {
      final base64Image = base64Encode(imageBytes);

      final response = await _client
          .post(
            Uri.parse('${EnvConfig.openAIBaseUrl}/chat/completions'),
            headers: _headers,
            body: jsonEncode({
              'model': AIConfig.visionModel,
              'max_tokens': AIConfig.visionMaxTokens,
              'messages': [
                {
                  'role': 'user',
                  'content': [
                    {'type': 'text', 'text': VisionPrompt.analyzeProduct},
                    {
                      'type': 'image_url',
                      'image_url': {
                        'url': 'data:image/jpeg;base64,$base64Image',
                        'detail': AIConfig.imageDetail,
                      },
                    },
                  ],
                },
              ],
            }),
          )
          .timeout(AIConfig.visionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
        if (jsonMatch != null) {
          return jsonDecode(jsonMatch.group(0)!);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Vision API Error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> analyzePurchaseDecision({
    required Map<String, dynamic> userProfile,
    required String mood,
    required Map<String, dynamic> purchaseData,
    Map<String, dynamic>? productFromImage,
  }) async {
    if (EnvConfig.openAIApiKey.isEmpty) {
      return _fallbackDecision(purchaseData, mood);
    }

    final systemPrompt = SystemPrompt.build(
      gender: userProfile['gender'] ?? 'neutral',
      country: userProfile['country'] ?? 'United States',
      currency: userProfile['currency'] ?? 'USD',
    );

    final userPrompt = PromptBuilder.buildAnalysisPrompt(
      userProfile: userProfile,
      mood: mood,
      purchaseData: purchaseData,
      productFromImage: productFromImage,
    );

    final response = await _client
        .post(
          Uri.parse('${EnvConfig.openAIBaseUrl}/chat/completions'),
          headers: _headers,
          body: jsonEncode({
            'model': AIConfig.chatModel,
            'max_tokens': AIConfig.maxTokens,
            'temperature': AIConfig.temperature,
            'response_format': {'type': 'json_object'},
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': userPrompt},
            ],
          }),
        )
        .timeout(AIConfig.requestTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'] as String;
      return jsonDecode(content) as Map<String, dynamic>;
    }

    throw Exception('OpenAI API Error: ${response.statusCode} - ${response.body}');
  }

  static Map<String, dynamic> _fallbackDecision(Map<String, dynamic> purchaseData, String mood) {
    final price = (purchaseData['price'] ?? 0).toDouble();
    final currency = purchaseData['currency'] ?? 'USD';
    return {
      'decision': price <= 100 ? 'leaning_yes' : 'wait',
      'headline': price <= 100 ? 'Looks reasonable' : 'Sleep on it',
      'message':
          price <= 100 ? 'This seems like a fair treat. Make sure it fits your week.' : 'Give it a little time. A short pause can confirm it is worth it.',
      'costAnalysis': {
        'costPerUse': price > 0 ? '${(price / 20).toStringAsFixed(2)} per use over ~20 uses' : null,
        'trueCostNote': null,
        'affordabilityNote': 'Based on a quick gut check.',
      },
      'peerInsight': 'Most people in your mood ($mood) weigh it against their week and budget.',
      'mindsetNote': 'Trust your pace—no rush decisions.',
      'alternatives': ['Wait 48 hours', 'Check a deal alert'],
      'waitSuggestion': {'shouldWait': price > 150, 'days': price > 150 ? 2 : 0, 'reason': 'Waiting helps curb impulse buys.'},
      'emotionalNote': 'Be kind to yourself—treats are okay when mindful.',
      'actionItems': ['Double-check price fits your budget', 'Decide after a short walk'],
    };
  }
}
