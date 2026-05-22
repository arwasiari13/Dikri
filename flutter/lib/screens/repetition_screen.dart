import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/top_bar.dart';
import 'ready_screen.dart';

class RepetitionScreen extends StatefulWidget {
  final double recordedDuration;
  final String? dhikrText;

  const RepetitionScreen({
    super.key,
    required this.recordedDuration,
    this.dhikrText,
  });

  @override
  State<RepetitionScreen> createState() => _RepetitionScreenState();
}

class _RepetitionScreenState extends State<RepetitionScreen> {
  int _selected = 33;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBar(title: 'عدد التكرار'),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'كم مرة تريد تكرار الذكر؟',
                    style: AppFonts.kufi(
                      size: 26,
                      weight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اختر عدد التكرارات المناسب لجلستك.',
                    style: AppFonts.arabic(
                      size: 14,
                      color: AppColors.ink2,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _RepetitionCard(
                      n: '٣٣',
                      hint: 'ثلاث وثلاثون',
                      subtitle: 'جلسة قصيرة',
                      selected: _selected == 33,
                      onTap: () => setState(() => _selected = 33),
                    ),
                    const SizedBox(height: 16),
                    _RepetitionCard(
                      n: '١٠٠',
                      hint: 'مئة',
                      subtitle: 'جلسة كاملة',
                      selected: _selected == 100,
                      onTap: () => setState(() => _selected = 100),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 34),
              child: PrimaryButton(
                label: 'متابعة',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReadyScreen(
                      total: _selected,
                      recordedDuration: widget.recordedDuration,
                      dhikrText: widget.dhikrText,
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

class _RepetitionCard extends StatelessWidget {
  final String n;
  final String hint;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RepetitionCard({
    required this.n,
    required this.hint,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: selected ? AppColors.sage : AppColors.card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected ? AppColors.sage : AppColors.line,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.sage.withOpacity(0.5),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                    spreadRadius: -12,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: AppFonts.kufi(
                      size: 13,
                      color: selected
                          ? AppColors.creamText.withOpacity(0.7)
                          : AppColors.ink3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hint,
                    style: AppFonts.kufi(
                      size: 18,
                      weight: FontWeight.w500,
                      color: selected ? AppColors.creamText : AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              n,
              style: AppFonts.kufi(
                size: 64,
                weight: FontWeight.w500,
                color: selected ? AppColors.creamText : AppColors.ink,
                spacing: -2,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
