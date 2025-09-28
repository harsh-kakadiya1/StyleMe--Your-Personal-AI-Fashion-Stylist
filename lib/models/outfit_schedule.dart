class OutfitSchedule {
  final String id;
  final DateTime date;
  final String? topId;
  final String? bottomId;
  final String? note;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OutfitSchedule({
    required this.id,
    required this.date,
    this.topId,
    this.bottomId,
    this.note,
    required this.createdAt,
    this.updatedAt,
  });

  // Check if the schedule has an outfit assigned
  bool get hasOutfit => topId != null && bottomId != null;

  // Check if the schedule has a note
  bool get hasNote => note != null && note!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'topId': topId,
      'bottomId': bottomId,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory OutfitSchedule.fromJson(Map<String, dynamic> json) {
    return OutfitSchedule(
      id: json['id'],
      date: DateTime.parse(json['date']),
      topId: json['topId'],
      bottomId: json['bottomId'],
      note: json['note'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  // Create a copy with updated fields
  OutfitSchedule copyWith({
    String? id,
    DateTime? date,
    String? topId,
    String? bottomId,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OutfitSchedule(
      id: id ?? this.id,
      date: date ?? this.date,
      topId: topId ?? this.topId,
      bottomId: bottomId ?? this.bottomId,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
