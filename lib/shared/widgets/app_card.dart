import 'package:flutter/material.dart';
import '../../config/theme/spacing_tokens.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const AppCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: child,
      ),
    );
    if (onTap != null) {
      return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: card);
    }
    return card;
  }
}
