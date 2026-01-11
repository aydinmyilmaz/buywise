import 'package:flutter/material.dart';
import '../../../config/content/mood_options.dart';
import '../../../config/theme/spacing_tokens.dart';

class MoodSelector extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<String> onSelect;

  const MoodSelector({super.key, required this.selectedId, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: SpacingTokens.md,
      crossAxisSpacing: SpacingTokens.md,
      children: MoodOptions.options
          .map(
            (mood) => GestureDetector(
              onTap: () => onSelect(mood['id']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(SpacingTokens.md),
                decoration: BoxDecoration(
                  color: selectedId == mood['id']
                      ? theme.colorScheme.primary.withOpacity(0.14)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selectedId == mood['id']
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                  boxShadow: [
                    if (selectedId == mood['id'])
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(mood['emoji']!, style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: SpacingTokens.sm),
                    Text(mood['label']!, style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
