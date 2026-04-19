import 'package:flutter/material.dart';

import 'data/repositories/locale_repository.dart';
import 'l10n/app_localizations.dart';
import 'routing/app_routes.dart';
import 'ui/app/view_model/app_view_model.dart';

class App extends StatefulWidget {
  const App({super.key, required this.localeRepository});

  final LocaleRepository localeRepository;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AppViewModel(widget.localeRepository);
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
        return MaterialApp(
          title: 'Flutter Translate Example',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: _viewModel.locale,
          initialRoute: AppRoutes.home,
          routes: AppRoutes.routes(_viewModel),
        );
      },
    );
  }
}
