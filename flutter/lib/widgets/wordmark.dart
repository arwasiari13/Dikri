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
        Text(
          'ذِكري',
          style: AppFonts.kufi(
            size: size,
            weight: FontWeight.w500,
            color: color,
            spacing: -0.5,
            height: 1,
          ),
        ),
        if (showEn) ...[
          const SizedBox(height: 6),
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
