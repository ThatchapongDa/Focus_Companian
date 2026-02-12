import 'package:focus_companion/features/theme/domain/entities/theme_preference.dart';

abstract class ThemeRepository {
  Future<ThemePreference> getThemePreference();
  Future<void> saveThemePreference(ThemePreference preference);
}
