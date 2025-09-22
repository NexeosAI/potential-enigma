import 'package:flutter/material.dart';

enum AppBrand {
  studentlyAi,
  studentsAiUk,
  studentsAiUs,
}

extension AppBrandExtension on AppBrand {
  static AppBrand fromKey(String key) {
    switch (key.toLowerCase()) {
      case 'studentlyai':
        return AppBrand.studentlyAi;
      case 'studentsai_uk':
        return AppBrand.studentsAiUk;
      case 'studentsai_us':
        return AppBrand.studentsAiUs;
      default:
        return AppBrand.studentlyAi;
    }
  }

  BrandConfig get config {
    switch (this) {
      case AppBrand.studentlyAi:
        return const BrandConfig(
          key: 'studentlyai',
          displayName: 'StudentlyAI',
          tagline: 'Your local-first study companion.',
          currency: '£',
          tierPrices: [29, 49, 99, 149],
          primaryColor: Color(0xFFF97316),
          accentColor: Colors.white,
          brightness: Brightness.light,
        );
      case AppBrand.studentsAiUk:
        return const BrandConfig(
          key: 'studentsai_uk',
          displayName: 'StudentsAI UK',
          tagline: 'Academic excellence for UK learners.',
          currency: '£',
          tierPrices: [29, 49, 99, 149],
          primaryColor: Color(0xFF1E3A8A),
          accentColor: Color(0xFF0EA5E9),
          brightness: Brightness.dark,
        );
      case AppBrand.studentsAiUs:
        return const BrandConfig(
          key: 'studentsai_us',
          displayName: 'StudentsAI US',
          tagline: 'Study smarter with trusted AI.',
          currency: '$',
          tierPrices: [29, 49, 99, 149],
          primaryColor: Color(0xFF0369A1),
          accentColor: Color(0xFF38BDF8),
          brightness: Brightness.light,
        );
    }
  }
}

class BrandConfig {
  const BrandConfig({
    required this.key,
    required this.displayName,
    required this.tagline,
    required this.currency,
    required this.tierPrices,
    required this.primaryColor,
    required this.accentColor,
    required this.brightness,
  });

  final String key;
  final String displayName;
  final String tagline;
  final String currency;
  final List<int> tierPrices;
  final Color primaryColor;
  final Color accentColor;
  final Brightness brightness;

  ThemeData themeData() {
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: baseColorScheme.copyWith(secondary: accentColor),
      scaffoldBackgroundColor:
          brightness == Brightness.dark ? const Color(0xFF0F172A) : Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor:
            brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      chipTheme: ChipThemeData.fromDefaults(
        secondaryColor: accentColor,
        brightness: brightness,
      ),
    );
  }
}
