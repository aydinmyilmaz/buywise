import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/content/strings.dart';
import '../../../config/theme/spacing_tokens.dart';
import '../../../core/providers/history_provider.dart';
import '../../../core/providers/decision_provider.dart';
import '../../../core/providers/pending_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/atmosphere_background.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/currency_formatter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>().items;
    final pending = context.watch<PendingProvider>().items;
    final userProfile = context.watch<UserProvider>().profile;
    final theme = Theme.of(context);

    return Scaffold(
      body: AtmosphereBackground(
        accents: [
          theme.colorScheme.primary,
          theme.colorScheme.secondary,
        ],
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              expandedHeight: 120,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: SpacingTokens.lg, bottom: SpacingTokens.md),
                title: Text(
                  Strings.appTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push('/settings'),
                ),
                const SizedBox(width: SpacingTokens.sm),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back${userProfile?.ageGroup != null ? '' : ''}', // Could personalise if we had name
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xl),
                    
                    // Main Action Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(SpacingTokens.xl),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: SpacingTokens.lg),
                          const Text(
                            'Thinking of buying something?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: SpacingTokens.xs),
                          const Text(
                            'Let\'s analyze it together.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: SpacingTokens.xl),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<DecisionProvider>().reset();
                                context.push('/mood');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: theme.colorScheme.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text('New Decision', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: SpacingTokens.lg),

                    // Budget Tracker
                    if (userProfile?.funBudgetAmount != null && userProfile!.funBudgetAmount! > 0) ...[
                      _BudgetTrackerCard(
                        budgetAmount: userProfile.funBudgetAmount!,
                        spent: context.watch<HistoryProvider>().getMonthlySpending(userProfile.currency),
                        currency: userProfile.currency,
                      ),
                      const SizedBox(height: SpacingTokens.lg),
                    ],

                    // Pending Decisions Section
                    if (pending.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Waiting Decisions', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${pending.length}',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SpacingTokens.md),
                      ...pending.take(3).map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.withOpacity(0.1),
                                Colors.deepOrange.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: item.isReady
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.orange.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: SpacingTokens.md,
                              vertical: SpacingTokens.sm,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: item.isReady
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                              child: Icon(
                                item.isReady ? Icons.alarm_on : Icons.schedule,
                                color: item.isReady ? Colors.green : Colors.orange,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              item.productName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  CurrencyFormatter.format(item.price, item.currency),
                                  style: theme.textTheme.bodySmall,
                                ),
                                Text(
                                  item.timeRemainingText,
                                  style: TextStyle(
                                    color: item.isReady ? Colors.green : Colors.orange,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () async {
                                await context.read<PendingProvider>().remove(item.id);
                              },
                            ),
                          ),
                        ),
                      )),
                      const SizedBox(height: SpacingTokens.xl),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent History', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        if (history.isNotEmpty)
                          TextButton(
                            onPressed: () => context.push('/history'),
                            child: const Text('View All'),
                          ),
                      ],
                    ),
                    const SizedBox(height: SpacingTokens.md),
                  ],
                ),
              ),
            ),
            
            if (history.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(SpacingTokens.xxl),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.history, size: 48, color: theme.colorScheme.outline.withOpacity(0.5)),
                        const SizedBox(height: SpacingTokens.md),
                        Text(
                          Strings.emptyHistory,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = history[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg, vertical: SpacingTokens.xs),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
                          leading: CircleAvatar(
                            backgroundColor: _getDecisionColor(item.decision).withOpacity(0.1),
                            child: Icon(
                              _getDecisionIcon(item.decision),
                              color: _getDecisionColor(item.decision),
                              size: 20,
                            ),
                          ),
                          title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            DateFormatter.friendly(item.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                          ),
                          trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                          onTap: () {
                            // TODO: Add view history detail
                          },
                        ),
                      ),
                    );
                  },
                  childCount: history.length > 5 ? 5 : history.length, // Show max 5 on home
                ),
              ),
              
            const SliverPadding(padding: EdgeInsets.only(bottom: SpacingTokens.xxl)),
          ],
        ),
      ),
    );
  }

  Color _getDecisionColor(String decision) {
    switch (decision) {
      case 'yes': return Colors.green;
      case 'leaning_yes': return Colors.lightGreen;
      case 'wait': return Colors.orange;
      case 'leaning_no': return Colors.deepOrange;
      default: return Colors.grey;
    }
  }

  IconData _getDecisionIcon(String decision) {
    switch (decision) {
      case 'yes': return Icons.check_circle;
      case 'leaning_yes': return Icons.thumb_up;
      case 'wait': return Icons.hourglass_top;
      case 'leaning_no': return Icons.thumb_down;
      default: return Icons.help;
    }
  }
}

class _BudgetTrackerCard extends StatelessWidget {
  final double budgetAmount;
  final double spent;
  final String currency;

  const _BudgetTrackerCard({
    required this.budgetAmount,
    required this.spent,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = budgetAmount - spent;
    final progress = (spent / budgetAmount).clamp(0.0, 1.0);
    final isOverBudget = spent > budgetAmount;

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOverBudget
              ? [
                  Colors.red.withOpacity(0.15),
                  Colors.deepOrange.withOpacity(0.1),
                ]
              : [
                  Colors.green.withOpacity(0.12),
                  Colors.teal.withOpacity(0.08),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOverBudget
              ? Colors.red.withOpacity(0.3)
              : Colors.green.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isOverBudget ? Colors.red : Colors.green).withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isOverBudget ? Colors.red : Colors.green)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isOverBudget
                          ? Icons.warning_rounded
                          : Icons.account_balance_wallet_rounded,
                      color: isOverBudget ? Colors.red : Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Text(
                    'Monthly Budget',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                CurrencyFormatter.format(budgetAmount, currency),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.black.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.red : Colors.green,
              ),
            ),
          ),

          const SizedBox(height: SpacingTokens.md),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spent',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(spent, currency),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isOverBudget ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isOverBudget ? 'Over Budget' : 'Remaining',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(remaining.abs(), currency),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isOverBudget
                          ? Colors.red
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (isOverBudget) ...[
            const SizedBox(height: SpacingTokens.sm),
            Container(
              padding: const EdgeInsets.all(SpacingTokens.sm),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.red),
                  const SizedBox(width: SpacingTokens.xs),
                  Expanded(
                    child: Text(
                      'You\'ve exceeded your monthly budget. Consider waiting on future purchases.',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
