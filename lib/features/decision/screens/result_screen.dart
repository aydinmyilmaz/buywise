import 'dart:ui';
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
import '../../../shared/widgets/atmosphere_background.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeContent;
  late final Animation<double> _slideContent;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeContent = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideContent = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _decisionColor(String decision) {
    switch (decision) {
      case 'yes': return ColorTokens.decisionYes;
      case 'leaning_yes': return ColorTokens.decisionLeaningYes;
      case 'wait': return ColorTokens.decisionWait;
      case 'leaning_no': 
      default: return ColorTokens.decisionLeaningNo;
    }
  }

  IconData _decisionIcon(String decision) {
    switch (decision) {
      case 'yes': return Icons.verified_rounded;
      case 'leaning_yes': return Icons.thumb_up_rounded;
      case 'wait': return Icons.hourglass_top_rounded;
      case 'leaning_no': default: return Icons.thumb_down_rounded;
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
        appBar: AppBar(title: const Text('Result')),
        body: const Center(child: Text('No result found.')),
      );
    }

    final primaryColor = _decisionColor(result.decision);
    
    return Scaffold(
      body: AtmosphereBackground(
        accents: [primaryColor, theme.colorScheme.secondary],
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                children: [
                   // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg, vertical: SpacingTokens.sm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.go('/home'),
                        ),
                        Text('Your Insight', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const IconButton(
                          icon: Icon(Icons.share_outlined), // Placeholder for share
                          onPressed: null, 
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg, vertical: SpacingTokens.md),
                      child: Transform.translate(
                        offset: Offset(0, _slideContent.value),
                        child: Opacity(
                          opacity: _fadeContent.value,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. Hero Decision Card
                              _HeroDecisionCard(
                                decision: result.decision,
                                headline: result.headline,
                                message: result.message,
                                color: primaryColor,
                                icon: _decisionIcon(result.decision),
                              ),
                              const SizedBox(height: SpacingTokens.xl),

                              // 2. Logic / Reasoning
                              if (result.verdictReasoning != null) ...[
                                _SectionTitle(title: 'The Logic', color: theme.colorScheme.onSurface),
                                const SizedBox(height: SpacingTokens.sm),
                                _LogicCard(text: result.verdictReasoning!),
                                const SizedBox(height: SpacingTokens.xl),
                              ],

                              // 3. Pros & Cons (Grid-like)
                              if (result.pros != null || result.cons != null) ...[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (result.pros != null)
                                      Expanded(
                                        child: _ProsConsList(
                                          title: 'Pros',
                                          items: result.pros!,
                                          isPros: true,
                                        ),
                                      ),
                                    if (result.pros != null && result.cons != null)
                                      const SizedBox(width: SpacingTokens.md),
                                    if (result.cons != null)
                                      Expanded(
                                        child: _ProsConsList(
                                          title: 'Cons',
                                          items: result.cons!,
                                          isPros: false,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: SpacingTokens.xl),
                              ],

                              // 4. Key Stats / Analysis
                              _SectionTitle(title: 'Key Stats', color: theme.colorScheme.onSurface),
                              const SizedBox(height: SpacingTokens.sm),
                              _StatCard(
                                label: 'Cost',
                                value: CurrencyFormatter.format(purchase.price, currency: purchase.currency),
                                icon: Icons.attach_money,
                                color: primaryColor,
                              ),
                              if (result.costAnalysis['costPerUse'] != null)
                                _StatCard(
                                  label: 'Cost Per Use (est.)',
                                  value: result.costAnalysis['costPerUse'] ?? '',
                                  icon: Icons.repeat,
                                  color: Colors.orange,
                                ),
                              if (result.longTermValue != null)
                                _StatCard(
                                  label: 'Long Term Value',
                                  value: result.longTermValue!,
                                  icon: Icons.timeline,
                                  color: Colors.blue,
                                ),
                              _StatCard(
                                label: 'Peer Insight',
                                value: result.peerInsight,
                                icon: Icons.people_outline,
                                color: Colors.purple,
                                isTextBlocks: true,
                              ),

                              const SizedBox(height: SpacingTokens.xxl),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Actions
                  Transform.translate(
                    offset: Offset(0, _slideContent.value * 0.5),
                    child: Opacity(
                      opacity: _fadeContent.value,
                      child: Container(
                        padding: const EdgeInsets.all(SpacingTokens.lg),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor.withOpacity(0.9),
                          border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
                        ),
                        child: Column(
                          children: [
                            AppButton(
                              label: 'Save Decision',
                              onPressed: () async {
                                await context.read<HistoryProvider>().add(purchase, result);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Saved to history'), behavior: SnackBarBehavior.floating),
                                );
                              },
                            ),
                            const SizedBox(height: SpacingTokens.xs),
                            TextButton(
                              onPressed: () {
                                context.read<DecisionProvider>().reset();
                                context.go('/home');
                              },
                              child: Text('Start New Decision', style: TextStyle(color: theme.colorScheme.secondary)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeroDecisionCard extends StatelessWidget {
  final String decision;
  final String headline;
  final String message;
  final Color color;
  final IconData icon;

  const _HeroDecisionCard({
    required this.decision,
    required this.headline,
    required this.message,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg, vertical: SpacingTokens.xl),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              boxShadow: [
                 BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            ),
            child: Icon(icon, color: color, size: 40),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Text(
            decision.replaceAll('_', ' ').toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              letterSpacing: 2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogicCard extends StatelessWidget {
  final String text;
  const _LogicCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.6)),
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
        ),
      ),
    );
  }
}

class _ProsConsList extends StatelessWidget {
  final String title;
  final List<String> items;
  final bool isPros;

  const _ProsConsList({required this.title, required this.items, required this.isPros});

  @override
  Widget build(BuildContext context) {
    final color = isPros ? Colors.green : Colors.redAccent;
    final icon = isPros ? Icons.check_circle_outline : Icons.cancel_outlined;

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: SpacingTokens.xs),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                       color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isTextBlocks;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isTextBlocks = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: SpacingTokens.md),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.8)),
      ),
      child: Row(
        crossAxisAlignment: isTextBlocks ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  
  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: -0.5,
      ),
    );
  }
}
