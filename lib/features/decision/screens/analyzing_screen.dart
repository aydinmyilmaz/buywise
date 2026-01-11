import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/content/strings.dart';
import '../../../core/providers/decision_provider.dart';
import '../../../core/providers/user_provider.dart';

class AnalyzingScreen extends StatefulWidget {
  const AnalyzingScreen({super.key});

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final decisionProvider = context.read<DecisionProvider>();
    final userProvider = context.read<UserProvider>();
    if (decisionProvider.imageBytes != null && decisionProvider.productInfo == null) {
      await decisionProvider.analyzeImage();
    }
    await decisionProvider.analyze(userProvider.profileMap);
    if (!mounted) return;
    context.go('/result');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(Strings.analyzingTitle),
          ],
        ),
      ),
    );
  }
}
