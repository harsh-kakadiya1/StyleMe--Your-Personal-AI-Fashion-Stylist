import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/clothing_item.dart';
import '../models/outfit_schedule.dart';
import '../models/user_profile.dart';

class WardrobeProvider extends ChangeNotifier {
  List<ClothingItem> _clothingItems = [];
  List<OutfitCombination> _savedOutfits = [];
  List<OutfitSchedule> _outfitSchedules = [];
  UserProfile? _userProfile;
  List<OutfitTag> _outfitTags = [];
  List<TaggedOutfit> _taggedOutfits = [];

  // Getters
  List<ClothingItem> get clothingItems => _clothingItems;
  List<ClothingItem> get topWearItems =>
      _clothingItems.where((item) => item.category == 'top').toList();
  List<ClothingItem> get bottomWearItems =>
      _clothingItems.where((item) => item.category == 'bottom').toList();
  List<OutfitCombination> get savedOutfits => _savedOutfits;
  List<OutfitSchedule> get outfitSchedules => _outfitSchedules;
  UserProfile? get userProfile => _userProfile;
  List<OutfitTag> get outfitTags => _outfitTags;
  List<TaggedOutfit> get taggedOutfits => _taggedOutfits;
  List<OutfitCombination> get starredOutfits => _savedOutfits.where((outfit) {
    final taggedOutfit = _taggedOutfits.firstWhere(
      (tagged) => tagged.outfitId == outfit.id,
      orElse: () => TaggedOutfit(
        outfitId: outfit.id,
        tagIds: [],
        createdAt: DateTime.now(),
      ),
    );
    return taggedOutfit.isStarred;
  }).toList();

  // Load clothing items from storage
  Future<void> loadClothingItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? itemsJson = prefs.getStringList('clothing_items');

    if (itemsJson != null) {
      _clothingItems = itemsJson
          .map(
            (item) => ClothingItem.fromJson(
              Map.fromEntries(
                item.split('|').map((e) {
                  final parts = e.split(':');
                  return MapEntry(parts[0], parts[1]);
                }),
              ),
            ),
          )
          .toList();

      // Clean up orphaned outfits after loading clothing items
      await _cleanupOrphanedOutfits();

      notifyListeners();
    }
  }

  // Save clothing items to storage
  Future<void> saveClothingItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> itemsJson = _clothingItems
        .map(
          (item) =>
              'id:${item.id}|imagePath:${item.imagePath}|category:${item.category}|type:${item.type}|addedDate:${item.addedDate.toIso8601String()}',
        )
        .toList();
    await prefs.setStringList('clothing_items', itemsJson);
  }

  // Add new clothing item
  Future<void> addClothingItem(ClothingItem item) async {
    _clothingItems.add(item);
    await saveClothingItems();
    notifyListeners();
  }

  // Delete clothing item
  Future<void> deleteClothingItem(String id) async {
    // Remove the clothing item
    _clothingItems.removeWhere((item) => item.id == id);

    // Auto-delete any saved outfits that contain this clothing item
    _savedOutfits.removeWhere(
      (outfit) => outfit.topId == id || outfit.bottomId == id,
    );

    // Save both updated lists to storage
    await saveClothingItems();
    await saveOutfitCombinations();

    notifyListeners();
  }

  // Load saved outfits from storage
  Future<void> loadSavedOutfits() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? outfitsJson = prefs.getStringList('saved_outfits');

    if (outfitsJson != null) {
      _savedOutfits = outfitsJson
          .map(
            (outfit) => OutfitCombination.fromJson(
              Map.fromEntries(
                outfit.split('|').map((e) {
                  final parts = e.split(':');
                  return MapEntry(parts[0], parts[1]);
                }),
              ),
            ),
          )
          .toList();

      // Clean up orphaned outfits after loading
      await _cleanupOrphanedOutfits();

      notifyListeners();
    }
  }

  // Save outfit combinations to storage
  Future<void> saveOutfitCombinations() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> outfitsJson = _savedOutfits
        .map(
          (outfit) =>
              'id:${outfit.id}|topId:${outfit.topId}|bottomId:${outfit.bottomId}|createdDate:${outfit.createdDate.toIso8601String()}',
        )
        .toList();
    await prefs.setStringList('saved_outfits', outfitsJson);
  }

  // Save new outfit combination
  Future<void> saveOutfitCombination(String topId, String bottomId) async {
    final outfit = OutfitCombination(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      topId: topId,
      bottomId: bottomId,
      createdDate: DateTime.now(),
    );

    _savedOutfits.add(outfit);
    await saveOutfitCombinations();
    notifyListeners();
  }

  // Delete saved outfit
  Future<void> deleteOutfitCombination(String id) async {
    _savedOutfits.removeWhere((outfit) => outfit.id == id);
    await saveOutfitCombinations();
    notifyListeners();
  }

  // Get clothing item by ID
  ClothingItem? getClothingItemById(String id) {
    try {
      return _clothingItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clean up orphaned outfits (outfits that reference non-existent clothing items)
  Future<void> _cleanupOrphanedOutfits() async {
    final validTopIds = _clothingItems
        .where((item) => item.category == 'top')
        .map((item) => item.id)
        .toSet();
    final validBottomIds = _clothingItems
        .where((item) => item.category == 'bottom')
        .map((item) => item.id)
        .toSet();

    // Remove outfits that reference non-existent clothing items
    _savedOutfits.removeWhere(
      (outfit) =>
          !validTopIds.contains(outfit.topId) ||
          !validBottomIds.contains(outfit.bottomId),
    );

    // Save the cleaned up outfits list
    await saveOutfitCombinations();
  }

  // Get outfit details with clothing item information
  Map<String, dynamic>? getOutfitDetails(String outfitId) {
    try {
      final outfit = _savedOutfits.firstWhere(
        (outfit) => outfit.id == outfitId,
      );
      final topItem = getClothingItemById(outfit.topId);
      final bottomItem = getClothingItemById(outfit.bottomId);

      if (topItem != null && bottomItem != null) {
        return {'outfit': outfit, 'topItem': topItem, 'bottomItem': bottomItem};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if an outfit is valid (both clothing items still exist)
  bool isOutfitValid(String outfitId) {
    try {
      final outfit = _savedOutfits.firstWhere(
        (outfit) => outfit.id == outfitId,
      );
      final topItem = getClothingItemById(outfit.topId);
      final bottomItem = getClothingItemById(outfit.bottomId);

      return topItem != null && bottomItem != null;
    } catch (e) {
      return false;
    }
  }

  // Outfit Schedule Methods

  // Load outfit schedules from storage
  Future<void> loadOutfitSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? schedulesJson = prefs.getStringList('outfit_schedules');

    if (schedulesJson != null) {
      _outfitSchedules = schedulesJson
          .map(
            (schedule) => OutfitSchedule.fromJson(
              Map.fromEntries(
                schedule.split('|').map((e) {
                  final parts = e.split(':');
                  return MapEntry(parts[0], parts[1]);
                }),
              ),
            ),
          )
          .toList();

      notifyListeners();
    }
  }

  // Save outfit schedules to storage
  Future<void> saveOutfitSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> schedulesJson = _outfitSchedules
        .map(
          (schedule) =>
              'id:${schedule.id}|date:${schedule.date.toIso8601String()}|topId:${schedule.topId ?? ''}|bottomId:${schedule.bottomId ?? ''}|note:${schedule.note ?? ''}|createdAt:${schedule.createdAt.toIso8601String()}|updatedAt:${schedule.updatedAt?.toIso8601String() ?? ''}',
        )
        .toList();
    await prefs.setStringList('outfit_schedules', schedulesJson);
  }

  // Add or update outfit schedule
  Future<void> addOrUpdateOutfitSchedule(OutfitSchedule schedule) async {
    final existingIndex = _outfitSchedules.indexWhere(
      (s) => s.id == schedule.id,
    );

    if (existingIndex >= 0) {
      _outfitSchedules[existingIndex] = schedule.copyWith(
        updatedAt: DateTime.now(),
      );
    } else {
      _outfitSchedules.add(schedule);
    }

    await saveOutfitSchedules();
    notifyListeners();
  }

  // Get outfit schedule for a specific date
  OutfitSchedule? getOutfitScheduleForDate(DateTime date) {
    try {
      return _outfitSchedules.firstWhere(
        (schedule) =>
            schedule.date.year == date.year &&
            schedule.date.month == date.month &&
            schedule.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  // Delete outfit schedule
  Future<void> deleteOutfitSchedule(String id) async {
    _outfitSchedules.removeWhere((schedule) => schedule.id == id);
    await saveOutfitSchedules();
    notifyListeners();
  }

  // Get outfit schedule by ID
  OutfitSchedule? getOutfitScheduleById(String id) {
    try {
      return _outfitSchedules.firstWhere((schedule) => schedule.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get outfit details for a schedule
  Map<String, dynamic>? getScheduleOutfitDetails(String scheduleId) {
    try {
      final schedule = _outfitSchedules.firstWhere(
        (schedule) => schedule.id == scheduleId,
      );

      if (schedule.topId != null && schedule.bottomId != null) {
        final topItem = getClothingItemById(schedule.topId!);
        final bottomItem = getClothingItemById(schedule.bottomId!);

        if (topItem != null && bottomItem != null) {
          return {
            'schedule': schedule,
            'topItem': topItem,
            'bottomItem': bottomItem,
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // User Profile Methods

  // Load user profile from storage
  Future<void> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString('user_profile');

    if (profileJson != null) {
      _userProfile = UserProfile.fromJson(
        Map.fromEntries(
          profileJson.split('|').map((e) {
            final parts = e.split(':');
            return MapEntry(parts[0], parts[1]);
          }),
        ),
      );
      notifyListeners();
    }
  }

  // Save user profile to storage
  Future<void> saveUserProfile() async {
    if (_userProfile != null) {
      final prefs = await SharedPreferences.getInstance();
      final String profileJson =
          'id:${_userProfile!.id}|name:${_userProfile!.name}|birthday:${_userProfile!.birthday?.toIso8601String() ?? ''}|profilePhotoPath:${_userProfile!.profilePhotoPath ?? ''}|favoriteColors:${_userProfile!.favoriteColors.join(',')}|createdAt:${_userProfile!.createdAt.toIso8601String()}|updatedAt:${_userProfile!.updatedAt?.toIso8601String() ?? ''}';
      await prefs.setString('user_profile', profileJson);
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    _userProfile = profile.copyWith(updatedAt: DateTime.now());
    await saveUserProfile();
    notifyListeners();
  }

  // Create initial user profile
  Future<void> createUserProfile(String name) async {
    _userProfile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
    );
    await saveUserProfile();
    notifyListeners();
  }

  // Outfit Tags Methods

  // Load outfit tags from storage
  Future<void> loadOutfitTags() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? tagsJson = prefs.getStringList('outfit_tags');

    if (tagsJson != null) {
      _outfitTags = tagsJson
          .map(
            (tag) => OutfitTag.fromJson(
              Map.fromEntries(
                tag.split('|').map((e) {
                  final parts = e.split(':');
                  return MapEntry(parts[0], parts[1]);
                }),
              ),
            ),
          )
          .toList();
      notifyListeners();
    }
  }

  // Save outfit tags to storage
  Future<void> saveOutfitTags() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> tagsJson = _outfitTags
        .map(
          (tag) =>
              'id:${tag.id}|name:${tag.name}|color:${tag.color}|createdAt:${tag.createdAt.toIso8601String()}',
        )
        .toList();
    await prefs.setStringList('outfit_tags', tagsJson);
  }

  // Add outfit tag
  Future<void> addOutfitTag(OutfitTag tag) async {
    _outfitTags.add(tag);
    await saveOutfitTags();
    notifyListeners();
  }

  // Delete outfit tag
  Future<void> deleteOutfitTag(String id) async {
    _outfitTags.removeWhere((tag) => tag.id == id);
    // Remove tag from all tagged outfits
    _taggedOutfits.removeWhere((tagged) => tagged.tagIds.contains(id));
    await saveOutfitTags();
    await saveTaggedOutfits();
    notifyListeners();
  }

  // Tagged Outfits Methods

  // Load tagged outfits from storage
  Future<void> loadTaggedOutfits() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? taggedJson = prefs.getStringList('tagged_outfits');

    if (taggedJson != null) {
      _taggedOutfits = taggedJson
          .map(
            (tagged) => TaggedOutfit.fromJson(
              Map.fromEntries(
                tagged.split('|').map((e) {
                  final parts = e.split(':');
                  return MapEntry(parts[0], parts[1]);
                }),
              ),
            ),
          )
          .toList();
      notifyListeners();
    }
  }

  // Save tagged outfits to storage
  Future<void> saveTaggedOutfits() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> taggedJson = _taggedOutfits
        .map(
          (tagged) =>
              'outfitId:${tagged.outfitId}|tagIds:${tagged.tagIds.join(',')}|isStarred:${tagged.isStarred}|createdAt:${tagged.createdAt.toIso8601String()}|updatedAt:${tagged.updatedAt?.toIso8601String() ?? ''}',
        )
        .toList();
    await prefs.setStringList('tagged_outfits', taggedJson);
  }

  // Tag an outfit
  Future<void> tagOutfit(
    String outfitId,
    List<String> tagIds, {
    bool isStarred = false,
  }) async {
    final existingIndex = _taggedOutfits.indexWhere(
      (tagged) => tagged.outfitId == outfitId,
    );

    if (existingIndex >= 0) {
      _taggedOutfits[existingIndex] = _taggedOutfits[existingIndex].copyWith(
        tagIds: tagIds,
        isStarred: isStarred,
        updatedAt: DateTime.now(),
      );
    } else {
      _taggedOutfits.add(
        TaggedOutfit(
          outfitId: outfitId,
          tagIds: tagIds,
          isStarred: isStarred,
          createdAt: DateTime.now(),
        ),
      );
    }

    await saveTaggedOutfits();
    notifyListeners();
  }

  // Toggle outfit star status
  Future<void> toggleOutfitStar(String outfitId) async {
    final existingIndex = _taggedOutfits.indexWhere(
      (tagged) => tagged.outfitId == outfitId,
    );

    if (existingIndex >= 0) {
      _taggedOutfits[existingIndex] = _taggedOutfits[existingIndex].copyWith(
        isStarred: !_taggedOutfits[existingIndex].isStarred,
        updatedAt: DateTime.now(),
      );
    } else {
      _taggedOutfits.add(
        TaggedOutfit(
          outfitId: outfitId,
          tagIds: [],
          isStarred: true,
          createdAt: DateTime.now(),
        ),
      );
    }

    await saveTaggedOutfits();
    notifyListeners();
  }

  // Get tags for an outfit
  List<OutfitTag> getOutfitTags(String outfitId) {
    final taggedOutfit = _taggedOutfits.firstWhere(
      (tagged) => tagged.outfitId == outfitId,
      orElse: () => TaggedOutfit(
        outfitId: outfitId,
        tagIds: [],
        createdAt: DateTime.now(),
      ),
    );

    return _outfitTags
        .where((tag) => taggedOutfit.tagIds.contains(tag.id))
        .toList();
  }

  // Check if outfit is starred
  bool isOutfitStarred(String outfitId) {
    final taggedOutfit = _taggedOutfits.firstWhere(
      (tagged) => tagged.outfitId == outfitId,
      orElse: () => TaggedOutfit(
        outfitId: outfitId,
        tagIds: [],
        createdAt: DateTime.now(),
      ),
    );
    return taggedOutfit.isStarred;
  }

  // Initialize all data
  Future<void> initializeData() async {
    await loadClothingItems();
    await loadSavedOutfits();
    await loadOutfitSchedules();
    await loadUserProfile();
    await loadOutfitTags();
    await loadTaggedOutfits();
  }
}

class OutfitCombination {
  final String id;
  final String topId;
  final String bottomId;
  final DateTime createdDate;

  OutfitCombination({
    required this.id,
    required this.topId,
    required this.bottomId,
    required this.createdDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topId': topId,
      'bottomId': bottomId,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  factory OutfitCombination.fromJson(Map<String, dynamic> json) {
    return OutfitCombination(
      id: json['id'],
      topId: json['topId'],
      bottomId: json['bottomId'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}
