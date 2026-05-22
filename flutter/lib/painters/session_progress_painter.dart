import 'dart:math' as math;
import 'package:flutter/material.dart';

class SessionProgressPainter extends CustomPainter {
  final double progress;
  final int total;
  final int current;
  final Color progressColor;
  final Color trackColor;
  final Color dotActiveColor;
  final Color dotInactiveColor;

  const SessionProgressPainter({
    required this.progress,
    required this.total,
    required this.current,
    required this.progressColor,
    required this.trackColor,
    required this.dotActiveColor,
    required this.dotInactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4333; // matches 130/300 from design

    // Track ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = progressColor
          ..strokeWidth = 6
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    // Tick dots around the outside
    for (int i = 0; i < total; i++) {
      final angle = (i / total) * 2 * math.pi - math.pi / 2;
      final dotCenter = Offset(
        center.dx + math.cos(angle) * (radius + 14),
        center.dy + math.sin(angle) * (radius + 14),
      );
      canvas.drawCircle(
        dotCenter,
        1.2,
        Paint()
          ..color = i < current ? dotActiveColor : dotInactiveColor
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(SessionProgressPainter old) =>
      old.progress != progress || old.current != current;
}
