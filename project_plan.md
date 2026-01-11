# ShouldIBuyThis — Complete Vibe Coding Assistant Guide
## Master Prompt & Implementation Blueprint

---

# 🎯 PROJECT OVERVIEW

Build a Flutter mobile app called **"ShouldIBuyThis"** that helps people (especially those who struggle with spending guilt) make purchase decisions using AI-powered analysis.

## Core Concept
- User uploads a product image OR enters product details
- App asks smart, conditional questions
- AI (OpenAI GPT-5-mini) analyzes and gives personalized recommendation
- Tone is warm, supportive, never judgmental

## Key Principles
1. **Config-Driven**: ALL colors, strings, prompts, questions in separate config files
2. **No Backend**: Pure Flutter + direct OpenAI API calls
3. **Dual Theme**: Feminine (pink/purple) and Masculine (blue/cyan) themes
4. **Image Intelligence**: GPT Vision extracts product info from photos
5. **Empathetic AI**: Understands spending psychology and guilt patterns

---

# 📁 PROJECT STRUCTURE

Create this exact folder structure:

```
lib/
├── main.dart
├── app.dart
│
├── config/                              # ⭐ ALL CONFIGURABLE VALUES
│   ├── ai/
│   │   ├── ai_config.dart              # Model names, API settings
│   │   └── prompts/
│   │       ├── system_prompt.dart      # AI personality & rules
│   │       ├── vision_prompt.dart      # Image analysis prompt
│   │       └── prompt_builder.dart     # Builds final prompts
│   │
│   ├── theme/
│   │   ├── color_tokens.dart           # All color definitions
│   │   ├── typography_tokens.dart      # Font sizes, weights
│   │   ├── spacing_tokens.dart         # Padding, margins, radius
│   │   └── theme_config.dart           # Builds ThemeData
│   │
│   ├── content/
│   │   ├── onboarding_questions.dart   # Profile survey (one-time)
│   │   ├── decision_questions.dart     # Per-purchase questions
│   │   ├── mood_options.dart           # Mood choices
│   │   ├── categories.dart             # Purchase categories
│   │   ├── countries.dart              # Country + currency list
│   │   └── strings.dart                # All UI text
│   │
│   ├── app_config.dart                 # App-wide settings
│   └── env_config.dart                 # API keys loader
│
├── core/
│   ├── services/
│   │   ├── openai_service.dart         # Chat + Vision API
│   │   ├── storage_service.dart        # SharedPreferences wrapper
│   │   ├── image_service.dart          # Pick + compress images
│   │   └── notification_service.dart   # Wait timer reminders
│   │
│   ├── models/
│   │   ├── user_profile.dart           # Onboarding data model
│   │   ├── mood.dart                   # Mood enum
│   │   ├── purchase_query.dart         # Current decision data
│   │   ├── product_info.dart           # From image analysis
│   │   ├── ai_response.dart            # AI recommendation
│   │   ├── decision_record.dart        # History item
│   │   └── wait_timer.dart             # Pending decision
│   │
│   ├── providers/
│   │   ├── theme_provider.dart         # Theme state
│   │   ├── user_provider.dart          # User profile state
│   │   ├── decision_provider.dart      # Current decision state
│   │   └── history_provider.dart       # Past decisions
│   │
│   └── utils/
│       ├── currency_formatter.dart
│       └── date_formatter.dart
│
├── features/
│   ├── onboarding/
│   │   ├── screens/
│   │   │   ├── splash_screen.dart
│   │   │   ├── welcome_screen.dart
│   │   │   ├── gender_screen.dart
│   │   │   └── survey_screen.dart
│   │   └── widgets/
│   │       ├── survey_progress.dart
│   │       └── gender_card.dart
│   │
│   ├── home/
│   │   ├── screens/
│   │   │   └── home_screen.dart
│   │   └── widgets/
│   │       ├── greeting_card.dart
│   │       ├── new_decision_button.dart
│   │       └── recent_decisions.dart
│   │
│   ├── decision/
│   │   ├── screens/
│   │   │   ├── mood_screen.dart
│   │   │   ├── product_input_screen.dart
│   │   │   ├── questions_screen.dart
│   │   │   ├── analyzing_screen.dart
│   │   │   └── result_screen.dart
│   │   └── widgets/
│   │       ├── mood_selector.dart
│   │       ├── image_upload_card.dart
│   │       ├── question_card.dart
│   │       ├── currency_input.dart
│   │       ├── select_option.dart
│   │       ├── multi_select.dart
│   │       ├── result_header.dart
│   │       ├── cost_analysis_card.dart
│   │       ├── peer_insight_card.dart
│   │       ├── alternatives_card.dart
│   │       ├── wait_timer_card.dart
│   │       └── action_items_card.dart
│   │
│   ├── history/
│   │   ├── screens/
│   │   │   └── history_screen.dart
│   │   └── widgets/
│   │       └── history_item.dart
│   │
│   └── settings/
│       ├── screens/
│       │   ├── settings_screen.dart
│       │   └── edit_profile_screen.dart
│       └── widgets/
│           └── settings_tile.dart
│
└── shared/
    └── widgets/
        ├── app_button.dart
        ├── app_text_field.dart
        ├── app_card.dart
        ├── gradient_button.dart
        ├── loading_overlay.dart
        └── error_dialog.dart
```

---

# ⚙️ CONFIG FILES — IMPLEMENT THESE FIRST

## 1. config/env_config.dart
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get openAIApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get openAIBaseUrl => dotenv.env['OPENAI_BASE_URL'] ?? 'https://api.openai.com/v1';
}
```

## 2. config/ai/ai_config.dart
```dart
class AIConfig {
  // Models
  static const String chatModel = 'gpt-4o-mini';
  static const String visionModel = 'gpt-4o-mini';
  
  // Parameters
  static const double temperature = 0.7;
  static const int maxTokens = 1200;
  static const int visionMaxTokens = 500;
  
  // Timeouts
  static const Duration requestTimeout = Duration(seconds: 45);
  static const Duration visionTimeout = Duration(seconds: 30);
  
  // Image
  static const int maxImageWidth = 1024;
  static const int imageQuality = 85;
  static const String imageDetail = 'low'; // 'low', 'high', 'auto'
}
```

## 3. config/ai/prompts/system_prompt.dart
```dart
class SystemPrompt {
  static String build({
    required String gender,
    required String country,
    required String currency,
  }) {
    return '''
You are a supportive, empathetic AI assistant helping people make purchase decisions.
You're like a wise, caring friend who understands spending psychology.

USER CONTEXT:
- Gender: $gender
- Country: $country  
- Currency: $currency

PERSONALITY:
- Warm and supportive, NEVER judgmental
- You understand "scarcity mindset" and spending guilt
- You know hobbies are mental health investments
- Adjust tone slightly: more nurturing for female users, more practical for male users
- Be culturally aware of spending norms in $country

PSYCHOLOGICAL FRAMEWORKS YOU APPLY:
1. "3x Rule": If they can afford it 3 times, they can truly afford it
2. "48hr/30-day Rule": New discoveries need cooling off period
3. "Cost Per Use": Calculate value over time (price ÷ expected uses)
4. "True Cost": Include accessories, maintenance, subscriptions
5. "Now or Never": Some purchases are age/time sensitive
6. "Scarcity Mindset": Recognize irrational guilt and reassure

DETECT AND ADDRESS:
- Emotional/retail therapy buying → be gentle but honest
- Scarcity mindset → reassure if they can truly afford it
- Impulse vs genuine want → suggest waiting if needed
- Self-care avoidance → encourage healthy self-investment
- Social pressure buying → help them recognize it

RESPONSE RULES:
1. NEVER say "don't buy it" harshly - always reframe positively
2. Validate their feelings FIRST before any advice
3. If emotional spending, acknowledge kindly without shaming
4. Calculate cost-per-use for items over \$100
5. Suggest alternatives when appropriate
6. End with clear, actionable next steps
7. Use their currency ($currency) in all calculations

RESPOND WITH THIS EXACT JSON STRUCTURE:
{
  "decision": "yes" | "leaning_yes" | "wait" | "leaning_no",
  "headline": "Short empowering headline (max 8 words)",
  "message": "2-3 sentences of warm, personalized advice",
  "costAnalysis": {
    "costPerUse": "X.XX per use based on Y uses/week for Z months" | null,
    "trueCostNote": "Including accessories/maintenance, total ~X" | null,
    "affordabilityNote": "Based on what you shared..." | null
  },
  "peerInsight": "What people in similar situations typically do (1-2 sentences)",
  "mindsetNote": "Observation about their spending psychology" | null,
  "alternatives": ["Alternative 1", "Alternative 2"] | null,
  "waitSuggestion": {
    "shouldWait": true | false,
    "days": 0 | 2 | 7 | 30,
    "reason": "Why waiting might help"
  } | null,
  "emotionalNote": "Gentle note about mood/self-care if relevant" | null,
  "actionItems": ["Clear action 1", "Clear action 2"]
}
''';
  }
}
```

## 4. config/ai/prompts/vision_prompt.dart
```dart
class VisionPrompt {
  static const String analyzeProduct = '''
Analyze this product image and extract information.

EXTRACT:
1. Product name/type (be specific, e.g., "Dyson Airwrap Complete")
2. Brand (if visible or recognizable)
3. Category (choose ONE):
   - Beauty & Self-care
   - Fashion & Accessories
   - Tech & Gadgets
   - Home & Living
   - Health & Fitness
   - Hobbies & Entertainment
   - Travel & Experiences
   - Food & Dining
   - Other
4. Quality tier: budget / midrange / premium / luxury
5. Key features you can identify
6. Estimated price range (if you can tell)

RESPOND WITH THIS EXACT JSON:
{
  "productName": "Full product name",
  "brand": "Brand name" | null,
  "category": "Category from list above",
  "qualityTier": "budget" | "midrange" | "premium" | "luxury",
  "features": ["feature 1", "feature 2"],
  "estimatedPrice": {"min": 0, "max": 0, "currency": "USD"} | null,
  "confidence": 0.0 to 1.0
}
''';
}
```

## 5. config/ai/prompts/prompt_builder.dart
```dart
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
    
    buffer.writeln('');
    buffer.writeln('Based on all this information, provide your analysis as JSON.');
    
    return buffer.toString();
  }
}
```

## 6. config/theme/color_tokens.dart
```dart
import 'package:flutter/material.dart';

class ColorTokens {
  // ========== FEMININE PALETTE ==========
  static const femininePrimary = Color(0xFFEC4899);       // pink-500
  static const feminineSecondary = Color(0xFFA855F7);     // purple-500
  static const feminineBackground = Color(0xFFFDF2F8);    // pink-50
  static const feminineSurface = Color(0xFFFFFFFF);
  static const feminineGradientStart = Color(0xFFEC4899);
  static const feminineGradientEnd = Color(0xFFA855F7);
  static const feminineBorder = Color(0xFFFCE7F3);        // pink-100
  static const feminineBorderFocus = Color(0xFFF9A8D4);   // pink-300
  static const feminineEmoji = '💜';
  
  // ========== MASCULINE PALETTE ==========
  static const masculinePrimary = Color(0xFF3B82F6);      // blue-500
  static const masculineSecondary = Color(0xFF06B6D4);    // cyan-500
  static const masculineBackground = Color(0xFFF0F9FF);   // sky-50
  static const masculineSurface = Color(0xFFFFFFFF);
  static const masculineGradientStart = Color(0xFF3B82F6);
  static const masculineGradientEnd = Color(0xFF06B6D4);
  static const masculineBorder = Color(0xFFE0F2FE);       // sky-100
  static const masculineBorderFocus = Color(0xFF7DD3FC);  // sky-300
  static const masculineEmoji = '💙';
  
  // ========== SHARED COLORS ==========
  static const textPrimary = Color(0xFF1F2937);           // gray-800
  static const textSecondary = Color(0xFF6B7280);         // gray-500
  static const textTertiary = Color(0xFF9CA3AF);          // gray-400
  static const textInverse = Color(0xFFFFFFFF);
  
  // Semantic
  static const success = Color(0xFF10B981);               // emerald-500
  static const successLight = Color(0xFFD1FAE5);          // emerald-100
  static const warning = Color(0xFFF59E0B);               // amber-500
  static const warningLight = Color(0xFFFEF3C7);          // amber-100
  static const error = Color(0xFFEF4444);                 // red-500
  static const errorLight = Color(0xFFFEE2E2);            // red-100
  static const info = Color(0xFF3B82F6);                  // blue-500
  static const infoLight = Color(0xFFDBEAFE);             // blue-100
  
  // Decision Results
  static const decisionYes = Color(0xFF10B981);           // emerald
  static const decisionLeaningYes = Color(0xFF8B5CF6);    // violet
  static const decisionWait = Color(0xFFF59E0B);          // amber
  static const decisionLeaningNo = Color(0xFF6B7280);     // gray
}
```

## 7. config/theme/typography_tokens.dart
```dart
import 'package:flutter/material.dart';

class TypographyTokens {
  static const String fontFamily = 'Inter';
  
  // ========== SIZES ==========
  static const double sizeXs = 12.0;
  static const double sizeSm = 14.0;
  static const double sizeMd = 16.0;
  static const double sizeLg = 18.0;
  static const double sizeXl = 20.0;
  static const double size2xl = 24.0;
  static const double size3xl = 32.0;
  static const double size4xl = 40.0;
  
  // ========== WEIGHTS ==========
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  
  // ========== LINE HEIGHTS ==========
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.7;
  
  // ========== PRE-BUILT STYLES ==========
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: size3xl,
    fontWeight: bold,
    height: lineHeightTight,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: size2xl,
    fontWeight: semiBold,
    height: lineHeightTight,
  );
  
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: sizeXl,
    fontWeight: semiBold,
    height: lineHeightNormal,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: sizeLg,
    fontWeight: semiBold,
    height: lineHeightNormal,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: sizeMd,
    fontWeight: regular,
    height: lineHeightRelaxed,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: sizeSm,
    fontWeight: regular,
    height: lineHeightNormal,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: sizeMd,
    fontWeight: semiBold,
    height: lineHeightNormal,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: sizeXs,
    fontWeight: medium,
    height: lineHeightNormal,
  );
}
```

## 8. config/theme/spacing_tokens.dart
```dart
import 'package:flutter/material.dart';

class SpacingTokens {
  static const double xxxs = 2.0;
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
  
  // Screen padding
  static const EdgeInsets screenPadding = EdgeInsets.all(md);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: md);
}

class RadiusTokens {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double full = 9999.0;
  
  static BorderRadius get cardRadius => BorderRadius.circular(xl);
  static BorderRadius get buttonRadius => BorderRadius.circular(lg);
  static BorderRadius get inputRadius => BorderRadius.circular(lg);
  static BorderRadius get chipRadius => BorderRadius.circular(full);
}

class ShadowTokens {
  static List<BoxShadow> get sm => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get md => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get lg => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
```

## 9. config/theme/theme_config.dart
```dart
import 'package:flutter/material.dart';
import 'color_tokens.dart';
import 'typography_tokens.dart';
import 'spacing_tokens.dart';

enum AppThemeMode { feminine, masculine }

class ThemeConfig {
  final AppThemeMode mode;
  
  const ThemeConfig(this.mode);
  
  // ========== COLORS ==========
  Color get primary => mode == AppThemeMode.feminine 
      ? ColorTokens.femininePrimary 
      : ColorTokens.masculinePrimary;
      
  Color get secondary => mode == AppThemeMode.feminine 
      ? ColorTokens.feminineSecondary 
      : ColorTokens.masculineSecondary;
      
  Color get background => mode == AppThemeMode.feminine 
      ? ColorTokens.feminineBackground 
      : ColorTokens.masculineBackground;
      
  Color get surface => ColorTokens.feminineSurface;
  
  Color get gradientStart => mode == AppThemeMode.feminine 
      ? ColorTokens.feminineGradientStart 
      : ColorTokens.masculineGradientStart;
      
  Color get gradientEnd => mode == AppThemeMode.feminine 
      ? ColorTokens.feminineGradientEnd 
      : ColorTokens.masculineGradientEnd;
  
  Color get border => mode == AppThemeMode.feminine 
      ? ColorTokens.feminineBorder 
      : ColorTokens.masculineBorder;
      
  Color get borderFocus => mode == AppThemeMode.feminine 
      ? ColorTokens.feminineBorderFocus 
      : ColorTokens.masculineBorderFocus;
  
  String get emoji => mode == AppThemeMode.feminine 
      ? ColorTokens.feminineEmoji 
      : ColorTokens.masculineEmoji;
  
  LinearGradient get primaryGradient => LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ========== BUILD THEME DATA ==========
  ThemeData get themeData => ThemeData(
    useMaterial3: true,
    fontFamily: TypographyTokens.fontFamily,
    brightness: Brightness.light,
    
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: surface,
      background: background,
      onPrimary: ColorTokens.textInverse,
      onSecondary: ColorTokens.textInverse,
      onSurface: ColorTokens.textPrimary,
      onBackground: ColorTokens.textPrimary,
    ),
    
    scaffoldBackgroundColor: background,
    
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: ColorTokens.textPrimary),
      titleTextStyle: TypographyTokens.titleLarge.copyWith(
        color: ColorTokens.textPrimary,
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: ColorTokens.textInverse,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          vertical: SpacingTokens.md,
          horizontal: SpacingTokens.lg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: RadiusTokens.buttonRadius,
        ),
        textStyle: TypographyTokens.labelLarge,
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: BorderSide(color: primary, width: 2),
        padding: EdgeInsets.symmetric(
          vertical: SpacingTokens.md,
          horizontal: SpacingTokens.lg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: RadiusTokens.buttonRadius,
        ),
        textStyle: TypographyTokens.labelLarge,
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: TypographyTokens.labelLarge,
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: EdgeInsets.all(SpacingTokens.md),
      border: OutlineInputBorder(
        borderRadius: RadiusTokens.inputRadius,
        borderSide: BorderSide(color: border, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: RadiusTokens.inputRadius,
        borderSide: BorderSide(color: border, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: RadiusTokens.inputRadius,
        borderSide: BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: RadiusTokens.inputRadius,
        borderSide: BorderSide(color: ColorTokens.error, width: 2),
      ),
      hintStyle: TypographyTokens.bodyLarge.copyWith(
        color: ColorTokens.textTertiary,
      ),
    ),
    
    cardTheme: CardTheme(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: RadiusTokens.cardRadius,
        side: BorderSide(color: border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: ColorTokens.textTertiary,
    ),
    
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: border,
    ),
  );
}
```

## 10. config/content/strings.dart
```dart
class Strings {
  // ========== APP ==========
  static const appName = 'ShouldIBuyThis';
  static const appTagline = 'Struggling to spend on yourself?\nLet\'s figure it out together.';
  
  // ========== WELCOME ==========
  static const welcomeButton = 'Let\'s Start';
  static const welcomeFooter = 'No judgment. Just support.';
  
  // ========== GENDER ==========
  static const genderTitle = 'Choose your style';
  static const genderSubtitle = 'This personalizes your experience';
  static const genderFeminine = 'Soft & Warm';
  static const genderMasculine = 'Clean & Bold';
  
  // ========== MOOD ==========
  static const moodTitle = 'Hey there! 👋';
  static const moodSubtitle = 'How are you feeling right now?';
  
  // ========== PRODUCT INPUT ==========
  static const productInputTitle = 'What are you thinking about buying?';
  static const productInputUpload = 'Upload a photo or screenshot';
  static const productInputManual = 'Or describe it yourself';
  static const productInputAnalyzing = 'Analyzing your image...';
  
  // ========== QUESTIONS ==========
  static const questionContinue = 'Continue';
  static const questionBack = 'Back';
  static const questionSkip = 'Skip';
  
  // ========== ANALYZING ==========
  static const analyzingTitle = 'Thinking about this...';
  static const analyzingSteps = [
    'Understanding your situation...',
    'Considering your financial style...',
    'Checking what others do...',
    'Calculating cost per use...',
    'Preparing your insight...',
  ];
  
  // ========== RESULT ==========
  static const resultNewDecision = 'Ask About Something Else';
  static const resultSetReminder = 'Remind Me Later';
  static const resultPeerInsight = 'What others do';
  static const resultCostAnalysis = 'Cost breakdown';
  static const resultAlternatives = 'Alternatives to consider';
  static const resultActionItems = 'Your next steps';
  
  // ========== HISTORY ==========
  static const historyTitle = 'Past Decisions';
  static const historyEmpty = 'No decisions yet.\nYour history will appear here.';
  
  // ========== SETTINGS ==========
  static const settingsTitle = 'Settings';
  static const settingsEditProfile = 'Edit Profile';
  static const settingsTheme = 'Appearance';
  static const settingsHistory = 'Decision History';
  static const settingsClearData = 'Clear All Data';
  static const settingsAbout = 'About';
  
  // ========== ERRORS ==========
  static const errorGeneric = 'Something went wrong. Please try again.';
  static const errorNetwork = 'Please check your internet connection.';
  static const errorImage = 'Couldn\'t process the image. Try another one.';
  static const errorAI = 'Couldn\'t get a response. Please try again.';
  
  // ========== BUTTONS ==========
  static const buttonRetry = 'Try Again';
  static const buttonCancel = 'Cancel';
  static const buttonConfirm = 'Confirm';
  static const buttonSave = 'Save';
  static const buttonDone = 'Done';
}
```

## 11. config/content/onboarding_questions.dart
```dart
class OnboardingQuestions {
  static const List<Map<String, dynamic>> questions = [
    {
      'id': 'ageGroup',
      'type': 'single_select',
      'title': 'What\'s your age group?',
      'icon': '👤',
      'options': ['18-24', '25-34', '35-44', '45-54', '55+'],
    },
    {
      'id': 'country',
      'type': 'searchable_select',
      'title': 'Where do you live?',
      'icon': '🌍',
      'subtitle': 'Helps us understand spending norms in your area',
    },
    {
      'id': 'spendingStyle',
      'type': 'single_select',
      'title': 'How would you describe your spending style?',
      'icon': '💳',
      'options': [
        'Very careful - I think twice about every purchase',
        'Thoughtful - I budget but allow treats',
        'Balanced - I spend when I can afford it',
        'Relaxed - money is meant to be enjoyed',
      ],
    },
    {
      'id': 'hasFunBudget',
      'type': 'single_select',
      'title': 'Do you set aside "fun money" for personal spending?',
      'icon': '🎯',
      'options': [
        'Yes, I have a specific amount',
        'Sort of - I have a rough idea',
        'No, I decide case by case',
      ],
    },
    {
      'id': 'spendingGuilt',
      'type': 'single_select',
      'title': 'When you buy something for yourself, how do you usually feel?',
      'icon': '💭',
      'options': [
        'Guilty - even when I can afford it',
        'Anxious - I worry about "what ifs"',
        'Mixed - happy but slightly guilty',
        'Good - I deserve nice things',
      ],
    },
    {
      'id': 'lastSelfPurchase',
      'type': 'single_select',
      'title': 'When did you last buy something purely for yourself?',
      'icon': '🎁',
      'options': [
        'This week',
        'This month',
        'A few months ago',
        '6+ months ago',
        'I honestly can\'t remember',
      ],
    },
    {
      'id': 'decisionStyle',
      'type': 'single_select',
      'title': 'What\'s your usual approach to purchase decisions?',
      'icon': '🤔',
      'options': [
        'I research extensively',
        'I wait to see if I still want it',
        'I check my budget, then decide',
        'I often overthink and don\'t buy',
      ],
    },
    {
      'id': 'preferredWaitTime',
      'type': 'single_select',
      'title': 'How long do you usually wait before buying something non-essential?',
      'icon': '⏰',
      'options': [
        'I decide same day',
        '24-48 hours',
        'About a week',
        'A month or more',
      ],
    },
  ];
}
```

## 12. config/content/decision_questions.dart
```dart
class DecisionQuestions {
  // ========== ALWAYS ASKED ==========
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
  
  // ========== CONDITIONAL QUESTIONS ==========
  static const List<Map<String, dynamic>> conditionalQuestions = [
    // Price > $100: True cost
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
    // Price > $200: Affordability
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
    // Price > $100: Usage
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
    // Just discovered today: Impulse check
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
    // Price > $50: Deal check
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
  
  // ========== NO IMAGE: Manual entry ==========
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
```

## 13. config/content/mood_options.dart
```dart
class MoodOptions {
  static const List<Map<String, String>> options = [
    {'id': 'great', 'emoji': '😊', 'label': 'Great'},
    {'id': 'calm', 'emoji': '😌', 'label': 'Calm'},
    {'id': 'tired', 'emoji': '😔', 'label': 'Tired'},
    {'id': 'stressed', 'emoji': '😤', 'label': 'Stressed'},
    {'id': 'sad', 'emoji': '😢', 'label': 'Down'},
    {'id': 'bored', 'emoji': '😐', 'label': 'Bored'},
  ];
  
  static String getDescription(String id) {
    switch (id) {
      case 'great': return 'feeling great and energetic';
      case 'calm': return 'calm and relaxed';
      case 'tired': return 'tired and low energy';
      case 'stressed': return 'stressed and overwhelmed';
      case 'sad': return 'feeling down';
      case 'bored': return 'bored and restless';
      default: return id;
    }
  }
}
```

## 14. config/content/countries.dart
```dart
class Countries {
  static const List<Map<String, String>> list = [
    {'name': 'United States', 'code': 'US', 'currency': 'USD', 'symbol': '\},
    {'name': 'United Kingdom', 'code': 'GB', 'currency': 'GBP', 'symbol': '£'},
    {'name': 'Germany', 'code': 'DE', 'currency': 'EUR', 'symbol': '€'},
    {'name': 'France', 'code': 'FR', 'currency': 'EUR', 'symbol': '€'},
    {'name': 'Netherlands', 'code': 'NL', 'currency': 'EUR', 'symbol': '€'},
    {'name': 'Turkey', 'code': 'TR', 'currency': 'TRY', 'symbol': '₺'},
    {'name': 'Canada', 'code': 'CA', 'currency': 'CAD', 'symbol': 'C\},
    {'name': 'Australia', 'code': 'AU', 'currency': 'AUD', 'symbol': 'A\},
    {'name': 'Japan', 'code': 'JP', 'currency': 'JPY', 'symbol': '¥'},
    {'name': 'India', 'code': 'IN', 'currency': 'INR', 'symbol': '₹'},
    {'name': 'Brazil', 'code': 'BR', 'currency': 'BRL', 'symbol': 'R\},
    {'name': 'Mexico', 'code': 'MX', 'currency': 'MXN', 'symbol': '\},
    {'name': 'Spain', 'code': 'ES', 'currency': 'EUR', 'symbol': '€'},
    {'name': 'Italy', 'code': 'IT', 'currency': 'EUR', 'symbol': '€'},
    {'name': 'South Korea', 'code': 'KR', 'currency': 'KRW', 'symbol': '₩'},
    {'name': 'Other', 'code': 'XX', 'currency': 'USD', 'symbol': '\},
  ];
  
  static Map<String, String>? getByCode(String code) {
    return list.firstWhere(
      (c) => c['code'] == code,
      orElse: () => list.last,
    );
  }
  
  static Map<String, String>? getByName(String name) {
    return list.firstWhere(
      (c) => c['name'] == name,
      orElse: () => list.last,
    );
  }
}
```

---

# 🔧 CORE SERVICES

## core/services/openai_service.dart
```dart
import 'dart:convert';
import 'dart:typed_data';
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
  
  /// Analyze product image with Vision
  static Future<Map<String, dynamic>?> analyzeProductImage(Uint8List imageBytes) async {
    try {
      final base64Image = base64Encode(imageBytes);
      
      final response = await _client.post(
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
      ).timeout(AIConfig.visionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        
        // Extract JSON from response
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
        if (jsonMatch != null) {
          return jsonDecode(jsonMatch.group(0)!);
        }
      }
      return null;
    } catch (e) {
      print('Vision API Error: $e');
      return null;
    }
  }
  
  /// Main decision analysis
  static Future<Map<String, dynamic>> analyzePurchaseDecision({
    required Map<String, dynamic> userProfile,
    required String mood,
    required Map<String, dynamic> purchaseData,
    Map<String, dynamic>? productFromImage,
  }) async {
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

    final response = await _client.post(
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
    ).timeout(AIConfig.requestTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'] as String;
      return jsonDecode(content);
    }
    
    throw Exception('OpenAI API Error: ${response.statusCode} - ${response.body}');
  }
}
```

---

# 📱 SCREEN FLOW

## Flow Diagram
```
FIRST LAUNCH:
┌──────────┐   ┌──────────┐   ┌────────────┐   ┌──────────┐
│  Splash  │ → │ Welcome  │ → │   Gender   │ → │  Survey  │ → [Home]
└──────────┘   └──────────┘   └────────────┘   └──────────┘
                                                 (8 questions)

RETURNING USER:
┌──────────┐   ┌──────────┐   ┌─────────────────┐   ┌────────────┐
│   Home   │ → │   Mood   │ → │  Product Input  │ → │  Questions │
└──────────┘   └──────────┘   └─────────────────┘   └────────────┘
                                │                         │
                         ┌──────┴──────┐                  │
                         │             │                  │
                    [Image]      [Manual]                 │
                         │             │                  │
                   Vision API     Skip to ───────────────→│
                         │        questions               │
                         └─────────────────────────→ ┌────┴─────┐
                                                     │ Analyzing │
                                                     └────┬─────┘
                                                          │
                                                     ┌────┴─────┐
                                                     │  Result  │
                                                     └──────────┘
```

---

# 🚀 IMPLEMENTATION ORDER

Follow this exact order when building:

## Phase 1: Foundation (Day 1-2)
```
1. Create project: flutter create should_i_buy_this
2. Set up folder structure (copy from above)
3. Add all dependencies to pubspec.yaml
4. Create ALL config files first (copy from above)
5. Set up .env file with OPENAI_API_KEY
6. Create ThemeProvider
7. Create basic app.dart with theme switching
```

## Phase 2: Onboarding (Day 3-4)
```
1. Create UserProfile model
2. Create StorageService (SharedPreferences)
3. Build SplashScreen (check if user exists)
4. Build WelcomeScreen
5. Build GenderScreen (sets theme)
6. Build SurveyScreen (dynamic from config)
7. Save profile to local storage
```

## Phase 3: Core Flow (Day 5-7)
```
1. Build HomeScreen
2. Build MoodScreen
3. Build ProductInputScreen (image upload)
4. Create ImageService (pick + compress)
5. Create OpenAIService
6. Build QuestionsScreen (dynamic + conditional)
7. Build AnalyzingScreen (with loading messages)
8. Build ResultScreen (parse AI response)
```

## Phase 4: Polish (Day 8-10)
```
1. Add history storage
2. Build HistoryScreen
3. Build SettingsScreen
4. Add error handling everywhere
5. Add loading states
6. Test full flow
7. Fix bugs
```

---

# 📦 PUBSPEC.YAML

```yaml
name: should_i_buy_this
description: AI-powered purchase decision support
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1
  
  # Storage
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Network
  http: ^1.1.0
  
  # Image
  image_picker: ^1.0.7
  flutter_image_compress: ^2.1.0
  
  # Environment
  flutter_dotenv: ^5.1.0
  
  # UI
  shimmer: ^3.0.0
  
  # Navigation
  go_router: ^13.1.0
  
  # Utils
  uuid: ^4.3.1
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  hive_generator: ^2.0.1
  build_runner: ^2.4.8

flutter:
  uses-material-design: true
  
  assets:
    - .env
    - assets/images/
  
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

---

# ✅ CHECKLIST FOR VIBE CODER

Use this checklist as you build:

## Config Files
- [ ] env_config.dart
- [ ] ai_config.dart
- [ ] system_prompt.dart
- [ ] vision_prompt.dart
- [ ] prompt_builder.dart
- [ ] color_tokens.dart
- [ ] typography_tokens.dart
- [ ] spacing_tokens.dart
- [ ] theme_config.dart
- [ ] strings.dart
- [ ] onboarding_questions.dart
- [ ] decision_questions.dart
- [ ] mood_options.dart
- [ ] countries.dart

## Models
- [ ] user_profile.dart
- [ ] mood.dart
- [ ] purchase_query.dart
- [ ] product_info.dart
- [ ] ai_response.dart
- [ ] decision_record.dart

## Services
- [ ] openai_service.dart
- [ ] storage_service.dart
- [ ] image_service.dart

## Providers
- [ ] theme_provider.dart
- [ ] user_provider.dart
- [ ] decision_provider.dart
- [ ] history_provider.dart

## Screens
- [ ] splash_screen.dart
- [ ] welcome_screen.dart
- [ ] gender_screen.dart
- [ ] survey_screen.dart
- [ ] home_screen.dart
- [ ] mood_screen.dart
- [ ] product_input_screen.dart
- [ ] questions_screen.dart
- [ ] analyzing_screen.dart
- [ ] result_screen.dart
- [ ] history_screen.dart
- [ ] settings_screen.dart

---

# 🎯 KEY REMINDERS

1. **NEVER hardcode colors** - always use ColorTokens
2. **NEVER hardcode strings** - always use Strings class
3. **NEVER hardcode questions** - always use config files
4. **NEVER hardcode prompt and llm model namess** - always use prompt files
5. **Theme must work** - test both feminine and masculine
6. **Handle errors gracefully** - show user-friendly messages
7. **Loading states everywhere** - never leave user hanging

Good luck! 🚀