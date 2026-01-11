import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/history_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final userProvider = context.read<UserProvider>();
    final historyProvider = context.read<HistoryProvider>();
    await userProvider.load();
    await historyProvider.load();
    if (userProvider.profile != null) {
      context.read<ThemeProvider>().setGender(userProvider.profile!.gender);
      if (!mounted) return;
      context.go('/home');
    } else {
      if (!mounted) return;
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
