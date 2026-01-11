import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/content/categories.dart';
import '../../../config/content/strings.dart';
import '../../../config/theme/spacing_tokens.dart';
import '../../../core/providers/decision_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/dashed_border.dart';

enum _ProductStep { choice, analyzing, details }

class ProductInputScreen extends StatefulWidget {
  const ProductInputScreen({super.key});

  @override
  State<ProductInputScreen> createState() => _ProductInputScreenState();
}

class _ProductInputScreenState extends State<ProductInputScreen> {
  final _productController = TextEditingController();
  final _priceController = TextEditingController();
  final _currencyController = TextEditingController(text: 'USD');
  String _category = CategoriesConfig.categories.first;
  bool _loadingImage = false;
  _ProductStep _step = _ProductStep.choice;

  @override
  void dispose() {
    _productController.dispose();
    _priceController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  void _continue() {
    final name = _productController.text.trim();
    final price = double.tryParse(_priceController.text) ?? 0;
    if (name.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Strings.productInputError)),
      );
      return;
    }
    context.push('/questions', extra: {
      'productName': name,
      'category': _category,
      'price': price,
      'currency': _currencyController.text.trim().isEmpty ? 'USD' : _currencyController.text.trim(),
    });
  }

  Future<void> _analyzePhoto() async {
    final provider = context.read<DecisionProvider>();
    setState(() {
      _loadingImage = true;
      _step = _ProductStep.analyzing;
    });
    final data = await provider.analyzeImage();
    if (!mounted) return;
    setState(() => _loadingImage = false);
    if (data == null || provider.productInfo == null) {
      setState(() => _step = _ProductStep.choice);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Strings.errorImage)),
      );
      return;
    }
    final info = provider.productInfo!;
    setState(() {
      _productController.text = info.productName;
      _category = info.category;
      _step = _ProductStep.details;
    });
  }

  Future<void> _pickPhoto() async {
    await context.read<DecisionProvider>().pickImage();
    if (!mounted) return;
    if (context.read<DecisionProvider>().imageBytes != null) {
      await _analyzePhoto();
    }
  }

  void _goManual() {
    setState(() => _step = _ProductStep.details);
  }

  Widget _buildStepIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final steps = [_ProductStep.choice, _ProductStep.analyzing, _ProductStep.details];
    return Row(
      children: steps.map((step) {
        final isActive = step.index <= _step.index;
        return Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.only(right: SpacingTokens.xs),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decisionProvider = context.watch<DecisionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.productInputTitle)),
      body: LoadingOverlay(
        loading: _loadingImage,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Strings.productInputTitle, style: theme.textTheme.headlineMedium),
                const SizedBox(height: SpacingTokens.xs),
                Text(Strings.productInputSubtitle, style: theme.textTheme.bodyLarge),
                const SizedBox(height: SpacingTokens.md),
                _buildStepIndicator(context),
                const SizedBox(height: SpacingTokens.lg),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: _step == _ProductStep.choice
                        ? _ChoiceStep(
                            key: const ValueKey('choice'),
                            onPickPhoto: _pickPhoto,
                            onManual: _goManual,
                          )
                        : _step == _ProductStep.analyzing
                            ? const _AnalyzingStep(key: ValueKey('analyzing'))
                            : _DetailsStep(
                                key: const ValueKey('details'),
                                category: _category,
                                onCategoryChanged: (val) => setState(() => _category = val),
                                productController: _productController,
                                priceController: _priceController,
                                currencyController: _currencyController,
                                autoFilled: decisionProvider.productInfo != null,
                                onSkipPhoto: () => setState(() => _step = _ProductStep.choice),
                              ),
                  ),
                ),
                AppButton(
                  label: Strings.continueLabel,
                  onPressed: _step == _ProductStep.details ? _continue : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceStep extends StatelessWidget {
  final VoidCallback onPickPhoto;
  final VoidCallback onManual;

  const _ChoiceStep({super.key, required this.onPickPhoto, required this.onManual});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Strings.productStepChooseTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: SpacingTokens.md),
        GestureDetector(
          onTap: onPickPhoto,
          child: DashedBorder(
            color: theme.colorScheme.primary,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SpacingTokens.xl),
              color: theme.colorScheme.primary.withOpacity(0.06),
              child: Column(
                children: [
                  const Text(Strings.uploadPhotoEmoji, style: TextStyle(fontSize: 36)),
                  const SizedBox(height: SpacingTokens.sm),
                  Text(Strings.uploadPhoto, style: theme.textTheme.titleMedium),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(Strings.uploadPhotoHelper, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        Center(child: Text(Strings.orLabel, style: theme.textTheme.bodyMedium)),
        const SizedBox(height: SpacingTokens.md),
        AppButton(label: Strings.enterDetailsManual, secondary: true, onPressed: onManual),
      ],
    );
  }
}

class _AnalyzingStep extends StatelessWidget {
  const _AnalyzingStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.18),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: SpacingTokens.sm),
            const CircularProgressIndicator(),
            const SizedBox(height: SpacingTokens.md),
            Text(Strings.productStepAnalyzeTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: SpacingTokens.xs),
            Text(Strings.productStepAnalyzeSubtitle, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _DetailsStep extends StatelessWidget {
  final String category;
  final ValueChanged<String> onCategoryChanged;
  final TextEditingController productController;
  final TextEditingController priceController;
  final TextEditingController currencyController;
  final bool autoFilled;
  final VoidCallback onSkipPhoto;

  const _DetailsStep({
    super.key,
    required this.category,
    required this.onCategoryChanged,
    required this.productController,
    required this.priceController,
    required this.currencyController,
    required this.autoFilled,
    required this.onSkipPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(Strings.productStepDetailsTitle, style: theme.textTheme.titleLarge),
              const Spacer(),
              TextButton(onPressed: onSkipPhoto, child: const Text(Strings.productStepSkipPhoto)),
            ],
          ),
          if (autoFilled) ...[
            const SizedBox(height: SpacingTokens.xs),
            Text(Strings.productStepAutoFilled, style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: SpacingTokens.md),
          TextField(
            controller: productController,
            decoration: const InputDecoration(labelText: Strings.productNameLabel),
          ),
          const SizedBox(height: SpacingTokens.sm),
          DropdownButtonFormField<String>(
            value: category,
            items: CategoriesConfig.categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (val) => onCategoryChanged(val ?? category),
            decoration: const InputDecoration(labelText: Strings.categoryLabel),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: Strings.priceLabel),
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
          ),
        ],
      ),
    );
  }
}
