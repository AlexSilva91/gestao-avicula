import 'package:flutter/material.dart';
import '../constants/design_tokens.dart';

abstract final class SeletoTheme {
  static const _seed = Color(0xFF176B4D);
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData _build(Brightness brightness) {
    final scheme =
        ColorScheme.fromSeed(seedColor: _seed, brightness: brightness).copyWith(
          primary: brightness == Brightness.light
              ? const Color(0xFF176B4D)
              : const Color(0xFF68D5A9),
          secondary: const Color(0xFFF1A83A),
          surface: brightness == Brightness.light
              ? const Color(0xFFFAFCFA)
              : const Color(0xFF101514),
        );
    final text = ThemeData(
      brightness: brightness,
    ).textTheme.apply(fontFamily: 'Roboto');
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: text.copyWith(
        displaySmall: text.displaySmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        headlineSmall: text.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
        ),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF5F8F5)
          : scheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        color: brightness == Brightness.light
            ? scheme.surface.withValues(alpha: .94)
            : scheme.surface.withValues(alpha: .9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SeletoTokens.radiusMd),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? Colors.white.withValues(alpha: .94)
            : scheme.surfaceContainerHighest.withValues(alpha: .92),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SeletoTokens.radiusSm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SeletoTokens.radiusSm),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, SeletoTokens.touchTargetMinimum),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SeletoTokens.radiusSm),
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        indicatorColor: scheme.primaryContainer,
        labelType: NavigationRailLabelType.all,
      ),
    );
  }
}
