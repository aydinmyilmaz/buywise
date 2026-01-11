import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/content/strings.dart';
import '../../../config/theme/color_tokens.dart';
import '../../../config/theme/spacing_tokens.dart';
import '../../../core/providers/decision_provider.dart';
import '../../../core/providers/history_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_button.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.9, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _decisionColor(String decision) {
    switch (decision) {
      case 'yes':
        return ColorTokens.decisionYes;
      case 'leaning_yes':
        return ColorTokens.decisionLeaningYes;
      case 'wait':
        return ColorTokens.decisionWait;
      case 'leaning_no':
      default:
        return ColorTokens.decisionLeaningNo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final decisionProvider = context.watch<DecisionProvider>();
    final result = decisionProvider.result;
    final purchase = decisionProvider.purchase;
    final theme = Theme.of(context);

    if (result == null || purchase == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(Strings.resultTitle)),
        body: const Center(child: Text('No result yet.')),
      );
    }

    final decisionColor = _decisionColor(result.decision);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/home'),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Expanded(child: Text(Strings.resultTitle, style: theme.textTheme.titleLarge)),
                ],
              ),
              const SizedBox(height: SpacingTokens.md),
              Expanded(
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: ScaleTransition(
                      scale: _scale,
                      child: Container(
                        padding: const EdgeInsets.all(SpacingTokens.lg),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              decisionColor.withOpacity(0.18),
                              theme.colorScheme.surface,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: decisionColor.withOpacity(0.2),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: SpacingTokens.sm,
                                      vertical: SpacingTokens.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: decisionColor.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(result.decision.toUpperCase()),
                                  ),
                                  const SizedBox(width: SpacingTokens.md),
                                  Expanded(
                                    child: Text(result.headline, style: theme.textTheme.titleLarge),
                                  ),
                                ],
                              ),
                              const SizedBox(height: SpacingTokens.md),
                              Text(result.message, style: theme.textTheme.bodyLarge),
                              const SizedBox(height: SpacingTokens.lg),
                              if (result.costAnalysis.isNotEmpty) ...[
                                Text('Cost Analysis', style: theme.textTheme.titleMedium),
                                const SizedBox(height: SpacingTokens.sm),
                                ...result.costAnalysis.entries
                                    .where((entry) => entry.value != null)
                                    .map((entry) => Padding(
                                          padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                                          child: Text('${entry.key}: ${entry.value}'),
                                        )),
                                const SizedBox(height: SpacingTokens.md),
                              ],
                              Text('Peer insight: ${result.peerInsight}'),
                              if (result.mindsetNote != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: SpacingTokens.sm),
                                  child: Text('Mindset: ${result.mindsetNote}'),
                                ),
                              if (result.emotionalNote != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: SpacingTokens.sm),
                                  child: Text('Emotional: ${result.emotionalNote}'),
                                ),
                              if (result.alternatives != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: SpacingTokens.sm),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Alternatives', style: theme.textTheme.titleMedium),
                                      ...result.alternatives!.map((alt) => Text('• $alt')),
                                    ],
                                  ),
                                ),
                              if (result.waitSuggestion != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: SpacingTokens.sm),
                                  child: Text(
                                    'Wait suggestion: ${result.waitSuggestion!['days']} days — ${result.waitSuggestion!['reason']}',
                                  ),
                                ),
                              const SizedBox(height: SpacingTokens.lg),
                              Text('Action items', style: theme.textTheme.titleMedium),
                              ...result.actionItems.map((item) => Text('• $item')),
                              const SizedBox(height: SpacingTokens.lg),
                              Text(
                                'Price: ${CurrencyFormatter.format(purchase.price, currency: purchase.currency)}',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              AppButton(
                label: Strings.saveDecision,
                onPressed: () async {
                  await context.read<HistoryProvider>().add(purchase, result);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to history')));
                },
              ),
              const SizedBox(height: SpacingTokens.sm),
              AppButton(
                label: Strings.startNewDecision,
                secondary: true,
                onPressed: () {
                  context.read<DecisionProvider>().reset();
                  context.go('/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
