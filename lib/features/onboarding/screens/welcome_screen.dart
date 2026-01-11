import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/content/strings.dart';
import '../../../config/theme/spacing_tokens.dart';
import '../../../shared/widgets/app_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Strings.appTitle, style: theme.textTheme.displayLarge),
            const SizedBox(height: SpacingTokens.sm),
            Text(Strings.welcomeSubtitle, style: theme.textTheme.bodyLarge),
            const SizedBox(height: SpacingTokens.xl),
            AppButton(
              label: Strings.getStarted,
              onPressed: () => context.go('/gender'),
            ),
          ],
        ),
      ),
    );
  }
}
