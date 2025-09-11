class ClothingItem {
  final String id;
  final String imagePath;
  final String category; // 'top' or 'bottom'
  final String type; // specific type like 'shirt', 'jeans', etc.
  final DateTime addedDate;

  ClothingItem({
    required this.id,
    required this.imagePath,
    required this.category,
    required this.type,
    required this.addedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'category': category,
      'type': type,
      'addedDate': addedDate.toIso8601String(),
    };
  }

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'],
      imagePath: json['imagePath'],
      category: json['category'],
      type: json['type'],
      addedDate: DateTime.parse(json['addedDate']),
    );
  }
}
