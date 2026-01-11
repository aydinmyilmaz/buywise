import 'package:flutter/material.dart';
import '../../../config/theme/spacing_tokens.dart';
import 'select_option.dart';

class MultiSelect extends StatelessWidget {
  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const MultiSelect({super.key, required this.options, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: options
          .map(
            (option) => SelectOption(
              label: option,
              selected: selected.contains(option),
              onTap: () {
                final updated = List<String>.from(selected);
                if (updated.contains(option)) {
                  updated.remove(option);
                } else {
                  updated.add(option);
                }
                onChanged(updated);
              },
            ),
          )
          .toList(),
    );
  }
}
