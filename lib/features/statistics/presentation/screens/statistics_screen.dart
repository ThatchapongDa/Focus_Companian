import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_companion/core/widgets/tactical_card.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('MISSION METRICS')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildMetricHeader(theme, 'OPERATIONAL OVERVIEW'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  theme,
                  label: 'TOTAL FOCUS',
                  value: '00:00',
                  unit: 'HRS',
                  icon: Icons.timer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  theme,
                  label: 'MISSIONS',
                  value: '0',
                  unit: 'COMPLETED',
                  icon: Icons.task_alt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildMetricHeader(theme, 'PERFORMANCE ANALYTICS'),
          const SizedBox(height: 16),
          TacticalCard(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.stacked_line_chart,
                    size: 48,
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'DATA CORRELATION IN PROGRESS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildMetricHeader(theme, 'RECENT LOGS'),
          const SizedBox(height: 16),
          TacticalCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'NO RECENT MISSION DATA RECORDED IN CURRENT SECTOR.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.primary.withOpacity(0.7),
        letterSpacing: 2.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMetricCard(
    ThemeData theme, {
    required String label,
    required String value,
    required String unit,
    required IconData icon,
  }) {
    return TacticalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.primary),
              Text(
                unit,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 8,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier', // Monospace feel
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
