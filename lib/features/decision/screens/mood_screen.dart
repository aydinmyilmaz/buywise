import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/content/strings.dart';
import '../../../config/theme/spacing_tokens.dart';
import '../../../core/providers/decision_provider.dart';
import '../widgets/mood_selector.dart';
import '../../../shared/widgets/app_button.dart';

class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final decisionProvider = context.watch<DecisionProvider>();
    final theme = Theme.of(context);
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
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Text(Strings.moodWaveEmoji, style: theme.textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(Strings.moodGreeting, style: theme.textTheme.headlineMedium),
              const SizedBox(height: SpacingTokens.xs),
              Text(Strings.moodPrompt, style: theme.textTheme.bodyLarge),
              const SizedBox(height: SpacingTokens.lg),
              MoodSelector(
                selectedId: decisionProvider.moodId,
                onSelect: (id) => context.read<DecisionProvider>().setMood(id),
              ),
              const Spacer(),
              AppButton(
                label: Strings.continueLabel,
                onPressed: decisionProvider.moodId == null ? null : () => context.push('/product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
