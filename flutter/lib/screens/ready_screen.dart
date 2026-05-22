import 'package:flutter/material.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/primary_button.dart';
import 'session_screen.dart';

class ReadyScreen extends StatelessWidget {
  final int total;
  final double recordedDuration;
  final String? dhikrText;

  const ReadyScreen({
    super.key,
    required this.total,
    required this.recordedDuration,
    this.dhikrText,
  });

  @override
  Widget build(BuildContext context) {
    final totalSeconds = (recordedDuration * total).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final label = toArabic(total);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Concentric rings with number
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.sage.withOpacity(0.10),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.sage.withOpacity(0.14),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(50),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.sageSoft,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            label,
                            style: AppFonts.kufi(
                              size: 64,
                              weight: FontWeight.w500,
                              color: AppColors.sage,
                              spacing: -2,
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'أنت جاهز لبدء جلسة الذكر',
                      textAlign: TextAlign.center,
                      style: AppFonts.kufi(
                        size: 26,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'خذ نفساً عميقاً، واسمح للهدوء أن يحضر معك.',
                      textAlign: TextAlign.center,
                      style: AppFonts.arabic(
                        size: 14,
                        color: AppColors.ink2,
                        height: 1.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Meta strip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.sage.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${toArabic(recordedDuration.toStringAsFixed(1))} ث/تكرار',
                          style: AppFonts.arabic(
                            size: 12,
                            color: AppColors.ink2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '·',
                            style: AppFonts.arabic(
                              size: 12,
                              color: AppColors.ink3,
                            ),
                          ),
                        ),
                        Text(
                          '~${toArabic(minutes)} د ${toArabic(seconds)} ث',
                          style: AppFonts.arabic(
                            size: 12,
                            color: AppColors.ink2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 34),
              child: PrimaryButton(
                label: 'ابدأ',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SessionScreen(
                      total: total,
                      recordedDuration: recordedDuration,
                      dhikrText: dhikrText,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
