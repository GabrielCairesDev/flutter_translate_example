import 'package:flutter/material.dart';

import 'data/services/locale_service.dart';
import 'l10n/app_localizations.dart';
import 'routing/app_routes.dart';

class App extends StatelessWidget {
  const App({super.key, required this.localeService});

  final LocaleService localeService;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: localeService,
      builder: (context, _) {
        return MaterialApp(
          title: 'Flutter Translate Example',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: localeService.locale,
          initialRoute: AppRoutes.home,
          routes: AppRoutes.routes(localeService),
        );
      },
    );
  }
}
