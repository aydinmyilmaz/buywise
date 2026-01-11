import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/content/strings.dart';
import '../../../config/theme/spacing_tokens.dart';
import '../../../core/providers/history_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/currency_formatter.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();
    final userProvider = context.watch<UserProvider>();
    final items = historyProvider.items;
    final currency = userProvider.profile?.currency ?? 'USD';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.history)),
      body: items.isEmpty
          ? const Center(child: Text(Strings.emptyHistory))
          : ListView(
              padding: const EdgeInsets.all(SpacingTokens.md),
              children: [
                // Insights Card
                _InsightsCard(
                  decisionsThisMonth: historyProvider.decisionsThisMonth,
                  moneySaved: historyProvider.getMoneySaved(currency),
                  currency: currency,
                  impulseBuysAvoided: historyProvider.impulseBuysAvoided,
                  mostCommonDecision: historyProvider.mostCommonDecision,
                ),
                const SizedBox(height: SpacingTokens.lg),

                // Section Title
                Text(
                  'Recent Decisions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: SpacingTokens.sm),

                // History List
                ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                  child: Card(
                    child: ListTile(
                      title: Text(item.productName),
                      subtitle: Text(
                        '${CurrencyFormatter.format(item.price, currency: item.currency)} • ${DateFormatter.friendly(item.createdAt)}',
                      ),
                      trailing: _DecisionBadge(decision: item.decision),
                    ),
                  ),
                )),
              ],
            ),
    );
  }
}

class _InsightsCard extends StatelessWidget {
  final int decisionsThisMonth;
  final double moneySaved;
  final String currency;
  final int impulseBuysAvoided;
  final String mostCommonDecision;

  const _InsightsCard({
    required this.decisionsThisMonth,
    required this.moneySaved,
    required this.currency,
    required this.impulseBuysAvoided,
    required this.mostCommonDecision,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.6),
            theme.colorScheme.secondaryContainer.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(SpacingTokens.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.insights_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Text(
                'Your Insights',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.lg),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _InsightStat(
                  icon: '📊',
                  label: 'This Month',
                  value: '$decisionsThisMonth',
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: _InsightStat(
                  icon: '💰',
                  label: 'Money Saved',
                  value: CurrencyFormatter.format(moneySaved, currency: currency),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Row(
            children: [
              Expanded(
                child: _InsightStat(
                  icon: '🎯',
                  label: 'Impulses Avoided',
                  value: '$impulseBuysAvoided',
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: _InsightStat(
                  icon: '📈',
                  label: 'Most Common',
                  value: mostCommonDecision.toUpperCase(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightStat extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _InsightStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DecisionBadge extends StatelessWidget {
  final String decision;

  const _DecisionBadge({required this.decision});

  Color _getColor(BuildContext context, String decision) {
    final theme = Theme.of(context);
    switch (decision.toLowerCase()) {
      case 'yes':
        return Colors.green;
      case 'leaning_yes':
        return Colors.lightGreen;
      case 'wait':
        return Colors.orange;
      case 'leaning_no':
        return Colors.deepOrange;
      case 'no':
        return Colors.red;
      default:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context, decision);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        decision.toUpperCase().replaceAll('_', ' '),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
