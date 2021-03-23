import 'package:meena_supplies/ui/document_page.dart';
import 'package:meena_supplies/ui/files_page.dart';
import 'package:meena_supplies/ui/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Route onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoute.login:
      return MaterialPageRoute(
        builder: (context) => LoginPage(),
      );
    case AppRoute.files:
      return MaterialPageRoute(
        builder: (context) => FilesPage(),
      );
    case AppRoute.document:
      final args = settings.arguments as Map;
      return MaterialPageRoute(
        builder: (context) => DocumentPage(fileId: args[Args.fileId]),
      );
    default:
      return null;
  }
}

class Args {
  static const fileId = 'fileId';
}

class AppRoute {
  static const login = '/login';
  static const files = '/files';
  static const document = '/document';
}
