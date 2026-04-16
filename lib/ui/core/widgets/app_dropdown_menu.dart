import 'dart:collection';

import 'package:flutter/material.dart';

class AppDropdownMenu extends StatefulWidget {
  const AppDropdownMenu({
    super.key,
    required this.list,
    required this.initialValue,
    required this.onSelected,
  });

  final List<String> list;
  final String initialValue;
  final ValueChanged<String> onSelected;

  @override
  State<AppDropdownMenu> createState() => _AppDropdownMenuState();
}

class _AppDropdownMenuState extends State<AppDropdownMenu> {
  late String _selected = widget.initialValue;

  @override
  void didUpdateWidget(AppDropdownMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _selected = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuEntries = UnmodifiableListView<DropdownMenuEntry<String>>(
      widget.list.map((name) => DropdownMenuEntry<String>(value: name, label: name)),
    );

    return DropdownMenu<String>(
      initialSelection: _selected,
      enableFilter: false,
      requestFocusOnTap: false,
      onSelected: (String? value) {
        if (value == null) return;
        setState(() => _selected = value);
        widget.onSelected(value);
      },
      dropdownMenuEntries: menuEntries,
    );
  }
}
