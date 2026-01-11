import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/content/decision_questions.dart';
import '../../../config/content/strings.dart';
import '../../../config/theme/spacing_tokens.dart';
import '../../../core/models/purchase_query.dart';
import '../../../core/providers/decision_provider.dart';
import '../../decision/widgets/multi_select.dart';
import '../../decision/widgets/select_option.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/atmosphere_background.dart';

class QuestionsScreen extends StatefulWidget {
  final Map<String, dynamic>? baseData;
  const QuestionsScreen({super.key, this.baseData});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  late double _price;
  late final TextEditingController _priceController;
  late final TextEditingController _currencyController;
  String _wantDuration = DecisionQuestions.coreQuestions[1]['options'][0];
  List<String> _reasons = [];
  List<String> _additionalCosts = [];
  String? _affordabilityLevel;
  String? _usageFrequency;
  String? _willingToWait;
  String? _hasCheckedDeals;

  final PageController _pageController = PageController();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _price = (widget.baseData?['price'] ?? 0).toDouble();
    _priceController = TextEditingController(text: _price == 0 ? '' : _price.toStringAsFixed(0));
    _currencyController = TextEditingController(text: widget.baseData?['currency'] ?? 'USD');
  }

  @override
  void dispose() {
    _priceController.dispose();
    _currencyController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _buildQuestions() {
    final questions = <Map<String, dynamic>>[...DecisionQuestions.coreQuestions];
    for (final q in DecisionQuestions.conditionalQuestions) {
      final condition = q['condition'] as Map<String, dynamic>;
      final field = condition['field'];
      if (field == 'price') {
        final value = (condition['value'] as num).toDouble();
        if (condition['operator'] == '>' && _price > value) {
          questions.add(q);
        }
      }
      if (field == 'wantDuration') {
        if (condition['operator'] == '==' && _wantDuration == condition['value']) {
          questions.add(q);
        }
      }
    }
    return questions;
  }

  bool _isValid(Map<String, dynamic> question) {
    final id = question['id'];
    if (id == 'price') return _price > 0;
    if (id == 'wantDuration') return _wantDuration.isNotEmpty;
    if (id == 'reasons') return _reasons.isNotEmpty;
    if (id == 'additionalCosts') return _additionalCosts.isNotEmpty;
    if (id == 'affordabilityLevel') return _affordabilityLevel != null;
    if (id == 'usageFrequency') return _usageFrequency != null;
    if (id == 'willingToWait') return _willingToWait != null;
    if (id == 'hasCheckedDeals') return _hasCheckedDeals != null;
    return true;
  }

  void _next(List<Map<String, dynamic>> questions) {
    if (_index < questions.length - 1) {
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

  void _save() {
    final purchase = PurchaseQuery(
      productName: widget.baseData?['productName'] ?? 'Unknown',
      category: widget.baseData?['category'] ?? 'Other',
      price: _price,
      currency: _currencyController.text.trim().isEmpty ? 'USD' : _currencyController.text.trim(),
      reasons: _reasons,
      wantDuration: _wantDuration,
      additionalCosts: _additionalCosts.isEmpty ? null : _additionalCosts,
      affordabilityLevel: _affordabilityLevel,
      usageFrequency: _usageFrequency,
      willingToWait: _willingToWait,
      hasCheckedDeals: _hasCheckedDeals,
    );
    context.read<DecisionProvider>().setPurchase(purchase);
    context.push('/analyzing');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final questions = _buildQuestions();
    if (_index >= questions.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _index = questions.length - 1);
      });
    }
    final progress = (_index + 1) / questions.length;
    final current = questions[_index];
    final accentColors = [
      theme.colorScheme.secondary,
      theme.colorScheme.primary,
      theme.colorScheme.tertiary,
      theme.colorScheme.secondaryContainer,
      theme.colorScheme.primaryContainer,
    ];
    final accent = accentColors[_index % accentColors.length];

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
                    IconButton(icon: const Icon(Icons.arrow_back), onPressed: _back),
                    const SizedBox(width: SpacingTokens.xs),
                    Expanded(child: Text(Strings.questionsTitle, style: theme.textTheme.titleLarge)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm, vertical: SpacingTokens.xs),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('${_index + 1}/${questions.length}', style: theme.textTheme.bodyMedium),
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
                    itemCount: questions.length,
                    itemBuilder: (context, index) => _DecisionQuestionPage(
                      key: ValueKey(questions[index]['id']),
                      question: questions[index],
                      accent: accentColors[index % accentColors.length],
                      priceController: _priceController,
                      currencyController: _currencyController,
                      price: _price,
                      reasons: _reasons,
                      wantDuration: _wantDuration,
                      additionalCosts: _additionalCosts,
                      affordabilityLevel: _affordabilityLevel,
                      usageFrequency: _usageFrequency,
                      willingToWait: _willingToWait,
                      hasCheckedDeals: _hasCheckedDeals,
                      onPriceChanged: (val) => setState(() => _price = val),
                      onWantDurationChanged: (val) => setState(() => _wantDuration = val),
                      onReasonsChanged: (val) => setState(() => _reasons = val),
                      onAdditionalCostsChanged: (val) => setState(() => _additionalCosts = val),
                      onAffordabilityChanged: (val) => setState(() => _affordabilityLevel = val),
                      onUsageChanged: (val) => setState(() => _usageFrequency = val),
                      onWaitChanged: (val) => setState(() => _willingToWait = val),
                      onDealsChanged: (val) => setState(() => _hasCheckedDeals = val),
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                AppButton(
                  label: _index == questions.length - 1 ? Strings.analyze : Strings.continueLabel,
                  onPressed: _isValid(current) ? () => _next(questions) : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DecisionQuestionPage extends StatelessWidget {
  final Map<String, dynamic> question;
  final Color accent;
  final TextEditingController priceController;
  final TextEditingController currencyController;
  final double price;
  final List<String> reasons;
  final String wantDuration;
  final List<String> additionalCosts;
  final String? affordabilityLevel;
  final String? usageFrequency;
  final String? willingToWait;
  final String? hasCheckedDeals;
  final ValueChanged<double> onPriceChanged;
  final ValueChanged<String> onWantDurationChanged;
  final ValueChanged<List<String>> onReasonsChanged;
  final ValueChanged<List<String>> onAdditionalCostsChanged;
  final ValueChanged<String> onAffordabilityChanged;
  final ValueChanged<String> onUsageChanged;
  final ValueChanged<String> onWaitChanged;
  final ValueChanged<String> onDealsChanged;

  const _DecisionQuestionPage({
    super.key,
    required this.question,
    required this.accent,
    required this.priceController,
    required this.currencyController,
    required this.price,
    required this.reasons,
    required this.wantDuration,
    required this.additionalCosts,
    required this.affordabilityLevel,
    required this.usageFrequency,
    required this.willingToWait,
    required this.hasCheckedDeals,
    required this.onPriceChanged,
    required this.onWantDurationChanged,
    required this.onReasonsChanged,
    required this.onAdditionalCostsChanged,
    required this.onAffordabilityChanged,
    required this.onUsageChanged,
    required this.onWaitChanged,
    required this.onDealsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final id = question['id'];
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
            if (id == 'price')
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: Strings.priceLabel),
                      onChanged: (val) => onPriceChanged(double.tryParse(val) ?? 0),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.md),
                  SizedBox(
                    width: 110,
                    child: TextField(
                      controller: currencyController,
                      decoration: const InputDecoration(labelText: Strings.currencyLabel),
                    ),
                  ),
                ],
              )
            else if (id == 'wantDuration')
              Wrap(
                children: (question['options'] as List<dynamic>)
                    .map(
                      (option) => SelectOption(
                        label: option.toString(),
                        selected: wantDuration == option,
                        onTap: () => onWantDurationChanged(option.toString()),
                      ),
                    )
                    .toList(),
              )
            else if (id == 'reasons')
              MultiSelect(
                options: (question['options'] as List<dynamic>).cast<String>(),
                selected: reasons,
                onChanged: onReasonsChanged,
              )
            else if (id == 'additionalCosts')
              MultiSelect(
                options: (question['options'] as List<dynamic>).cast<String>(),
                selected: additionalCosts,
                onChanged: onAdditionalCostsChanged,
              )
            else
              Wrap(
                children: (question['options'] as List<dynamic>)
                    .map(
                      (option) => SelectOption(
                        label: option.toString(),
                        selected: _isSelected(id, option.toString()),
                        onTap: () => _setSingle(id, option.toString()),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  bool _isSelected(String id, String option) {
    switch (id) {
      case 'affordabilityLevel':
        return affordabilityLevel == option;
      case 'usageFrequency':
        return usageFrequency == option;
      case 'willingToWait':
        return willingToWait == option;
      case 'hasCheckedDeals':
        return hasCheckedDeals == option;
      default:
        return false;
    }
  }

  void _setSingle(String id, String option) {
    switch (id) {
      case 'affordabilityLevel':
        onAffordabilityChanged(option);
        break;
      case 'usageFrequency':
        onUsageChanged(option);
        break;
      case 'willingToWait':
        onWaitChanged(option);
        break;
      case 'hasCheckedDeals':
        onDealsChanged(option);
        break;
    }
  }
}
