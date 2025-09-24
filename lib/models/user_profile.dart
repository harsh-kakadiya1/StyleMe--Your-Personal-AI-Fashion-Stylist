import 'package:flutter/foundation.dart';

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

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'])
          : null,
      profilePhotoPath: json['profilePhotoPath'],
      favoriteColors: List<String>.from(json['favoriteColors'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
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
      createdAt: DateTime.parse(json['createdAt']),
    );
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
      tagIds: List<String>.from(json['tagIds'] ?? []),
      isStarred: json['isStarred'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
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
