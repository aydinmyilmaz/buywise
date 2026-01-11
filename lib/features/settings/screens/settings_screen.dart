import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/content/strings.dart';
import '../../../config/theme/spacing_tokens.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/history_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.settings),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personal Profile Section
            _SectionHeader(title: Strings.personalProfile),
            
            if (profile != null) ...[
              // Profile summary card
              Container(
                margin: const EdgeInsets.only(bottom: SpacingTokens.md),
                padding: const EdgeInsets.all(SpacingTokens.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withOpacity(0.2),
                                theme.colorScheme.secondary.withOpacity(0.2),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 32,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Profile',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${profile.ageGroup} • ${profile.country}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: SpacingTokens.lg),
                    const Divider(),
                    const SizedBox(height: SpacingTokens.sm),
                    
                    // Profile fields
                    _ProfileField(
                      icon: Icons.attach_money,
                      label: 'Monthly Income',
                      value: profile.monthlyIncome,
                    ),
                    _ProfileField(
                      icon: Icons.flag,
                      label: 'Primary Goal',
                      value: profile.primaryGoal,
                    ),
                    _ProfileField(
                      icon: Icons.credit_card,
                      label: 'Spending Style',
                      value: profile.spendingStyle,
                    ),
                    _ProfileField(
                      icon: Icons.account_balance_wallet,
                      label: 'Fun Budget',
                      value: profile.hasFunBudget,
                    ),
                    _ProfileField(
                      icon: Icons.psychology,
                      label: 'Spending Feelings',
                      value: profile.spendingGuilt,
                    ),
                    _ProfileField(
                      icon: Icons.shopping_bag,
                      label: 'Last Self Purchase',
                      value: profile.lastSelfPurchase,
                    ),
                    _ProfileField(
                      icon: Icons.lightbulb,
                      label: 'Decision Style',
                      value: profile.decisionStyle,
                    ),
                    _ProfileField(
                      icon: Icons.schedule,
                      label: 'Preferred Wait Time',
                      value: profile.preferredWaitTime,
                      isLast: true,
                    ),
                    
                    const SizedBox(height: SpacingTokens.md),
                    
                    // Edit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/edit-profile'),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // No profile yet
              Container(
                padding: const EdgeInsets.all(SpacingTokens.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.error),
                    const SizedBox(width: SpacingTokens.md),
                    const Expanded(
                      child: Text('No profile found. Please complete onboarding.'),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: SpacingTokens.xl),
            
            // App Settings Section
            _SectionHeader(title: Strings.appSettings),
            
            SwitchListTile(
              title: const Text(Strings.appearance),
              subtitle: Text(themeProvider.isFeminine ? 'Feminine' : 'Masculine'),
              value: themeProvider.isFeminine,
              onChanged: (_) => themeProvider.toggle(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: theme.colorScheme.surface,
            ),
            
            const SizedBox(height: SpacingTokens.md),
            
            // Danger zone
            const SizedBox(height: SpacingTokens.lg),
            _SectionHeader(title: 'Danger Zone'),
            
            ListTile(
              title: const Text(
                Strings.clearData,
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Delete all your data and start fresh'),
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.red.withOpacity(0.3)),
              ),
              tileColor: Colors.red.withOpacity(0.05),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Data?'),
                    content: const Text(
                      'This will delete your profile and all purchase history. This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete Everything'),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true && context.mounted) {
                  await context.read<UserProvider>().clear();
                  await context.read<HistoryProvider>().clear();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data cleared')),
                  );
                  context.go('/welcome');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _ProfileField({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : SpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary.withOpacity(0.7),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'Not set' : value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: value.isEmpty 
                        ? theme.colorScheme.onSurface.withOpacity(0.4)
                        : theme.colorScheme.onSurface,
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
