import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/content/onboarding_questions.dart';
import '../../../config/content/strings.dart';
import '../../../config/content/countries.dart';
import '../../../config/theme/spacing_tokens.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/user_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../decision/widgets/select_option.dart';
import '../../../shared/widgets/atmosphere_background.dart';

class SurveyScreen extends StatefulWidget {
  final String? gender;
  const SurveyScreen({super.key, this.gender});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final Map<String, dynamic> _answers = {};
  final Map<String, TextEditingController> _controllers = {};
  final PageController _pageController = PageController();
  int _index = 0;

  List<Map<String, dynamic>> get _questions => OnboardingQuestions.questions;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _setAnswer(String id, dynamic value) {
    setState(() {
      _answers[id] = value;
    });
  }

  bool _isValid(Map<String, dynamic> question) {
    final id = question['id'];
    final type = question['type'];
    if (type == 'single_select') {
      return _answers[id] != null;
    }
    if (type == 'text') {
      final controller = _controllers[id];
      return controller != null && controller.text.trim().isNotEmpty;
    }
    return true;
  }

  void _next() {
    if (_index < _questions.length - 1) {
      setState(() => _index++);
      _pageController.animateToPage(
        _index,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    } else {
      _save();
    }
  }

  void _back() {
    if (_index > 0) {
      setState(() => _index--);
      _pageController.animateToPage(
        _index,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    } else {
      context.pop();
    }
  }

  Future<void> _save() async {
    // Get country name from text field - accept any value (open-ended)
    final countryName = (_answers['country'] as String? ?? 'United States').trim();
    
    // Try to find currency from predefined list, but don't require it
    final countryData = Countries.getByName(countryName);
    final currency = countryData?['currency'] ?? 'USD'; // Default to USD if not found
    
    final profile = UserProfile(
      gender: widget.gender ?? 'neutral',
      country: countryName, // Save whatever the user typed
      currency: currency,
      ageGroup: _answers['ageGroup'] ?? '',
      monthlyIncome: _answers['monthlyIncome'] ?? '',
      primaryGoal: _answers['primaryGoal'] ?? '',
      spendingStyle: _answers['spendingStyle'] ?? '',
      hasFunBudget: _answers['hasFunBudget'] ?? '',
      spendingGuilt: _answers['spendingGuilt'] ?? '',
      lastSelfPurchase: _answers['lastSelfPurchase'] ?? '',
      decisionStyle: _answers['decisionStyle'] ?? '',
      preferredWaitTime: _answers['preferredWaitTime'] ?? '',
    );
    await context.read<UserProvider>().save(profile);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = _questions[_index];
    final accentColors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.primaryContainer,
      theme.colorScheme.secondaryContainer,
    ];
    final accent = accentColors[_index % accentColors.length];
    final progress = (_index + 1) / _questions.length;

    return Scaffold(
      body: AtmosphereBackground(
        accents: [accent, accentColors[(_index + 1) % accentColors.length]],
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _back,
                    ),
                    const SizedBox(width: SpacingTokens.xs),
                    Expanded(
                      child: Text(
                        Strings.surveyTitle,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.sm, vertical: SpacingTokens.xs),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('${_index + 1}/${_questions.length}',
                          style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.sm),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                ),
                const SizedBox(height: SpacingTokens.lg),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _questions.length,
                    itemBuilder: (context, index) => _QuestionPage(
                      key: ValueKey(_questions[index]['id']),
                      question: _questions[index],
                      accent: accentColors[index % accentColors.length],
                      controller: _controllers.putIfAbsent(
                        _questions[index]['id'],
                        () => TextEditingController(),
                      ),
                      selected: _answers[_questions[index]['id']],
                      onSelect: (value) => _setAnswer(_questions[index]['id'], value),
                      onNext: _next,
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                AppButton(
                  label: _index == _questions.length - 1 ? Strings.save : Strings.continueLabel,
                  onPressed: _isValid(question) ? _next : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionPage extends StatelessWidget {
  final Map<String, dynamic> question;
  final Color accent;
  final TextEditingController controller;
  final dynamic selected;
  final ValueChanged<dynamic> onSelect;
  final VoidCallback onNext;

  const _QuestionPage({
    super.key,
    required this.question,
    required this.accent,
    required this.controller,
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = question['type'];
    final icon = question['icon'] ?? '';
    final title = question['title'] ?? '';
    final subtitle = question['subtitle'];
    
    return SingleChildScrollView(
      child: Container(
        // Glassmorphism card container
        padding: const EdgeInsets.all(SpacingTokens.xl),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Bubble
            Container(
               width: 72,
               height: 72,
               alignment: Alignment.center,
               decoration: BoxDecoration(
                 gradient: LinearGradient(
                   colors: [
                     accent.withOpacity(0.15),
                     accent.withOpacity(0.08),
                   ],
                   begin: Alignment.topLeft,
                   end: Alignment.bottomRight,
                 ),
                 shape: BoxShape.circle,
                 border: Border.all(
                   color: accent.withOpacity(0.25), 
                   width: 2,
                 ),
                 boxShadow: [
                   BoxShadow(
                     color: accent.withOpacity(0.15),
                     blurRadius: 12,
                     offset: const Offset(0, 4),
                   ),
                 ],
               ),
               child: Text(icon.toString(), style: const TextStyle(fontSize: 36)),
            ),
            const SizedBox(height: SpacingTokens.lg),
            
            // Title
            Text(
              title.toString(),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
            
            if (subtitle != null) ...[ 
              const SizedBox(height: SpacingTokens.sm),
              Text(
                subtitle.toString(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.65),
                  height: 1.5,
                  fontSize: 16,
                ),
              ),
            ],
            
            const SizedBox(height: SpacingTokens.xl),
            
            // Options
            if (type == 'single_select')
              Wrap(
                spacing: SpacingTokens.xs,
                runSpacing: SpacingTokens.xs,
                children: (question['options'] as List<dynamic>)
                    .map(
                      (option) => SelectOption(
                        label: option.toString(),
                        selected: selected == option,
                        onTap: () {
                           onSelect(option);
                           // Auto advance for single select
                           Future.delayed(const Duration(milliseconds: 350), onNext);
                        },
                      ),
                    )
                    .toList(),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Type your answer...',
                      filled: true,
                      fillColor: theme.colorScheme.surface.withOpacity(0.8),
                      contentPadding: const EdgeInsets.all(SpacingTokens.lg),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: accent, width: 2),
                      ),
                    ),
                    onChanged: (val) => onSelect(val),
                    onSubmitted: (_) => onNext(),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    'Press Return to continue',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
