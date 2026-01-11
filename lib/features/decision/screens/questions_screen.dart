import 'dart:ui';
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
  late final TextEditingController _productNameController; // New
  
  String _wantDuration = '';
  String _category = ''; // New
  String _emotionalState = ''; // New
  
  List<String> _reasons = []; // Kept for legacy compatibility if needed
  List<String> _additionalCosts = [];
  List<String> _marketingTactics = []; // New
  
  // Conditional vars
  String? _affordabilityLevel; // Renamed to 'affordability' in ID but let's check
  String? _usageFrequency; // usageReality in new?
  String? _willingToWait; // waitRule in new?
  String? _hasCheckedDeals;
  String? _necessity;
  String? _utility; // substitution in new?
  String? _sentiment; // postPurchaseFeel in new?
  String? _resaleValue;
  String? _laborCost; // New
  String? _opportunityCost; // New
  String? _socialProof; // New
  String? _usageReality; // New
  String? _postPurchaseFeel; // New
  String? _waitRule; // New
  String? _substitution; // New

  final PageController _pageController = PageController();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _price = (widget.baseData?['price'] ?? 0).toDouble();
    _priceController = TextEditingController(text: _price == 0 ? '' : _price.toStringAsFixed(0));
    _currencyController = TextEditingController(text: widget.baseData?['currency'] ?? 'USD');
    _productNameController = TextEditingController(text: widget.baseData?['productName'] ?? '');

    // Initialize category from baseData if available, otherwise use default
    if (widget.baseData != null && widget.baseData!['category'] != null) {
      _category = widget.baseData!['category'];
    } else {
      _initDefaultOption('category', (val) => _category = val);
    }

    // Safely initialize default options if they exist
    _initDefaultOption('wantDuration', (val) => _wantDuration = val);
  }

  void _initDefaultOption(String id, Function(String) setter) {
    final q = DecisionQuestions.coreQuestions.firstWhere((q) => q['id'] == id, orElse: () => {});
    if (q.isNotEmpty && q['options'] != null && (q['options'] as List).isNotEmpty) {
       setter((q['options'] as List).first as String);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _currencyController.dispose();
    _productNameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _buildQuestions() {
    final questions = <Map<String, dynamic>>[];
    for (final q in DecisionQuestions.coreQuestions) {
      final id = q['id'];

      // Skip questions if already answered in product input
      if (id == 'productName' && _productNameController.text.isNotEmpty) continue;
      if (id == 'price' && _price > 0) continue;
      if (id == 'category' && _category.isNotEmpty && _category != 'Other') continue;

      questions.add(q);
    }

    for (final q in DecisionQuestions.conditionalQuestions) {
      if (_shouldShowQuestion(q)) {
        questions.add(q);
      }
    }
    return questions;
  }

  bool _shouldShowQuestion(Map<String, dynamic> q) {
    final condition = q['condition'] as Map<String, dynamic>;
    final field = condition['field'];
    final operator = condition['operator'];
    final value = condition['value'];

    dynamic currentValue;
    switch (field) {
      case 'price': currentValue = _price; break;
      case 'wantDuration': currentValue = _wantDuration; break;
      case 'category': currentValue = _category; break;
      case 'emotionalState': currentValue = _emotionalState; break;
      default: return false;
    }

    if (operator == '>') return (currentValue is num) && currentValue > (value as num);
    if (operator == '==') return currentValue == value;
    if (operator == '!=') return currentValue != value;
    if (operator == 'in') return (value as List).contains(currentValue);

    return false;
  }

  bool _isValid(Map<String, dynamic> question) {
    final id = question['id'];
    if (id == 'productName') return _productNameController.text.isNotEmpty;
    if (id == 'price') return _price > 0;
    if (id == 'wantDuration') return _wantDuration.isNotEmpty;
    if (id == 'category') return _category.isNotEmpty;
    if (id == 'emotionalState') return _emotionalState.isNotEmpty;
    
    // For selects, usually they are set, but ensure not null if strictly required
    if (question['type'].toString().contains('select')) {
      return true; // We default to first or selected, simplified validation
    }
    return true;
  }

  void _next(List<Map<String, dynamic>> questions) {
    // Force save text fields if current page has them
    final currentQ = questions[_index];
    if (currentQ['id'] == 'productName') {
      // already in controller
    }

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
      productName: _productNameController.text.isEmpty ? 'Unknown' : _productNameController.text,
      category: _category.isEmpty ? 'Other' : _category,
      price: _price,
      currency: _currencyController.text.trim().isEmpty ? 'USD' : _currencyController.text.trim(),
      reasons: _reasons, // Legacy
      wantDuration: _wantDuration,
      additionalCosts: _additionalCosts,
      affordabilityLevel: _affordabilityLevel,
      usageFrequency: _usageFrequency ?? _usageReality, // Map new to old or add new fields to model later
      willingToWait: _willingToWait ?? _waitRule,
      hasCheckedDeals: _hasCheckedDeals, // Logic might overlap with marketingTactics
      necessity: _necessity,
      utility: _utility ?? _substitution,
      sentiment: _sentiment ?? _postPurchaseFeel,
      resaleValue: _resaleValue,
      // Pass raw data for new fields that might not be in PurchaseQuery yet, 
      // or we should have updated PurchaseQuery. 
      // For now, mapping best effort to existing fields.
    );
    context.read<DecisionProvider>().setPurchase(purchase);
    context.push('/analyzing');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final questions = _buildQuestions();
    if (_index >= questions.length && questions.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _index = questions.length - 1);
      });
    }
    // Safety check if questions are empty (edge case)
    if (questions.isEmpty) return Container(); 

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
                      productNameController: _productNameController, // New
                      price: _price,
                      
                      // State values
                      reasons: _reasons,
                      wantDuration: _wantDuration,
                      category: _category, // New
                      emotionalState: _emotionalState, // New
                      additionalCosts: _additionalCosts,
                      
                      // Mapped values
                      affordabilityLevel: _affordabilityLevel,
                      usageFrequency: _usageFrequency,
                      willingToWait: _willingToWait,
                      hasCheckedDeals: _hasCheckedDeals,
                      necessity: _necessity,
                      utility: _utility,
                      sentiment: _sentiment,
                      resaleValue: _resaleValue,
                      
                      // Callbacks
                      onPriceChanged: (val) => setState(() => _price = val),
                      onProductNameChanged: (val) {}, // Managed by controller
                      onWantDurationChanged: (val) => setState(() => _wantDuration = val),
                      onCategoryChanged: (val) => setState(() => _category = val),
                      onEmotionalStateChanged: (val) => setState(() => _emotionalState = val),
                      onReasonsChanged: (val) => setState(() => _reasons = val),
                      onAdditionalCostsChanged: (val) => setState(() => _additionalCosts = val),
                      
                      // Generic Callbacks for conditional
                      onAffordabilityChanged: (val) => setState(() => _affordabilityLevel = val),
                      onUsageChanged: (val) => setState(() => _usageFrequency = val),
                      onWaitChanged: (val) => setState(() => _willingToWait = val),
                      onDealsChanged: (val) => setState(() => _hasCheckedDeals = val),
                      onNecessityChanged: (val) => setState(() => _necessity = val),
                      onUtilityChanged: (val) => setState(() => _utility = val),
                      onSentimentChanged: (val) => setState(() => _sentiment = val),
                      onResaleValueChanged: (val) => setState(() => _resaleValue = val),
                      
                      // NEW: Generic fallbacks for new fields mapping to old vars or new vars
                      onGenericChanged: (id, val) {
                        setState(() {
                          if (id == 'laborCost') _laborCost = val;
                          else if (id == 'opportunityCost') _opportunityCost = val;
                          else if (id == 'socialProof') _socialProof = val;
                          else if (id == 'usageReality') _usageReality = val;
                          else if (id == 'postPurchaseFeel') _postPurchaseFeel = val;
                          else if (id == 'waitRule') _waitRule = val;
                          else if (id == 'substitution') _substitution = val;
                        });
                      },
                      onNext: () => _next(questions),
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
  final TextEditingController? productNameController;
  final double price;
  final List<String> reasons;
  final String wantDuration;
  final String category;
  final String emotionalState;
  final List<String> additionalCosts;
  
  final String? affordabilityLevel;
  final String? usageFrequency;
  final String? willingToWait;
  final String? hasCheckedDeals;
  final String? necessity;
  final String? utility;
  final String? sentiment;
  final String? resaleValue;

  final ValueChanged<double> onPriceChanged;
  final ValueChanged<String> onProductNameChanged;
  final ValueChanged<String> onWantDurationChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onEmotionalStateChanged;
  final ValueChanged<List<String>> onReasonsChanged;
  final ValueChanged<List<String>> onAdditionalCostsChanged;
  final ValueChanged<String> onAffordabilityChanged;
  final ValueChanged<String> onUsageChanged;
  final ValueChanged<String> onWaitChanged;
  final ValueChanged<String> onDealsChanged;
  final ValueChanged<String> onNecessityChanged;
  final ValueChanged<String> onUtilityChanged;
  final ValueChanged<String> onSentimentChanged;
  final ValueChanged<String> onResaleValueChanged;
  final Function(String, String) onGenericChanged;
  final VoidCallback onNext;

  const _DecisionQuestionPage({
    super.key,
    required this.question,
    required this.accent,
    required this.priceController,
    required this.currencyController,
    required this.productNameController,
    required this.price,
    required this.reasons,
    required this.wantDuration,
    this.category = '',
    this.emotionalState = '',
    required this.additionalCosts,
    required this.affordabilityLevel,
    required this.usageFrequency,
    required this.willingToWait,
    required this.hasCheckedDeals,
    required this.necessity,
    required this.utility,
    required this.sentiment,
    required this.resaleValue,
    required this.onPriceChanged,
    required this.onProductNameChanged,
    required this.onWantDurationChanged,
    required this.onCategoryChanged,
    required this.onEmotionalStateChanged,
    required this.onReasonsChanged,
    required this.onAdditionalCostsChanged,
    required this.onAffordabilityChanged,
    required this.onUsageChanged,
    required this.onWaitChanged,
    required this.onDealsChanged,
    required this.onNecessityChanged,
    required this.onUtilityChanged,
    required this.onSentimentChanged,
    required this.onResaleValueChanged,
    required this.onGenericChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final id = question['id'];
    final icon = question['icon'] ?? '';
    final title = question['title'] ?? '';
    final subtitle = question['subtitle'];
    final type = question['type'];

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                    title.toString(), 
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      height: 1.2,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: SpacingTokens.sm),
                    Text(
                      subtitle.toString(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        height: 1.4,
                      ),
                    ),
                  ],
              const SizedBox(height: SpacingTokens.lg),
              
              if (id == 'price')
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: Strings.priceLabel,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) => onPriceChanged(double.tryParse(val) ?? 0),
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.md),
                    SizedBox(
                      width: 110,
                      child: TextField(
                        controller: currencyController,
                        decoration: const InputDecoration(
                          labelText: Strings.currencyLabel,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                )
              else if (id == 'productName')
                TextField(
                  controller: productNameController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                     hintText: question['placeholder'] ?? 'Type here...',
                     border: const OutlineInputBorder(),
                     filled: true,
                     fillColor: Colors.white.withOpacity(0.5),
                  ),
                  onChanged: onProductNameChanged,
                )
              else if (id == 'reasons' || type == 'multi_select')
                MultiSelect(
                  options: (question['options'] as List<dynamic>).cast<String>(),
                  selected: id == 'reasons' ? reasons : additionalCosts, // Simplification for now, revisit for generic
                  onChanged: id == 'reasons' ? onReasonsChanged : onAdditionalCostsChanged,
                )
              else
                // Generic Single Select for EVERYTHING else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
          ),
        ),
      ),
    );
  }

  bool _isSelected(String id, String option) {
    if (id == 'wantDuration') return wantDuration == option;
    if (id == 'category') return category == option;
    if (id == 'emotionalState') return emotionalState == option;
    if (id == 'affordability' || id == 'affordabilityLevel') return affordabilityLevel == option;
    if (id == 'usageFrequency') return usageFrequency == option;
    if (id == 'willingToWait') return willingToWait == option;
    if (id == 'hasCheckedDeals') return hasCheckedDeals == option;
    if (id == 'necessity') return necessity == option;
    if (id == 'utility') return utility == option;
    if (id == 'sentiment') return sentiment == option;
    if (id == 'resaleValue') return resaleValue == option;
    
    // Default check (for new fields not explicitly mapped to a named var yet)
    // In a real app we'd have a Map<String, String> _answers
    return false;
  }

  void _setSingle(String id, String option) {
    bool shouldAdvance = true;
    
    if (id == 'wantDuration') onWantDurationChanged(option);
    else if (id == 'category') onCategoryChanged(option);
    else if (id == 'emotionalState') onEmotionalStateChanged(option);
    else if (id == 'affordability' || id == 'affordabilityLevel') onAffordabilityChanged(option);
    else if (id == 'usageFrequency') onUsageChanged(option);
    else if (id == 'willingToWait') onWaitChanged(option);
    else if (id == 'hasCheckedDeals') onDealsChanged(option);
    else if (id == 'necessity') onNecessityChanged(option);
    else if (id == 'utility') onUtilityChanged(option);
    else if (id == 'sentiment') onSentimentChanged(option);
    else if (id == 'resaleValue') onResaleValueChanged(option);
    else {
      // Generic
      onGenericChanged(id, option);
    }
    
    if (shouldAdvance) {
      Future.delayed(const Duration(milliseconds: 300), onNext);
    }
  }
}
