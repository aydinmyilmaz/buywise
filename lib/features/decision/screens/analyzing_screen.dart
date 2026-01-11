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
  int _currentStep = 0;
  final List<String> _steps = Strings.analyzingSteps;

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _runAnalysis();
  }

  void _startAnimation() async {
    for (int i = 0; i < _steps.length; i++) {
      if (!mounted) return;
      setState(() => _currentStep = i);
      await Future.delayed(const Duration(milliseconds: 1800));
    }
  }

  Future<void> _runAnalysis() async {
    // Add a small initial delay so the user sees the first "Thinking" step
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    final decisionProvider = context.read<DecisionProvider>();
    final userProvider = context.read<UserProvider>();
    
    try {
      if (decisionProvider.imageBytes != null && decisionProvider.productInfo == null) {
        await decisionProvider.analyzeImage();
      }
      await decisionProvider.analyze(userProvider.profileMap);
      
      if (!mounted) return;
      // Ensure we showed at least a couple of steps before pushing result
      if (_currentStep < 2) {
         await Future.delayed(const Duration(seconds: 2));
      }
      context.go('/result');
    } catch (e) {
      if (mounted) context.pop(); // Go back on critical error
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the provider to get the primary color for the loader
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Container(
         width: double.infinity,
         padding: const EdgeInsets.all(32),
         child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: primaryColor,
                backgroundColor: primaryColor.withOpacity(0.1),
              ),
            ),
            const SizedBox(height: 48),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                _steps[_currentStep],
                key: ValueKey<int>(_currentStep),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              Strings.analyzingTitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
