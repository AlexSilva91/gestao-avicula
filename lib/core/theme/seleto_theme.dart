import 'package:flutter/material.dart';
import '../constants/design_tokens.dart';

abstract final class SeletoTheme {
  static const _seed = Color(0xFF176B4D);
  static const _lightSurface = Color(0xFFF7F9F6);
  static const _lightPanel = Color(0xFFFEFFFC);
  static const _darkSurface = Color(0xFF101514);
  static const _darkPanel = Color(0xFF151B19);
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData _build(Brightness brightness) {
    final light = brightness == Brightness.light;
    final scheme =
        ColorScheme.fromSeed(seedColor: _seed, brightness: brightness).copyWith(
          primary: light ? const Color(0xFF176B4D) : const Color(0xFF68D5A9),
          secondary: light ? const Color(0xFFE39A27) : const Color(0xFFFFC36B),
          tertiary: light ? const Color(0xFF2F5F8F) : const Color(0xFF9DCBFF),
          surface: light ? _lightSurface : _darkSurface,
          surfaceContainerLowest: light ? _lightPanel : _darkPanel,
          surfaceContainerLow: light
              ? const Color(0xFFF0F4EF)
              : const Color(0xFF18201D),
          surfaceContainer: light
              ? const Color(0xFFEAF0E8)
              : const Color(0xFF1D2622),
        );
    final text = ThemeData(
      brightness: brightness,
    ).textTheme.apply(fontFamily: 'Roboto');
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      visualDensity: VisualDensity.compact,
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
      scaffoldBackgroundColor: light ? _lightSurface : scheme.surface,
      cardTheme: CardThemeData(
        elevation: light ? 1 : 0,
        shadowColor: Colors.black.withValues(alpha: light ? .08 : .32),
        margin: const EdgeInsets.all(3),
        surfaceTintColor: Colors.transparent,
        color: light
            ? scheme.surfaceContainerLowest.withValues(alpha: .98)
            : scheme.surfaceContainerLow.withValues(alpha: .96),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .62)),
          borderRadius: BorderRadius.circular(SeletoTokens.radiusMd),
        ),
      ),
      listTileTheme: ListTileThemeData(
        dense: true,
        minLeadingWidth: 24,
        horizontalTitleGap: 10,
        minVerticalPadding: 8,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        iconColor: scheme.onSurfaceVariant,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        selectedColor: scheme.primaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .76)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SeletoTokens.radiusSm),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: scheme.outlineVariant,
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: light
            ? scheme.surfaceContainerLowest.withValues(alpha: .98)
            : scheme.surfaceContainerHighest.withValues(alpha: .92),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SeletoTokens.radiusSm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SeletoTokens.radiusSm),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: .86),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SeletoTokens.radiusSm),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, SeletoTokens.touchTargetMinimum),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SeletoTokens.radiusSm),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, SeletoTokens.touchTargetMinimum),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SeletoTokens.radiusSm),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, SeletoTokens.touchTargetMinimum),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SeletoTokens.radiusSm),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, SeletoTokens.touchTargetMinimum),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SeletoTokens.radiusSm),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface.withValues(alpha: .98),
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SeletoTokens.radiusMd),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SeletoTokens.radiusMd),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(40),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SeletoTokens.radiusSm),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SeletoTokens.radiusMd),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: .82),
        space: 1,
        thickness: 1,
      ),
      navigationRailTheme: NavigationRailThemeData(
        indicatorColor: scheme.primaryContainer,
        labelType: NavigationRailLabelType.all,
      ),
    );
  }
}
