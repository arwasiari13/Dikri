import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/primary_button.dart';
import '../widgets/top_bar.dart';
import 'repetition_screen.dart';

enum _RecordState { idle, recording, complete }

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen>
    with TickerProviderStateMixin {
  _RecordState _state = _RecordState.idle;
  int _elapsedMs = 0;
  double _recordedDuration = 3.2;
  Timer? _recordTimer;

  late AnimationController _breatheCtrl;
  late Animation<double> _breatheScale1;
  late Animation<double> _breatheScale2;
  late AnimationController _blinkCtrl;
  late Animation<double> _blinkOpacity;

  static const List<double> _barHeights = [
    22.0, 38, 14, 52, 30, 64, 42, 28, 56, 36,
    70, 44, 24, 50, 32, 60, 26, 46, 38, 18,
    42, 56, 30, 22, 48, 36, 62, 28, 40, 20, 32, 18,
  ];

  @override
  void initState() {
    super.initState();
    _breatheCtrl = AnimationController(
      duration: const Duration(milliseconds: 4200),
      vsync: this,
    )..repeat(reverse: true);
    _breatheScale1 = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut),
    );
    _breatheScale2 = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(
        parent: _breatheCtrl,
        curve: const Interval(0.1, 1.0, curve: Curves.easeInOut),
      ),
    );
    _blinkCtrl = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);
    _blinkOpacity = Tween<double>(begin: 1.0, end: 0.35).animate(
      CurvedAnimation(parent: _blinkCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    _blinkCtrl.dispose();
    _recordTimer?.cancel();
    super.dispose();
  }

  void _startRecording() {
    setState(() => _state = _RecordState.recording);
    _recordTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() => _elapsedMs += 100);
    });
  }

  void _stopRecording() {
    _recordTimer?.cancel();
    setState(() {
      _recordedDuration = _elapsedMs / 1000.0;
      _state = _RecordState.complete;
    });
  }

  void _retry() {
    setState(() {
      _state = _RecordState.idle;
      _elapsedMs = 0;
    });
  }

  String get _timerLabel {
    final s = _elapsedMs ~/ 1000;
    final ms = (_elapsedMs % 1000) ~/ 10;
    return '${toArabic(s).padLeft(2, '٠')}:${toArabic(ms).padLeft(2, '٠')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg2,
      body: SafeArea(
        child: Column(
          children: [
            TopBar(title: 'التسجيل'),
            Expanded(child: _buildBody()),
            _buildFooter(),
            const SizedBox(height: 34),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _RecordState.idle:
        return _buildIdle();
      case _RecordState.recording:
        return _buildRecording();
      case _RecordState.complete:
        return _buildComplete();
    }
  }

  Widget _buildIdle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Text(
                'اقرأ الذكر الذي تريد تكراره',
                textAlign: TextAlign.center,
                style: AppFonts.kufi(size: 24, weight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Text(
                'اضغط على الزر وابدأ بقراءة الذكر بصوتٍ هادئ.',
                textAlign: TextAlign.center,
                style: AppFonts.arabic(size: 14, color: AppColors.ink2, height: 1.6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.sage.withOpacity(0.06),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.sage.withOpacity(0.08),
                ),
              ),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.card,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ink.withOpacity(0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: const _MicIcon(size: 40, color: AppColors.sage),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'جاهز للتسجيل',
          style: AppFonts.arabic(size: 13, color: AppColors.ink3),
        ),
      ],
    );
  }

  Widget _buildRecording() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Live recording tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: _blinkOpacity,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFC2492E),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'جارٍ التسجيل',
                style: AppFonts.arabic(size: 13, color: AppColors.ink2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _breatheScale1,
                builder: (_, __) => Transform.scale(
                  scale: _breatheScale1.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.sage.withOpacity(0.10),
                    ),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _breatheScale2,
                builder: (_, __) => Transform.scale(
                  scale: _breatheScale2.value,
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.sage.withOpacity(0.14),
                    ),
                  ),
                ),
              ),
              Container(
                width: 124,
                height: 124,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.sage,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.sage.withOpacity(0.55),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                      spreadRadius: -8,
                    ),
                  ],
                ),
                child: const _MicIcon(size: 44, color: AppColors.creamText),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        // Static waveform
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_barHeights.length, (i) {
            return Container(
              width: 3,
              height: _barHeights[i],
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: i < 18
                    ? AppColors.sage
                    : AppColors.sage.withOpacity(0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        Text(
          _timerLabel,
          style: AppFonts.kufi(size: 28, color: AppColors.ink, spacing: 1),
        ),
      ],
    );
  }

  Widget _buildComplete() {
    final duration = _recordedDuration;
    final durationStr = duration.toStringAsFixed(1);
    final playbackBars = [8,14,6,18,12,20,10,16,8,14,18,10,6,12,20,8,14,10,16,8,12,18,10,6,14,8,12,16,10,8];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sageSoft,
              border: Border.all(color: AppColors.sage.withOpacity(0.15)),
            ),
            child: const Icon(Icons.check, color: AppColors.sage, size: 28),
          ),
          const SizedBox(height: 28),
          Text(
            'تم حفظ تسجيلك',
            style: AppFonts.kufi(size: 22, weight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'سيُستخدم هذا الإيقاع لضبط جلستك.',
            textAlign: TextAlign.center,
            style: AppFonts.arabic(size: 14, color: AppColors.ink2, height: 1.6),
          ),
          const SizedBox(height: 28),
          // Duration card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مدة الذكر المسجل',
                  style: AppFonts.arabic(size: 12, color: AppColors.ink3),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      toArabic(double.parse(durationStr)),
                      style: AppFonts.kufi(
                        size: 48,
                        weight: FontWeight.w500,
                        spacing: -1,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ثانية',
                      style: AppFonts.arabic(size: 15, color: AppColors.ink2),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Mini playback
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.sage,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: AppColors.creamText,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: playbackBars.map((h) => Container(
                            width: 2.5,
                            height: h.toDouble(),
                            decoration: BoxDecoration(
                              color: AppColors.sage.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          )).toList(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        toArabic('0:03'),
                        style: AppFonts.kufi(size: 12, color: AppColors.ink2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    if (_state == _RecordState.idle) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: PrimaryButton(
          label: 'ابدأ التسجيل',
          onTap: _startRecording,
        ),
      );
    }
    if (_state == _RecordState.recording) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: PrimaryButton(
          label: 'إيقاف التسجيل',
          dark: true,
          onTap: _stopRecording,
        ),
      );
    }
    // complete
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          PrimaryButton(
            label: 'متابعة',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RepetitionScreen(
                  recordedDuration: _recordedDuration,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: _retry,
            child: Container(
              height: 44,
              alignment: Alignment.center,
              child: Text(
                'إعادة التسجيل',
                style: AppFonts.kufi(size: 15, color: AppColors.ink2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MicIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _MicIcon({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.mic, size: size, color: color);
  }
}
