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

  Future<void> setDarkMode(bool isDark) async {
    state = state.copyWith(isDarkMode: isDark);
    await _repository.saveThemePreference(state);
  }

  Future<void> setGlassEffect(bool enabled) async {
    state = state.copyWith(useGlassEffect: enabled);
    await _repository.saveThemePreference(state);
  }
}

final themeDataProvider = Provider<ThemeData>((ref) {
  final preference = ref.watch(themePreferenceProvider);
  return FlexThemeData.light(
    scheme: FlexScheme.materialBaseline,
    useMaterial3: true,
    fontFamily: GoogleFonts.sarabun().fontFamily,
  );
});

final darkThemeDataProvider = Provider<ThemeData>((ref) {
  final preference = ref.watch(themePreferenceProvider);
  return FlexThemeData.dark(
    scheme: FlexScheme.materialBaseline,
    useMaterial3: true,
    fontFamily: GoogleFonts.sarabun().fontFamily,
  );
});

// Removed _getTacticalDarkTheme
