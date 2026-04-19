import 'package:flutter/material.dart';

import '../ui/app/view_model/app_view_model.dart';
import '../ui/home/widgets/home_screen.dart';

abstract class AppRoutes {
  static const home = '/';

  static Map<String, WidgetBuilder> routes(AppViewModel appViewModel) {
    return {home: (_) => HomeScreen(appViewModel: appViewModel)};
  }
}
