import 'package:flutter/material.dart';

import 'app.dart';
import 'branding/branding_config.dart';

void main() {
  const brandKey = String.fromEnvironment('APP_BRAND', defaultValue: 'studentlyai');
  final brand = AppBrandExtension.fromKey(brandKey);
  runApp(McCaigsApp(brand: brand));
}
