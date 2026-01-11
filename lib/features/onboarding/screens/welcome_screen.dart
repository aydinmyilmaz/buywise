import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/content/strings.dart';
import '../../../config/theme/spacing_tokens.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/atmosphere_background.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: AtmosphereBackground(
        accents: [
          theme.colorScheme.primary,
          theme.colorScheme.secondary,
        ],
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(SpacingTokens.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(flex: 1),

                          // Hero Section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: SpacingTokens.md,
                                  vertical: SpacingTokens.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  '🧠 AI-Powered',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: SpacingTokens.lg),
                              Text(
                                'Should I Buy This?',
                                style: theme.textTheme.displayLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: SpacingTokens.md),
                              Text(
                                'Make confident, guilt-free purchase decisions with personalized AI guidance.',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: SpacingTokens.xxl),

                          // Feature Cards
                          _FeatureCard(
                            icon: '💰',
                            title: 'Save Money',
                            description: 'Track spending, avoid impulse buys, and stay within budget',
                            color: Colors.green,
                          ),
                          const SizedBox(height: SpacingTokens.md),
                          _FeatureCard(
                            icon: '🧘',
                            title: 'No Guilt',
                            description: 'Empathetic guidance that understands your feelings',
                            color: Colors.purple,
                          ),
                          const SizedBox(height: SpacingTokens.md),
                          _FeatureCard(
                            icon: '⏰',
                            title: 'Smart Waiting',
                            description: 'Set reminders to reconsider purchases later',
                            color: Colors.orange,
                          ),

                          const Spacer(flex: 2),

                          // CTA Button
                          AppButton(
                            label: 'Get Started',
                            onPressed: () => context.go('/gender'),
                          ),

                          const SizedBox(height: SpacingTokens.md),

                          // Trust Indicator
                          Center(
                            child: Text(
                              'Free • No signup required • Private',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ),

                          const SizedBox(height: SpacingTokens.lg),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
