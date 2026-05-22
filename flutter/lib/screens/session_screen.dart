import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/session_record.dart';
import '../repositories/session_history_store.dart';
import '../theme.dart';
import '../utils.dart';
import '../painters/session_progress_painter.dart';
import '../widgets/primary_button.dart';
import 'history_screen.dart';

class SessionScreen extends StatefulWidget {
  final int total;
  final double recordedDuration;
  final String? dhikrText;

  const SessionScreen({
    super.key,
    required this.total,
    required this.recordedDuration,
    this.dhikrText,
  });

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen>
    with TickerProviderStateMixin {
  int _count = 0;
  int _completedCycles = 0;
  bool _running = true;
  final bool _complete = false;
  bool _saved = false;
  Timer? _sessionTimer;

  late AnimationController _breatheCtrl;
  late Animation<double> _breatheAnim;
  late AnimationController _numberCtrl;
  late Animation<double> _numberScale;

  @override
  void initState() {
    super.initState();

    _breatheCtrl = AnimationController(
      duration: const Duration(milliseconds: 4200),
      vsync: this,
    )..repeat(reverse: true);
    _breatheAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut),
    );

    _numberCtrl = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _numberScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _numberCtrl, curve: Curves.easeOut),
    );

    _startCounter();
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    _numberCtrl.dispose();
    _sessionTimer?.cancel();
    super.dispose();
  }

  void _startCounter() {
    final intervalMs = (widget.recordedDuration * 1000).round();
    _sessionTimer = Timer.periodic(
      Duration(milliseconds: intervalMs),
      (_) => _increment(),
    );
  }

  void _increment() {
    if (!_running || _complete) return;
    final nextCount = _count + 1;
    final reachedTarget = nextCount >= widget.total;
    setState(() {
      if (reachedTarget) {
        _completedCycles++;
        _count = 0;
      } else {
        _count = nextCount;
      }
    });
    _numberCtrl.forward(from: 0);

    if (reachedTarget) {
      HapticFeedback.heavyImpact();
    }
  }

  int get _totalCompleted => (_completedCycles * widget.total) + _count;

  Future<void> _saveSession(int completed) async {
    if (_saved) return;
    _saved = true;
    await SessionHistoryStore().add(
      SessionRecord(
        date: DateTime.now(),
        target: widget.total,
        completed: completed,
        dhikrText: widget.dhikrText,
      ),
    );
  }

  void _stop() {
    _sessionTimer?.cancel();
    setState(() => _running = false);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'إيقاف الجلسة؟',
              style: AppFonts.kufi(size: 20, weight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم حفظ تقدمك.',
              style: AppFonts.arabic(size: 14, color: AppColors.ink2),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'إنهاء الجلسة',
              dark: true,
              onTap: () async {
                Navigator.pop(ctx);
                await _saveSession(_totalCompleted);
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  (route) => route.isFirst,
                );
              },
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _running = true);
                _startCounter();
              },
              child: Container(
                height: 44,
                alignment: Alignment.center,
                child: Text(
                  'متابعة',
                  style: AppFonts.kufi(size: 16, color: AppColors.sage),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_complete) return _buildComplete();
    return _buildSession();
  }

  Widget _buildSession() {
    final progress = _count / widget.total;
    final totalCompleted = _totalCompleted;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top trailing timer icon
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.ink.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.timer_outlined,
                      color: AppColors.ink,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Breathing aura
                        AnimatedBuilder(
                          animation: _breatheAnim,
                          builder: (_, __) => Transform.scale(
                            scale: _breatheAnim.value,
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.sage.withOpacity(0.12),
                                    AppColors.sage.withOpacity(0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Progress ring with dots
                        CustomPaint(
                          size: const Size(300, 300),
                          painter: SessionProgressPainter(
                            progress: progress,
                            total: widget.total,
                            current: _count,
                            progressColor: AppColors.sage,
                            trackColor: AppColors.sage.withOpacity(0.10),
                            dotActiveColor: AppColors.sage,
                            dotInactiveColor: AppColors.sage.withOpacity(0.18),
                          ),
                        ),
                        // Counter
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ScaleTransition(
                              scale: _numberScale,
                              child: Text(
                                toArabic(_count),
                                style: AppFonts.kufi(
                                  size: 96,
                                  weight: FontWeight.w500,
                                  spacing: -3,
                                  height: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'من ${toArabic(widget.total)}',
                              style: AppFonts.kufi(
                                size: 20,
                                color: AppColors.ink3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    totalCompleted == 0
                        ? 'تنفس بهدوء، الذكر يجري معك.'
                        : '${toArabic(totalCompleted)} ذكر حتى الآن',
                    style: AppFonts.arabic(size: 13, color: AppColors.ink3),
                  ),
                ],
              ),
            ),
            // Stop button
            GestureDetector(
              onTap: _stop,
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.ink.withOpacity(0.05),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Center(
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'إيقاف',
                    style: AppFonts.kufi(size: 12, color: AppColors.ink3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 34),
          ],
        ),
      ),
    );
  }

  Widget _buildComplete() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF1EC), Color(0xFFDDE7DF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Brass radial glow
                          Container(
                            margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.brass.withOpacity(0.18),
                                  AppColors.brass.withOpacity(0),
                                ],
                              ),
                            ),
                          ),
                          // Full ring
                          CustomPaint(
                            size: const Size(300, 300),
                            painter: SessionProgressPainter(
                              progress: 1.0,
                              total: widget.total,
                              current: widget.total,
                              progressColor: AppColors.sage,
                              trackColor: AppColors.sage.withOpacity(0.10),
                              dotActiveColor: AppColors.sage,
                              dotInactiveColor:
                                  AppColors.sage.withOpacity(0.18),
                            ),
                          ),
                          // Check + number
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.sage,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.sage.withOpacity(0.5),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                      spreadRadius: -8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: AppColors.creamText,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                toArabic(widget.total),
                                style: AppFonts.kufi(
                                  size: 56,
                                  weight: FontWeight.w500,
                                  color: AppColors.sage2,
                                  spacing: -2,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'اكتملت جلسة الذكر',
                      style: AppFonts.kufi(size: 26, weight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'تقبّل الله منك',
                      style: AppFonts.arabic(
                        size: 14,
                        color: AppColors.ink2,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Stats card
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _StatBit(
                            label: 'الذِكر',
                            value:
                                '${toArabic(widget.total)}/${toArabic(widget.total)}',
                          ),
                          Container(
                            width: 1,
                            height: 32,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            color: AppColors.line,
                          ),
                          _StatBit(
                            label: 'المدة',
                            value: _formatTotalTime(),
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
                  label: 'إنهاء',
                  onTap: () async {
                    await _saveSession(widget.total);
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HistoryScreen(),
                      ),
                      (route) => route.isFirst,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTotalTime() {
    final totalSeconds = (widget.recordedDuration * widget.total).round();
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${toArabic(m)}:${toArabic(s).padLeft(2, '٠')}';
  }
}

class _StatBit extends StatelessWidget {
  final String label;
  final String value;

  const _StatBit({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppFonts.arabic(size: 11, color: AppColors.ink3),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppFonts.kufi(
            size: 16,
            weight: FontWeight.w500,
            spacing: 0.5,
          ),
        ),
      ],
    );
  }
}
