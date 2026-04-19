import 'package:flutter/material.dart';

import 'core/di/service_locator.dart';
import 'l10n/app_localizations.dart';
import 'routing/app_routes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final appViewModel = ServiceLocator.instance.appViewModel;
    return ListenableBuilder(
      listenable: appViewModel,
      builder: (context, _) {
        return MaterialApp(
          title: 'Flutter Translate Example',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: appViewModel.locale,
          initialRoute: AppRoutes.home,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
