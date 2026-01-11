import 'package:flutter/material.dart';
import '../../config/theme/spacing_tokens.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool secondary;

  const AppButton({super.key, required this.label, this.onPressed, this.secondary = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (secondary) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
            side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.4)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          onPressed: onPressed,
          child: Text(label),
        ),
      );
    }

    final isDisabled = onPressed == null;
    return SizedBox(
      width: double.infinity,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1,
        child: Material(
          borderRadius: BorderRadius.circular(18),
          elevation: isDisabled ? 0 : 8,
          shadowColor: theme.colorScheme.primary.withOpacity(0.25),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
                child: Center(
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
