import 'package:flutter/material.dart';

import '../models/saved_dhikr.dart';
import '../repositories/saved_dhikr_store.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/primary_button.dart';
import '../widgets/top_bar.dart';
import 'record_screen.dart';
import 'repetition_screen.dart';

class DhikrLibraryScreen extends StatefulWidget {
  const DhikrLibraryScreen({super.key});

  @override
  State<DhikrLibraryScreen> createState() => _DhikrLibraryScreenState();
}

class _DhikrLibraryScreenState extends State<DhikrLibraryScreen> {
  final _store = SavedDhikrStore();
  late Future<List<SavedDhikr>> _dhikrsFuture = _store.load();

  void _reload() {
    setState(() {
      _dhikrsFuture = _store.load();
    });
  }

  Future<void> _delete(SavedDhikr dhikr) async {
    await _store.remove(dhikr.id);
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TopBar(title: 'الأذكار المحفوظة'),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اختر ذكراً محفوظاً أو سجّل ذكراً جديداً',
                    style: AppFonts.kufi(
                      size: 24,
                      weight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'التعرّف الصوتي يحتاج الإنترنت في بعض الأجهزة، وبعد الحفظ يبقى النص محلياً على الهاتف.',
                    style: AppFonts.arabic(
                      size: 13,
                      color: AppColors.ink2,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<SavedDhikr>>(
                future: _dhikrsFuture,
                builder: (context, snapshot) {
                  final dhikrs = snapshot.data ?? const <SavedDhikr>[];
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.sage),
                    );
                  }
                  if (dhikrs.isEmpty) return const _EmptySavedDhikrs();

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: dhikrs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final dhikr = dhikrs[index];
                      return _SavedDhikrCard(
                        dhikr: dhikr,
                        onUse: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RepetitionScreen(
                              recordedDuration: 3,
                              dhikrText: dhikr.text,
                            ),
                          ),
                        ),
                        onDelete: () => _delete(dhikr),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 34),
              child: PrimaryButton(
                label: 'تسجيل ذكر جديد',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RecordScreen()),
                  );
                  if (mounted) _reload();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedDhikrCard extends StatelessWidget {
  final SavedDhikr dhikr;
  final VoidCallback onUse;
  final VoidCallback onDelete;

  const _SavedDhikrCard({
    required this.dhikr,
    required this.onUse,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dhikr.text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.arabic(
              size: 16,
              weight: FontWeight.w500,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${toArabic(dhikr.createdAt.day)}/${toArabic(dhikr.createdAt.month)}',
                  style: AppFonts.arabic(size: 12, color: AppColors.ink3),
                ),
              ),
              IconButton(
                tooltip: 'حذف',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.ink3,
              ),
              TextButton(
                onPressed: onUse,
                child: Text(
                  'استخدام',
                  style: AppFonts.kufi(
                    size: 13,
                    color: AppColors.sage,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptySavedDhikrs extends StatelessWidget {
  const _EmptySavedDhikrs();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mic_none,
              color: AppColors.sage.withOpacity(0.55),
              size: 42,
            ),
            const SizedBox(height: 14),
            Text(
              'لا توجد أذكار محفوظة بعد',
              textAlign: TextAlign.center,
              style: AppFonts.kufi(size: 18, weight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'سجّل الذكر بصوتك، وسنحوّله إلى نص لتتمكن من حفظه واستخدامه لاحقاً.',
              textAlign: TextAlign.center,
              style: AppFonts.arabic(
                size: 13,
                color: AppColors.ink2,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
