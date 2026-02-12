import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TacticalTimerDisplay extends StatefulWidget {
  final Duration remainingDuration;
  final Duration totalDuration;
  final bool isRunning;

  const TacticalTimerDisplay({
    super.key,
    required this.remainingDuration,
    required this.totalDuration,
    required this.isRunning,
  });

  @override
  State<TacticalTimerDisplay> createState() => _TacticalTimerDisplayState();
}

class _TacticalTimerDisplayState extends State<TacticalTimerDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isRunning) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(TacticalTimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = widget.totalDuration.inSeconds > 0
        ? widget.remainingDuration.inSeconds / widget.totalDuration.inSeconds
        : 0.0;

    final isLowTime = progress < 0.2 && widget.totalDuration.inMinutes > 0;
    final primaryColor = isLowTime
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'OPERATION TIMER',
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 2.0,
            color: primaryColor.withOpacity(0.7),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer Pulsing Glow
            if (widget.isRunning)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(
                            0.15 * _pulseController.value,
                          ),
                          blurRadius: 30 * _pulseController.value,
                          spreadRadius: 5 * _pulseController.value,
                        ),
                      ],
                    ),
                  );
                },
              ),

            // Segmented Progress Ring
            SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(
                painter: SegmentedProgressPainter(
                  progress: progress,
                  color: primaryColor,
                  backgroundColor: theme.dividerColor.withOpacity(0.2),
                ),
              ),
            ),

            // Timer Text
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatDuration(widget.remainingDuration),
                  style: GoogleFonts.orbitron(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: primaryColor.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                if (widget.isRunning)
                  Text(
                    'ACTIVE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: primaryColor,
                      letterSpacing: 4.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class SegmentedProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final int segments = 60;
  final double gap = 0.05;

  SegmentedProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 12.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final segmentAngle = (2 * pi) / segments;

    for (int i = 0; i < segments; i++) {
      final startAngle = -pi / 2 + (i * segmentAngle) + (gap / 2);
      final sweptAngle = segmentAngle - gap;

      final isSegmentActive = (i / segments) < progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweptAngle,
        false,
        isSegmentActive ? activePaint : bgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(SegmentedProgressPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
