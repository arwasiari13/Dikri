import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/session_record.dart';
import '../repositories/session_history_store.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/top_bar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  static const _weekDays = ['س', 'أ', 'ث', 'ر', 'خ', 'ج', 'ح'];

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final Future<List<SessionRecord>> _sessionsFuture =
      SessionHistoryStore().load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SessionRecord>>(
      future: _sessionsFuture,
      builder: (context, snapshot) {
        final sessions = snapshot.data ?? const <SessionRecord>[];
        final weekCounts = _buildWeekCounts(sessions);
        final maxCount = weekCounts.fold<int>(0, math.max);
        final weekBars = maxCount == 0
            ? List<double>.filled(7, 0)
            : weekCounts.map((count) => count / maxCount).toList();
        final weekTotal = weekCounts.fold<int>(0, (sum, count) => sum + count);

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TopBar(
                  title: 'السجل',
                  trailing: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.ink.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.ink,
                      size: 20,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سجل الذِكر',
                        style: AppFonts.kufi(
                          size: 28,
                          weight: FontWeight.w500,
                          spacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'تتبّع جلساتك اليومية',
                        style: AppFonts.arabic(size: 13, color: AppColors.ink2),
                      ),
                      const SizedBox(height: 16),
                      _WeekCard(
                        bars: weekBars,
                        days: HistoryScreen._weekDays,
                        total: weekTotal,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: snapshot.connectionState == ConnectionState.waiting
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.sage,
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                              child: Text(
                                'الجلسات الأخيرة',
                                style: AppFonts.arabic(
                                  size: 12,
                                  color: AppColors.ink3,
                                  spacing: 1,
                                ),
                              ),
                            ),
                            if (sessions.isEmpty)
                              const _EmptyHistory()
                            else
                              ...sessions.map(
                                (s) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _SessionRow(record: s),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<int> _buildWeekCounts(List<SessionRecord> sessions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 6));
    final counts = List<int>.filled(7, 0);

    for (final session in sessions) {
      final day = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );
      final index = day.difference(start).inDays;
      if (index >= 0 && index < counts.length) {
        counts[index] += session.completed;
      }
    }

    return counts;
  }
}

class _WeekCard extends StatelessWidget {
  final List<double> bars;
  final List<String> days;
  final int total;

  const _WeekCard({
    required this.bars,
    required this.days,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.sage,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.sage.withOpacity(0.5),
            blurRadius: 32,
            offset: const Offset(0, 12),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'هذا الأسبوع',
                style: AppFonts.arabic(
                  size: 13,
                  color: AppColors.creamText.withOpacity(0.75),
                ),
              ),
              Text(
                '${toArabic(7)} أيام',
                style: AppFonts.arabic(
                  size: 12,
                  color: AppColors.creamText.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                toArabic(total),
                style: AppFonts.kufi(
                  size: 48,
                  weight: FontWeight.w500,
                  color: AppColors.creamText,
                  spacing: -1,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'ذكر',
                style: AppFonts.arabic(
                  size: 14,
                  color: AppColors.creamText.withOpacity(0.75),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(bars.length, (i) {
                final isToday = i == bars.length - 1;
                final barHeight = math.max(4.0, bars[i] * 40);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: isToday
                            ? AppColors.creamText
                            : AppColors.creamText.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      days[i],
                      style: AppFonts.kufi(
                        size: 10,
                        color: AppColors.creamText.withOpacity(0.7),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            color: AppColors.sage.withOpacity(0.55),
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            'لا توجد جلسات بعد',
            style: AppFonts.kufi(size: 16, weight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'ستظهر جلساتك هنا بعد إنهائها.',
            textAlign: TextAlign.center,
            style: AppFonts.arabic(size: 13, color: AppColors.ink2),
          ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final SessionRecord record;

  const _SessionRow({required this.record});

  String get _dayLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(record.date.year, record.date.month, record.date.day);
    final diff = today.difference(date).inDays;
    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'أمس';
    const days = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return days[record.date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final pct = record.progress;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: -math.pi / 2,
                  child: CustomPaint(
                    size: const Size(44, 44),
                    painter: _MiniRingPainter(
                      progress: pct,
                      color:
                          record.isComplete ? AppColors.sage : AppColors.brass,
                    ),
                  ),
                ),
                if (record.isComplete)
                  const Icon(Icons.check, color: AppColors.sage, size: 14)
                else
                  Text(
                    '${toArabic((pct * 100).round())}%',
                    style: AppFonts.kufi(
                      size: 9,
                      weight: FontWeight.w500,
                      color: AppColors.brass,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _dayLabel,
                      style: AppFonts.kufi(
                        size: 15,
                        weight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${toArabic(record.date.day)}/${toArabic(record.date.month)}',
                      style: AppFonts.arabic(
                        size: 12,
                        color: AppColors.ink3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${toArabic(record.completed)} من ${toArabic(record.target)} ذكر',
                  style: AppFonts.arabic(
                    size: 12,
                    color: AppColors.ink2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: record.isComplete
                  ? AppColors.sageSoft
                  : AppColors.brass.withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              record.isComplete ? 'مكتمل' : 'غير مكتمل',
              style: AppFonts.kufi(
                size: 11,
                weight: FontWeight.w500,
                color: record.isComplete ? AppColors.sage : AppColors.brass,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _MiniRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const r = 18.0;

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = AppColors.line
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_MiniRingPainter old) =>
      old.progress != progress || old.color != color;
}
