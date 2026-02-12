import 'package:hive/hive.dart';
import 'package:focus_companion/core/constants/app_constants.dart';
import 'package:focus_companion/features/theme/domain/entities/theme_preference.dart';
import 'package:focus_companion/features/theme/domain/repositories/theme_repository.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final String _boxName = AppConstants.themePreferenceBoxName;

  @override
  Future<ThemePreference> getThemePreference() async {
    final box = await Hive.openBox<ThemePreference>(_boxName);
    return box.get('current', defaultValue: ThemePreference())!;
  }

  @override
  Future<void> saveThemePreference(ThemePreference preference) async {
    final box = await Hive.openBox<ThemePreference>(_boxName);
    await box.put('current', preference);
  }
}
