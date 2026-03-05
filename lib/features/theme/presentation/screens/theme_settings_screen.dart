import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_companion/features/theme/data/providers/theme_providers.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themePreference = ref.watch(themePreferenceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('ตั้งค่าแอปพลิเคชัน')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader(theme, 'ธีมของแอป'),
          const SizedBox(height: 16),

          _buildThemeOption(
            context,
            ref,
            title: 'โหมดสว่าง (Light Mode)',
            description: 'หน้าจอโทนสีสว่าง สบายตา',
            isDark: false,
            currentIsDark: themePreference.isDarkMode,
            icon: Icons.light_mode,
          ),

          const SizedBox(height: 16),

          _buildThemeOption(
            context,
            ref,
            title: 'โหมดมืด (Dark Mode)',
            description: 'หน้าจอโทนสีเข้ม สบายตาในเวลากลางคืน',
            isDark: true,
            currentIsDark: themePreference.isDarkMode,
            icon: Icons.dark_mode,
          ),

          const SizedBox(height: 32),

          _buildSectionHeader(theme, 'การปรับแต่งเพิ่มเติม'),
          const SizedBox(height: 16),

          Card(
            clipBehavior: Clip.antiAlias,
            child: SwitchListTile(
              title: const Text(
                'เอฟเฟกต์โปร่งแสง (Glass Effect)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('เปิดใช้เอฟเฟกต์กระจกโปร่งแสง'),
              value: themePreference.useGlassEffect,
              onChanged: (value) {
                ref
                    .read(themePreferenceProvider.notifier)
                    .setGlassEffect(value);
              },
              activeThumbColor: theme.colorScheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(height: 48),

          Center(
            child: Text(
              'เวอร์ชัน 1.0.0',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String description,
    required bool isDark,
    required bool currentIsDark,
    required IconData icon,
  }) {
    final isSelected = isDark == currentIsDark;
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          ref.read(themePreferenceProvider.notifier).setDarkMode(isDark);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
