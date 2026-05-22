import 'dart:convert';

class SessionRecord {
  final DateTime date;
  final int target;
  final int completed;
  final String? dhikrText;

  const SessionRecord({
    required this.date,
    required this.target,
    required this.completed,
    this.dhikrText,
  });

  bool get isComplete => completed >= target;
  double get progress => target == 0 ? 0 : (completed / target).clamp(0, 1);

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'target': target,
        'completed': completed,
        if (dhikrText != null && dhikrText!.isNotEmpty) 'dhikrText': dhikrText,
      };

  String encode() => jsonEncode(toJson());

  factory SessionRecord.fromJson(Map<String, dynamic> json) {
    return SessionRecord(
      date: DateTime.parse(json['date'] as String),
      target: (json['target'] as num).toInt(),
      completed: (json['completed'] as num).toInt(),
      dhikrText: json['dhikrText'] as String?,
    );
  }

  factory SessionRecord.decode(String value) {
    return SessionRecord.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }
}
