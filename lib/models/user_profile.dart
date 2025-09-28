class UserProfile {
  final String id;
  final String name;
  final DateTime? birthday;
  final String? profilePhotoPath;
  final List<String> favoriteColors;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    this.birthday,
    this.profilePhotoPath,
    this.favoriteColors = const [],
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthday': birthday?.toIso8601String(),
      'profilePhotoPath': profilePhotoPath,
      'favoriteColors': favoriteColors,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error parsing date: $dateString, error: $e');
      return null;
    }
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      birthday: json['birthday'] != null ? _parseDate(json['birthday']) : null,
      profilePhotoPath: json['profilePhotoPath'],
      favoriteColors: _parseFavoriteColors(json['favoriteColors']),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? _parseDate(json['updatedAt'])
          : null,
    );
  }

  static List<String> _parseFavoriteColors(dynamic favoriteColors) {
    if (favoriteColors == null) {
      return [];
    }

    if (favoriteColors is List) {
      return List<String>.from(favoriteColors);
    }

    if (favoriteColors is String) {
      // Handle case where it's stored as a single string
      return favoriteColors.isNotEmpty ? [favoriteColors] : [];
    }

    // Fallback for any other type
    return [];
  }

  UserProfile copyWith({
    String? id,
    String? name,
    DateTime? birthday,
    String? profilePhotoPath,
    List<String>? favoriteColors,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      favoriteColors: favoriteColors ?? this.favoriteColors,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class OutfitTag {
  final String id;
  final String name;
  final String color;
  final DateTime createdAt;

  OutfitTag({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OutfitTag.fromJson(Map<String, dynamic> json) {
    return OutfitTag(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error parsing date: $dateString, error: $e');
      return null;
    }
  }
}

class TaggedOutfit {
  final String outfitId;
  final List<String> tagIds;
  final bool isStarred;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TaggedOutfit({
    required this.outfitId,
    required this.tagIds,
    this.isStarred = false,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'outfitId': outfitId,
      'tagIds': tagIds,
      'isStarred': isStarred,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory TaggedOutfit.fromJson(Map<String, dynamic> json) {
    return TaggedOutfit(
      outfitId: json['outfitId'],
      tagIds: _parseTagIds(json['tagIds']),
      isStarred: _parseIsStarred(json['isStarred']),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? _parseDate(json['updatedAt'])
          : null,
    );
  }

  static DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error parsing date: $dateString, error: $e');
      return null;
    }
  }

  static bool _parseIsStarred(dynamic isStarred) {
    if (isStarred == null) {
      return false;
    }

    if (isStarred is bool) {
      return isStarred;
    }

    if (isStarred is String) {
      return isStarred.toLowerCase() == 'true';
    }

    // Fallback for any other type
    return false;
  }

  static List<String> _parseTagIds(dynamic tagIds) {
    if (tagIds == null) {
      return [];
    }

    if (tagIds is List) {
      return List<String>.from(tagIds);
    }

    if (tagIds is String) {
      // Handle case where it's stored as a single string
      return tagIds.isNotEmpty ? [tagIds] : [];
    }

    // Fallback for any other type
    return [];
  }

  TaggedOutfit copyWith({
    String? outfitId,
    List<String>? tagIds,
    bool? isStarred,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaggedOutfit(
      outfitId: outfitId ?? this.outfitId,
      tagIds: tagIds ?? this.tagIds,
      isStarred: isStarred ?? this.isStarred,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
