class AIConfig {
  static const String chatModel = 'gpt-4o-mini';
  static const String visionModel = 'gpt-4o-mini';

  static const double temperature = 0.7;
  static const int maxTokens = 1200;
  static const int visionMaxTokens = 500;

  static const Duration requestTimeout = Duration(seconds: 45);
  static const Duration visionTimeout = Duration(seconds: 30);

  static const int maxImageWidth = 1024;
  static const int imageQuality = 85;
  static const String imageDetail = 'low';
}
