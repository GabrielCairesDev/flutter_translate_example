import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/routing/app_routes.dart';
import '../view_models/app_view_model.dart';

class App extends StatelessWidget {
  const App({super.key, required this.viewModel, required this.routes});

  final AppViewModel viewModel;
  final AppRoutes routes;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return MaterialApp(
          title: 'Flutter Translate Example',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: viewModel.locale,
          onGenerateRoute: routes.onGenerateRoute,
        );
      },
    );
  }
}
