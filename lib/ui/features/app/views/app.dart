import 'package:flutter/material.dart';
import 'package:flutter_translate_example/data/repositories/locale_repository.dart';
import 'package:flutter_translate_example/l10n/app_localizations.dart';
import 'package:flutter_translate_example/ui/core/routing/app_routes.dart';

class App extends StatelessWidget {
  const App({super.key, required this.localeRepository, required this.routes});

  final LocaleRepository localeRepository;
  final AppRoutes routes;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeRepository.localeListenable,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'Flutter Translate Example',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          onGenerateRoute: routes.onGenerateRoute,
        );
      },
    );
  }
}
