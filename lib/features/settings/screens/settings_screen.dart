import 'package:flutter/material.dart';
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
    final themeProvider = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.settings)),
      body: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text(Strings.appearance),
              subtitle: Text(themeProvider.isFeminine ? 'Feminine' : 'Masculine'),
              value: themeProvider.isFeminine,
              onChanged: (_) => themeProvider.toggle(),
            ),
            ListTile(
              title: const Text(Strings.clearData),
              trailing: const Icon(Icons.delete_outline),
              onTap: () async {
                await context.read<UserProvider>().clear();
                await context.read<HistoryProvider>().clear();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data cleared')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
