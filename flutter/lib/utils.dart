const _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

String toArabic(Object n) {
  return n.toString().split('').map((d) {
    final i = int.tryParse(d);
    return i != null ? _arabicDigits[i] : d;
  }).join();
}

String formatDuration(int totalSeconds) {
  final m = totalSeconds ~/ 60;
  final s = totalSeconds % 60;
  final ms = toArabic(m).padLeft(2, '٠');
  final ss = toArabic(s).padLeft(2, '٠');
  return '$ms:$ss';
}
