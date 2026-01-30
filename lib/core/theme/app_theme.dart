import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_theme.g.dart';

@riverpod
ThemeData lightTheme(Ref ref) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.cyan,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: _buildTextTheme(colorScheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.audiowide(
        fontSize: 22,
        color: colorScheme.onSurface,
      ),
    ),
  );
}

@riverpod
ThemeData darkTheme(Ref ref) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.cyan,
    brightness: Brightness.dark,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: _buildTextTheme(colorScheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.audiowide(
        fontSize: 22,
        color: colorScheme.onSurface,
      ),
    ),
  );
}

TextTheme _buildTextTheme(ColorScheme colorScheme) {
  final baseTheme = GoogleFonts.outfitTextTheme();
  return baseTheme
      .copyWith(
        // Timer Display
        displayLarge: GoogleFonts.chivoMono(
          fontSize: 80,
          fontWeight: FontWeight.w300,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        // Scramble Display
        headlineSmall: GoogleFonts.chivoMono(
          fontSize: 24,
        ),
        // History List Time
        titleLarge: GoogleFonts.chivoMono(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      )
      .apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      );
}
