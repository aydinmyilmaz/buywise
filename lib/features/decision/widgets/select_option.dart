import 'package:flutter/material.dart';
import '../../../config/theme/spacing_tokens.dart';

class SelectOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const SelectOption({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm, horizontal: SpacingTokens.md),
        margin: const EdgeInsets.only(right: SpacingTokens.sm, bottom: SpacingTokens.sm),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary.withOpacity(0.14) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? theme.colorScheme.primary : theme.colorScheme.outline),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.18),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
