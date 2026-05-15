import 'package:flutter/material.dart';
import 'package:flutter_translate_example/l10n/context_l10n.dart';
import 'package:flutter_translate_example/ui/core/routing/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(context.l10n.helloWorld)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.config),
        child: const Icon(Icons.settings),
      ),
    );
  }
}
