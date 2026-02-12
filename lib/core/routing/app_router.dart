import 'package:flutter/material.dart';
import 'package:focus_companion/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:focus_companion/features/tasks/presentation/screens/task_list_screen.dart';
import 'package:focus_companion/features/tasks/presentation/screens/task_detail_screen.dart';
import 'package:focus_companion/features/focus/presentation/screens/focus_screen.dart';
import 'package:focus_companion/features/music/presentation/screens/music_selection_screen.dart';

import 'package:focus_companion/features/theme/presentation/screens/theme_settings_screen.dart';
import 'package:focus_companion/features/statistics/presentation/screens/statistics_screen.dart';

class AppRouter {
  static const String dashboard = '/';
  static const String taskList = '/tasks';
  static const String taskDetail = '/tasks/detail';
  static const String focus = '/focus';
  static const String musicSelection = '/music';
  static const String statistics = '/statistics';
  static const String themeSettings = '/settings/theme';
  static const String appSettings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case taskList:
        return MaterialPageRoute(builder: (_) => const TaskListScreen());
      case taskDetail:
        final taskId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => TaskDetailScreen(taskId: taskId),
        );
      case focus:
        return MaterialPageRoute(builder: (_) => const FocusScreen());
      case musicSelection:
        return MaterialPageRoute(builder: (_) => const MusicSelectionScreen());
      case statistics:
        return MaterialPageRoute(builder: (_) => const StatisticsScreen());
      case themeSettings:
        return MaterialPageRoute(builder: (_) => const ThemeSettingsScreen());
      case appSettings:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('App Settings - Coming Soon')),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static void navigateTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void navigateToAndReplace(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void navigateToAndClearStack(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
