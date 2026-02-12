import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:focus_companion/features/theme/domain/entities/theme_preference.dart';
import 'package:focus_companion/features/theme/domain/repositories/theme_repository.dart';
import 'package:focus_companion/features/theme/data/repositories/theme_repository_impl.dart';

final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  return ThemeRepositoryImpl();
});

final themePreferenceProvider =
    StateNotifierProvider<ThemeNotifier, ThemePreference>((ref) {
      final repository = ref.watch(themeRepositoryProvider);
      return ThemeNotifier(repository);
    });

class ThemeNotifier extends StateNotifier<ThemePreference> {
  final ThemeRepository _repository;

  ThemeNotifier(this._repository) : super(ThemePreference()) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    state = await _repository.getThemePreference();
  }

  Future<void> setThemePreset(ThemePreset preset) async {
    state = state.copyWith(themePreset: preset);
    await _repository.saveThemePreference(state);
  }

  Future<void> toggleDarkMode() async {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    await _repository.saveThemePreference(state);
  }

  Future<void> setGlassEffect(bool enabled) async {
    state = state.copyWith(useGlassEffect: enabled);
    await _repository.saveThemePreference(state);
  }
}

final themeDataProvider = Provider<ThemeData>((ref) {
  final preference = ref.watch(themePreferenceProvider);

  if (preference.themePreset == ThemePreset.tacticalDark) {
    return _getTacticalDarkTheme();
  }

  // Default Material Theme
  return FlexThemeData.light(
    scheme: FlexScheme.materialBaseline,
    useMaterial3: true,
    fontFamily: GoogleFonts.inter().fontFamily,
  );
});

final darkThemeDataProvider = Provider<ThemeData>((ref) {
  final preference = ref.watch(themePreferenceProvider);

  if (preference.themePreset == ThemePreset.tacticalDark) {
    return _getTacticalDarkTheme();
  }

  return FlexThemeData.dark(
    scheme: FlexScheme.materialBaseline,
    useMaterial3: true,
    fontFamily: GoogleFonts.inter().fontFamily,
  );
});

ThemeData _getTacticalDarkTheme() {
  const background = Color(0xFF0F1115);
  const surface = Color(0xFF1A1F29);
  const divider = Color(0xFF2A2F3A);
  const primary = Color(0xFF3FA7FF);
  const accent = Color(0xFFFFB020);
  const success = Color(0xFF4CD964);
  const warning = Color(0xFFFF5A5F);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: surface,
      background: background,
      error: warning,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),
    dividerTheme: const DividerThemeData(
      color: divider,
      thickness: 1,
      space: 1,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: divider, width: 1),
      ),
    ),
    textTheme: GoogleFonts.rajdhaniTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(letterSpacing: 0.5),
      ),
    ).apply(bodyColor: Colors.white, displayColor: Colors.white),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: divider,
      circularTrackColor: divider,
    ),
  );
}
