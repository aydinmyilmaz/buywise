import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/content/strings.dart';
import '../../../config/theme/spacing_tokens.dart';
import '../../../core/providers/history_provider.dart';
import '../../../core/utils/date_formatter.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();
    final items = historyProvider.items;
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.history)),
      body: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: items.isEmpty
            ? const Center(child: Text(Strings.emptyHistory))
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.productName),
                      subtitle: Text(DateFormatter.friendly(item.createdAt)),
                      trailing: Text(item.decision.toUpperCase()),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
