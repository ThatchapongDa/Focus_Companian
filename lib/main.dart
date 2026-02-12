import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:focus_companion/core/utils/notification_service.dart';
import 'package:focus_companion/core/routing/app_router.dart';
import 'package:focus_companion/features/tasks/domain/entities/task.dart';
import 'package:focus_companion/features/focus/domain/entities/focus_session.dart';
import 'package:focus_companion/features/music/domain/entities/music_track.dart';
import 'package:focus_companion/features/dashboard/presentation/screens/dashboard_screen.dart';

import 'package:focus_companion/features/theme/domain/entities/theme_preference.dart';
import 'package:focus_companion/features/theme/data/providers/theme_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(FocusSessionAdapter());
  Hive.registerAdapter(MusicTrackAdapter());
  Hive.registerAdapter(SourceTypeAdapter());
  Hive.registerAdapter(ThemePresetAdapter());
  Hive.registerAdapter(ThemePreferenceAdapter());

  // Initialize Notification Service
  await NotificationService().init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeDataProvider);
    final darkTheme = ref.watch(darkThemeDataProvider);
    final themePreference = ref.watch(themePreferenceProvider);

    return MaterialApp(
      title: 'Focus Companion',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themePreference.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const DashboardScreen(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
