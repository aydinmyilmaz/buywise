import 'package:flutter/material.dart';
import '../../../config/theme/spacing_tokens.dart';

class QuestionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String icon;
  final Widget child;

  const QuestionCard({super.key, required this.title, this.subtitle, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: SpacingTokens.xs),
                          child: Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.md),
            child,
          ],
        ),
      ),
    );
  }
}
