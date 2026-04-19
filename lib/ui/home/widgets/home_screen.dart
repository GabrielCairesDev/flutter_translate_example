import 'package:flutter/material.dart';
import 'package:flutter_translate_example/l10n/context_l10n.dart';
import 'package:flutter_translate_example/ui/core/widgets/app_dropdown_menu.dart';

import '../../app/view_model/app_view_model.dart';
import '../view_model/home_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.appViewModel});

  final AppViewModel appViewModel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(widget.appViewModel);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 20,
              children: [
                Text(context.l10n.helloWorld),
                AppDropdownMenu(
                  list: _viewModel.availableLocales,
                  initialValue: _viewModel.currentLocale,
                  onSelected: (value) => _viewModel.setLocale(value),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
