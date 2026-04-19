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
  late List<DropdownMenuEntry<String>> _menuEntries;

  @override
  void initState() {
    super.initState();
    _updateMenuEntries();
  }

  @override
  void didUpdateWidget(AppDropdownMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _selected = widget.initialValue;
    }
    if (oldWidget.list != widget.list) {
      _updateMenuEntries();
    }
  }

  void _updateMenuEntries() {
    _menuEntries = widget.list
        .map((name) => DropdownMenuEntry<String>(value: name, label: name))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      initialSelection: _selected,
      enableFilter: false,
      requestFocusOnTap: false,
      onSelected: (String? value) {
        if (value == null || value == _selected) return;
        setState(() => _selected = value);
        widget.onSelected(value);
      },
      dropdownMenuEntries: _menuEntries,
    );
  }
}
