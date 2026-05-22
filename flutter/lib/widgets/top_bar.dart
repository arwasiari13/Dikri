import 'package:flutter/material.dart';
import '../theme.dart';

class TopBar extends StatelessWidget {
  final String title;
  final bool showBack;
  final Widget? trailing;
  final VoidCallback? onBack;

  const TopBar({
    super.key,
    this.title = '',
    this.showBack = true,
    this.trailing,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            if (showBack)
              GestureDetector(
                onTap: onBack ?? () => Navigator.maybePop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.ink.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: AppColors.ink,
                    size: 20,
                  ),
                ),
              )
            else
              const SizedBox(width: 36),
            const Spacer(),
            if (title.isNotEmpty)
              Text(
                title,
                style: AppFonts.kufi(
                  size: 17,
                  weight: FontWeight.w500,
                ),
              ),
            const Spacer(),
            trailing ?? const SizedBox(width: 36),
          ],
        ),
      ),
    );
  }
}
