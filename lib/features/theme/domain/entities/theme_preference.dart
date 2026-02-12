import 'package:hive/hive.dart';

part 'theme_preference.g.dart';

@HiveType(typeId: 4)
enum ThemePreset {
  @HiveField(0)
  material,
  @HiveField(1)
  tacticalDark,
}

@HiveType(typeId: 5)
class ThemePreference extends HiveObject {
  @HiveField(0)
  ThemePreset themePreset;

  @HiveField(1)
  bool useGlassEffect;

  @HiveField(2)
  bool isDarkMode;

  ThemePreference({
    this.themePreset = ThemePreset.material,
    this.useGlassEffect = true,
    this.isDarkMode = true,
  });

  ThemePreference copyWith({
    ThemePreset? themePreset,
    bool? useGlassEffect,
    bool? isDarkMode,
  }) {
    return ThemePreference(
      themePreset: themePreset ?? this.themePreset,
      useGlassEffect: useGlassEffect ?? this.useGlassEffect,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
