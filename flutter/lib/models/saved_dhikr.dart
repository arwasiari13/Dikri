import 'dart:convert';

class SavedDhikr {
  final String id;
  final String text;
  final DateTime createdAt;

  const SavedDhikr({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  String encode() => jsonEncode(toJson());

  factory SavedDhikr.fromJson(Map<String, dynamic> json) {
    return SavedDhikr(
      id: json['id'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  factory SavedDhikr.decode(String value) {
    return SavedDhikr.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }
}
