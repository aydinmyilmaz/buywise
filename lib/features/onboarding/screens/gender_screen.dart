import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/content/strings.dart';
import '../../../config/theme/color_tokens.dart';
import '../../../config/theme/spacing_tokens.dart';
import '../../../core/providers/theme_provider.dart';

class GenderScreen extends StatelessWidget {
  const GenderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.chooseVibe)),
      body: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Strings.chooseVibe, style: theme.textTheme.titleLarge),
            const SizedBox(height: SpacingTokens.md),
            Row(
              children: [
                _GenderCard(
                  label: Strings.feminineLabel,
                  emoji: ColorTokens.feminineEmoji,
                  onTap: () {
                    context.read<ThemeProvider>().setGender('female');
                    context.go('/survey', extra: 'female');
                  },
                  selected: context.watch<ThemeProvider>().isFeminine,
                ),
                const SizedBox(width: SpacingTokens.md),
                _GenderCard(
                  label: Strings.masculineLabel,
                  emoji: ColorTokens.masculineEmoji,
                  onTap: () {
                    context.read<ThemeProvider>().setGender('male');
                    context.go('/survey', extra: 'male');
                  },
                  selected: !context.watch<ThemeProvider>().isFeminine,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final String emoji;
  final VoidCallback onTap;
  final bool selected;

  const _GenderCard({required this.label, required this.emoji, required this.onTap, required this.selected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(SpacingTokens.xl),
          decoration: BoxDecoration(
            color: selected ? theme.colorScheme.primary.withOpacity(0.12) : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: SpacingTokens.sm),
              Text(label, style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
