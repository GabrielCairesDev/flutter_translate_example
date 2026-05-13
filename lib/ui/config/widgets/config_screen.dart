import 'package:flutter/material.dart';
import 'package:flutter_translate_example/domain/app_locales.dart';
import 'package:flutter_translate_example/domain/locale_labels.dart';
import 'package:flutter_translate_example/l10n/context_l10n.dart';
import 'package:flutter_translate_example/ui/config/view_model/config_view_model.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key, required this.viewModel});

  final ConfigViewModel viewModel;

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.config)),
      body: Center(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) => _LocaleDropdown(viewModel: widget.viewModel),
        ),
      ),
    );
  }
}

class _LocaleDropdown extends StatelessWidget {
  const _LocaleDropdown({required this.viewModel});

  final ConfigViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final currentCode = viewModel.currentLocaleCode;
    final entries = appLocaleLabels.entries
        .map(
          (e) => DropdownMenuEntry<String>(value: e.key, label: e.value),
        )
        .toList(growable: false);

    return DropdownMenu<String>(
      key: ValueKey(currentCode),
      initialSelection: currentCode,
      enableFilter: false,
      requestFocusOnTap: false,
      dropdownMenuEntries: entries,
      onSelected: (String? code) {
        if (code == null || code == currentCode) return;
        viewModel.setLocale(localeFromCode(code));
      },
    );
  }
}
