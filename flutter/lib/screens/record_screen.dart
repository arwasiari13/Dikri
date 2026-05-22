import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../repositories/saved_dhikr_store.dart';
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
  final _speech = stt.SpeechToText();
  final _dhikrStore = SavedDhikrStore();
  final _recordStopwatch = Stopwatch();

  _RecordState _state = _RecordState.idle;
  int _elapsedMs = 0;
  double _recordedDuration = 3.2;
  String _recognizedText = '';
  String? _speechMessage;
  String? _listenLocaleId;
  bool _speechReady = false;
  bool _saving = false;
  Timer? _recordTimer;

  static const _recordingTrimMs = 1000;

  late AnimationController _breatheCtrl;
  late Animation<double> _breatheScale1;
  late Animation<double> _breatheScale2;
  late AnimationController _blinkCtrl;
  late Animation<double> _blinkOpacity;

  static const List<double> _barHeights = [
    22.0,
    38,
    14,
    52,
    30,
    64,
    42,
    28,
    56,
    36,
    70,
    44,
    24,
    50,
    32,
    60,
    26,
    46,
    38,
    18,
    42,
    56,
    30,
    22,
    48,
    36,
    62,
    28,
    40,
    20,
    32,
    18,
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
    _speech.stop();
    super.dispose();
  }

  Future<void> _startRecording() async {
    setState(() {
      _speechMessage = null;
      _recognizedText = '';
      _elapsedMs = 0;
    });

    final ready = _speechReady || await _initializeSpeech();

    if (!ready) {
      setState(() {
        _speechMessage =
            'لم يتم السماح باستخدام الميكروفون أو خدمة التعرّف الصوتي.';
      });
      return;
    }

    _speechReady = true;
    _listenLocaleId ??= await _resolveArabicLocale();
    _recordStopwatch
      ..reset()
      ..start();
    setState(() => _state = _RecordState.recording);
    _recordTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) {
        setState(() => _elapsedMs = _recordStopwatch.elapsedMilliseconds);
      }
    });

    try {
      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;
          setState(() {
            _recognizedText = result.recognizedWords.trim();
          });
        },
        listenOptions: stt.SpeechListenOptions(
          localeId: _listenLocaleId,
          listenFor: const Duration(seconds: 60),
          pauseFor: const Duration(seconds: 6),
          partialResults: true,
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
        ),
      );
    } catch (error) {
      _recordTimer?.cancel();
      if (!mounted) return;
      setState(() {
        _state = _RecordState.idle;
        _speechMessage = 'تعذّر بدء التعرّف الصوتي: $error';
      });
    }
  }

  Future<bool> _initializeSpeech() {
    return _speech.initialize(
      debugLogging: true,
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _speechMessage = _friendlySpeechError(error.errorMsg);
        });
      },
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'done' && _state == _RecordState.recording) {
          _stopRecording();
        }
      },
    );
  }

  Future<String> _resolveArabicLocale() async {
    try {
      final locales = await _speech.locales();
      final preferred = [
        'ar_DZ',
        'ar-DZ',
        'ar_SA',
        'ar-SA',
        'ar_EG',
        'ar-EG',
        'ar_AE',
        'ar-AE',
        'ar',
      ];

      String normalize(String value) =>
          value.toLowerCase().replaceAll('-', '_');
      for (final target in preferred.map(normalize)) {
        for (final locale in locales) {
          if (normalize(locale.localeId) == target) return locale.localeId;
        }
      }
      for (final locale in locales) {
        if (normalize(locale.localeId).startsWith('ar')) return locale.localeId;
      }
    } catch (_) {
      // Web speech often cannot list all online recognizer languages.
    }
    return 'ar-SA';
  }

  String _friendlySpeechError(String error) {
    switch (error) {
      case 'not-allowed':
      case 'not_allowed':
      case 'permission':
        return 'اسمح للمتصفح أو الهاتف باستخدام الميكروفون ثم جرّب مرة أخرى.';
      case 'no-speech':
      case 'error_no_match':
        return 'لم أسمع صوتاً واضحاً. اقترب من الميكروفون وجرّب مرة أخرى.';
      case 'network':
      case 'network_error':
        return 'خدمة التعرّف الصوتي تحتاج اتصال إنترنت الآن.';
      case 'speech_not_supported':
      case 'not supported':
        return 'التعرّف الصوتي غير مدعوم في هذا المتصفح. جرّبه على كروم أو على هاتف أندرويد.';
      default:
        return 'خطأ في التعرّف الصوتي: $error';
    }
  }

  Future<void> _stopRecording() async {
    if (_state != _RecordState.recording) return;
    _recordTimer?.cancel();
    _recordStopwatch.stop();
    await _speech.stop();
    if (!mounted) return;
    final adjustedMs = (_recordStopwatch.elapsedMilliseconds - _recordingTrimMs)
        .clamp(0, 60000);
    setState(() {
      _recordedDuration = (adjustedMs / 1000.0).clamp(0.8, 60);
      _state = _RecordState.complete;
    });
    HapticFeedback.mediumImpact();
  }

  void _retry() {
    _recordTimer?.cancel();
    _recordStopwatch
      ..stop()
      ..reset();
    _speech.stop();
    setState(() {
      _state = _RecordState.idle;
      _elapsedMs = 0;
      _recognizedText = '';
      _speechMessage = null;
    });
  }

  Future<void> _saveAndContinue() async {
    final text = _recognizedText.trim();
    if (text.isEmpty || _saving) return;

    setState(() => _saving = true);
    await _dhikrStore.add(text);
    if (!mounted) return;
    setState(() => _saving = false);
    _continue(text);
  }

  void _continue([String? text]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RepetitionScreen(
          recordedDuration: _recordedDuration,
          dhikrText: text ?? _recognizedText.trim(),
        ),
      ),
    );
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
            const TopBar(title: 'التسجيل'),
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
                'اقرأ الذكر بصوتك',
                textAlign: TextAlign.center,
                style: AppFonts.kufi(size: 24, weight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Text(
                'سنستخدم التعرّف الصوتي لتحويل الذكر إلى نص، ثم يمكنك حفظه محلياً.',
                textAlign: TextAlign.center,
                style: AppFonts.arabic(
                  size: 14,
                  color: AppColors.ink2,
                  height: 1.6,
                ),
              ),
              if (_speechMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _speechMessage!,
                  textAlign: TextAlign.center,
                  style: AppFonts.arabic(
                    size: 12,
                    color: AppColors.brass,
                    height: 1.5,
                  ),
                ),
              ],
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
    final recognized = _recognizedText.trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 30),
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
                  'جاري الاستماع',
                  style: AppFonts.arabic(size: 13, color: AppColors.ink2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
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
          const SizedBox(height: 24),
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
          const SizedBox(height: 18),
          Text(
            _timerLabel,
            style: AppFonts.kufi(size: 28, color: AppColors.ink, spacing: 1),
          ),
          const SizedBox(height: 18),
          _RecognizedTextCard(
            text: recognized.isEmpty ? 'ابدأ بقراءة الذكر...' : recognized,
            muted: recognized.isEmpty,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildComplete() {
    final duration = _recordedDuration;
    final durationStr = duration.toStringAsFixed(1);
    final recognized = _recognizedText.trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 34),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  recognized.isEmpty ? AppColors.lineLight : AppColors.sageSoft,
              border: Border.all(color: AppColors.sage.withOpacity(0.15)),
            ),
            child: Icon(
              recognized.isEmpty ? Icons.priority_high : Icons.check,
              color: AppColors.sage,
              size: 28,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            recognized.isEmpty
                ? 'لم يتم التعرّف على نص'
                : 'تم التعرّف على الذكر',
            textAlign: TextAlign.center,
            style: AppFonts.kufi(size: 22, weight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            recognized.isEmpty
                ? 'أعد التسجيل بصوت أوضح، أو تابع بدون حفظ النص.'
                : 'راجع النص، ثم احفظه واستخدمه في جلستك.',
            textAlign: TextAlign.center,
            style: AppFonts.arabic(
              size: 14,
              color: AppColors.ink2,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          _RecognizedTextCard(
            text: recognized.isEmpty ? 'لا يوجد نص بعد' : recognized,
            muted: recognized.isEmpty,
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  toArabic(double.parse(durationStr)),
                  style: AppFonts.kufi(
                    size: 42,
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
          ),
          const SizedBox(height: 30),
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

    final hasText = _recognizedText.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          PrimaryButton(
            label: hasText
                ? (_saving ? 'جاري الحفظ...' : 'حفظ ومتابعة')
                : 'متابعة بدون نص',
            onTap: hasText ? _saveAndContinue : () => _continue(''),
          ),
          if (hasText) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => _continue(_recognizedText.trim()),
              child: Container(
                height: 44,
                alignment: Alignment.center,
                child: Text(
                  'متابعة بدون حفظ',
                  style: AppFonts.kufi(size: 15, color: AppColors.ink2),
                ),
              ),
            ),
          ],
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

class _RecognizedTextCard extends StatelessWidget {
  final String text;
  final bool muted;

  const _RecognizedTextCard({
    required this.text,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppFonts.arabic(
          size: muted ? 14 : 18,
          weight: muted ? FontWeight.w400 : FontWeight.w500,
          color: muted ? AppColors.ink3 : AppColors.ink,
          height: 1.7,
        ),
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
