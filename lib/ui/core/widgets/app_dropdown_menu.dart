import 'package:flutter/material.dart';

class AppDropdownMenu extends StatelessWidget {
  const AppDropdownMenu({
    super.key,
    required this.list,
    required this.selectedValue,
    required this.onSelected,
  });

  final List<String> list;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final entries = list
        .map((name) => DropdownMenuEntry<String>(value: name, label: name))
        .toList(growable: false);

    return DropdownMenu<String>(
      key: ValueKey(selectedValue),
      initialSelection: selectedValue,
      enableFilter: false,
      requestFocusOnTap: false,
      onSelected: (String? value) {
        if (value == null || value == selectedValue) return;
        onSelected(value);
      },
      dropdownMenuEntries: entries,
    );
  }
}
