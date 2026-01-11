import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get openAIApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get openAIBaseUrl => dotenv.env['OPENAI_BASE_URL'] ?? 'https://api.openai.com/v1';
}
