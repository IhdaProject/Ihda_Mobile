import 'package:flutter/material.dart';

import 'main_shell.dart';

/// Centralized route table. The bottom-nav tabs themselves are handled by
/// [MainShell]; this is for any screen you push on top of it later
/// (e.g. a prayer detail sheet, an about page).
class AppRoutes {
  AppRoutes._();

  static const home = '/';

  static Map<String, WidgetBuilder> get routes => {
        // The default route '/' is handled by the 'home' property in NamazTimingApp
        // Add other routes here as the app grows
      };
}
