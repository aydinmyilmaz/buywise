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
    final countryName = (_answers['country'] as String? ?? 'United States').trim();
    final country = Countries.getByName(countryName) ?? Countries.list.last;
    final profile = UserProfile(
      gender: widget.gender ?? 'neutral',
      country: country['name']!,
      currency: country['currency']!,
      ageGroup: _answers['ageGroup'] ?? '',
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
                      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm, vertical: SpacingTokens.xs),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('${_index + 1}/${_questions.length}', style: theme.textTheme.bodyMedium),
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

  const _QuestionPage({
    super.key,
    required this.question,
    required this.accent,
    required this.controller,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = question['type'];
    final icon = question['icon'] ?? '';
    final title = question['title'] ?? '';
    final subtitle = question['subtitle'];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.18),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(icon.toString(), style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(title.toString(), style: theme.textTheme.headlineMedium),
            if (subtitle != null) ...[
              const SizedBox(height: SpacingTokens.xs),
              Text(subtitle.toString(), style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: SpacingTokens.lg),
            if (type == 'single_select')
              Wrap(
                children: (question['options'] as List<dynamic>)
                    .map(
                      (option) => SelectOption(
                        label: option.toString(),
                        selected: selected == option,
                        onTap: () => onSelect(option),
                      ),
                    )
                    .toList(),
              )
            else
              TextField(
                controller: controller,
                decoration: InputDecoration(hintText: subtitle?.toString() ?? ''),
                onChanged: (val) => onSelect(val),
              ),
          ],
        ),
      ),
    );
  }
}
