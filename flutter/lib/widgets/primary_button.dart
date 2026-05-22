import 'package:flutter/material.dart';
import '../theme.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool dark;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: dark ? AppColors.sage2 : AppColors.sage,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.sage.withOpacity(0.55),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -8,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppFonts.kufi(
            size: 19,
            weight: FontWeight.w500,
            color: AppColors.creamText,
            spacing: 0.2,
          ),
        ),
      ),
    );
  }
}
