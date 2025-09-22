import 'package:flutter/material.dart';

import 'branding/branding_config.dart';
import 'modules/settings/settings_shell.dart';

class McCaigsApp extends StatelessWidget {
  const McCaigsApp({super.key, required this.brand});

  final AppBrand brand;

  @override
  Widget build(BuildContext context) {
    final config = brand.config;
    return MaterialApp(
      title: config.displayName,
      debugShowCheckedModeBanner: false,
      theme: config.themeData(),
      home: SettingsShell(brand: brand),
    );
  }
}
