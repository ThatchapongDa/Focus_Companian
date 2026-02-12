import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_companion/features/theme/data/providers/theme_providers.dart';
import 'package:focus_companion/features/theme/domain/entities/theme_preference.dart';
import 'package:focus_companion/core/widgets/tactical_card.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themePreference = ref.watch(themePreferenceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('INTERFACE CONFIG')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader(theme, 'THEME PRESETS'),
          const SizedBox(height: 16),

          _buildThemeOption(
            context,
            ref,
            title: 'TACTICAL DARK (MISSION CONTROL)',
            description:
                'Futuristic industrial interface with neon highlights.',
            preset: ThemePreset.tacticalDark,
            currentPreset: themePreference.themePreset,
            icon: Icons.terminal,
          ),

          const SizedBox(height: 16),

          _buildThemeOption(
            context,
            ref,
            title: 'MATERIAL STANDARDS',
            description: 'Standard system interface with clean aesthetics.',
            preset: ThemePreset.material,
            currentPreset: themePreference.themePreset,
            icon: Icons.style,
          ),

          const SizedBox(height: 32),

          _buildSectionHeader(theme, 'VISUAL ENHANCEMENTS'),
          const SizedBox(height: 16),

          TacticalCard(
            child: SwitchListTile(
              title: const Text(
                'GLASS OVERLAY',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              subtitle: const Text(
                'Apply frosted glass effect to UI elements.',
              ),
              value: themePreference.useGlassEffect,
              onChanged: (value) {
                ref
                    .read(themePreferenceProvider.notifier)
                    .setGlassEffect(value);
              },
              activeColor: theme.colorScheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(height: 48),

          Center(
            child: Text(
              'INTERFACE VERSION v1.0.4r',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
                letterSpacing: 2.0,
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
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.primary.withOpacity(0.7),
        letterSpacing: 1.5,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String description,
    required ThemePreset preset,
    required ThemePreset currentPreset,
    required IconData icon,
  }) {
    final isSelected = preset == currentPreset;
    final theme = Theme.of(context);

    return TacticalCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          ref.read(themePreferenceProvider.notifier).setThemePreset(preset);
        },
        child: Container(
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
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
                        letterSpacing: 1.2,
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
