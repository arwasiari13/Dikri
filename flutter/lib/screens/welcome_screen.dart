import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/wordmark.dart';
import '../widgets/primary_button.dart';
import 'dhikr_library_screen.dart';
import 'history_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Decorative arch backdrop
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _ArchPainter()),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                const Wordmark(size: 84),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    'سجّل ذِكرك بصوتك،\nودعه يرافقك بإيقاع هادئ.',
                    textAlign: TextAlign.center,
                    style: AppFonts.arabic(
                      size: 15,
                      color: AppColors.ink2,
                      height: 1.7,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: PrimaryButton(
                    label: 'ابدأ التسجيل',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DhikrLibraryScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  ),
                  child: Text(
                    'السجل',
                    style: AppFonts.arabic(
                      size: 13,
                      color: AppColors.ink3,
                    ),
                  ),
                ),
                const SizedBox(height: 34),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // Radial gradient at top
    final gradient = RadialGradient(
      colors: [
        const Color(0xFF3F6253).withOpacity(0.10),
        const Color(0xFF3F6253).withOpacity(0),
      ],
    );
    final rect = Rect.fromCircle(center: Offset(cx, -120), radius: 240);
    canvas.drawOval(
      rect,
      Paint()..shader = gradient.createShader(rect),
    );

    final archPaint = Paint()
      ..color = const Color(0xFF3F6253).withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Outer arch
    final outerPath = Path()
      ..addRRect(RRect.fromRectAndCorners(
        Rect.fromCenter(center: Offset(cx, 110 + 140), width: 220, height: 280),
        topLeft: const Radius.circular(110),
        topRight: const Radius.circular(110),
        bottomLeft: const Radius.circular(30),
        bottomRight: const Radius.circular(30),
      ));
    canvas.drawPath(outerPath, archPaint);

    // Inner arch
    final innerPaint = Paint()
      ..color = const Color(0xFF3F6253).withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final innerPath = Path()
      ..addRRect(RRect.fromRectAndCorners(
        Rect.fromCenter(center: Offset(cx, 130 + 115), width: 170, height: 230),
        topLeft: const Radius.circular(85),
        topRight: const Radius.circular(85),
        bottomLeft: const Radius.circular(24),
        bottomRight: const Radius.circular(24),
      ));
    canvas.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(_ArchPainter old) => false;
}
