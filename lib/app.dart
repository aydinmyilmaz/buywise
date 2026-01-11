import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'config/theme/theme_config.dart';
import 'core/providers/decision_provider.dart';
import 'core/providers/history_provider.dart';
import 'core/providers/pending_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/user_provider.dart';
import 'features/decision/screens/analyzing_screen.dart';
import 'features/decision/screens/mood_screen.dart';
import 'features/decision/screens/product_input_screen.dart';
import 'features/decision/screens/questions_screen.dart';
import 'features/decision/screens/result_screen.dart';
import 'features/history/screens/history_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/onboarding/screens/gender_screen.dart';
import 'features/onboarding/screens/splash_screen.dart';
import 'features/onboarding/screens/survey_screen.dart';
import 'features/onboarding/screens/welcome_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/settings/screens/edit_profile_screen.dart';

class ShouldIBuyThisApp extends StatefulWidget {
  const ShouldIBuyThisApp({super.key});

  @override
  State<ShouldIBuyThisApp> createState() => _ShouldIBuyThisAppState();
}

class _ShouldIBuyThisAppState extends State<ShouldIBuyThisApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/welcome', builder: (context, state) => const WelcomeScreen()),
        GoRoute(path: '/gender', builder: (context, state) => const GenderScreen()),
        GoRoute(path: '/survey', builder: (context, state) => SurveyScreen(gender: state.extra as String?)),
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/mood', builder: (context, state) => const MoodScreen()),
        GoRoute(path: '/product', builder: (context, state) => const ProductInputScreen()),
        GoRoute(path: '/questions', builder: (context, state) => QuestionsScreen(baseData: state.extra as Map<String, dynamic>?)),
        GoRoute(path: '/analyzing', builder: (context, state) => const AnalyzingScreen()),
        GoRoute(path: '/result', builder: (context, state) => const ResultScreen()),
        GoRoute(path: '/history', builder: (context, state) => const HistoryScreen()),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        GoRoute(path: '/edit-profile', builder: (context, state) => const EditProfileScreen()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DecisionProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => PendingProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp.router(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          routerConfig: _router,
        ),
      ),
    );
  }
}
