import 'package:flutter/material.dart';
import '../theme.dart';

class Wordmark extends StatelessWidget {
  final double size;
  final bool showEn;
  final Color color;

  const Wordmark({
    super.key,
    this.size = 56,
    this.showEn = true,
    this.color = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.22),
          child: Image.asset(
            'assets/icon/dikri_logo.png',
            width: size * 1.45,
            height: size * 1.45,
            fit: BoxFit.cover,
          ),
        ),
        if (showEn) ...[
          const SizedBox(height: 12),
          Text(
            'DIKRI',
            style: AppFonts.kufi(
              size: 11,
              weight: FontWeight.w300,
              color: AppColors.ink3,
              spacing: 6,
            ),
          ),
        ],
      ],
    );
  }
}
