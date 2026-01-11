import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/content/strings.dart';
import '../../../config/theme/spacing_tokens.dart';
import '../../../core/providers/history_provider.dart';
import '../../../core/providers/decision_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../core/utils/date_formatter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>().items;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/history'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Strings.homeGreeting, style: theme.textTheme.headlineMedium),
            const SizedBox(height: SpacingTokens.sm),
            Text(Strings.moodCheck, style: theme.textTheme.bodyLarge),
            const SizedBox(height: SpacingTokens.lg),
            AppButton(
              label: Strings.startNewDecision,
              onPressed: () {
                context.read<DecisionProvider>().reset();
                context.push('/mood');
              },
            ),
            const SizedBox(height: SpacingTokens.xl),
            Text(Strings.recentDecisions, style: theme.textTheme.titleLarge),
            const SizedBox(height: SpacingTokens.sm),
            Expanded(
              child: history.isEmpty
                  ? Center(child: Text(Strings.emptyHistory, textAlign: TextAlign.center))
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        return Card(
                          child: ListTile(
                            title: Text(item.productName),
                            subtitle: Text('${item.headline}\n${DateFormatter.friendly(item.createdAt)}'),
                            trailing: Text(item.decision.toUpperCase()),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
