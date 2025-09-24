import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'dart:io';
import '../providers/wardrobe_provider.dart';
import '../models/user_profile.dart';
import '../models/clothing_item.dart';
import 'profile_edit_dialog.dart';
import 'outfit_tags_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WardrobeProvider>().initializeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Consumer<WardrobeProvider>(
        builder: (context, wardrobeProvider, child) {
          final userProfile = wardrobeProvider.userProfile;
          final starredOutfits = wardrobeProvider.starredOutfits;
          final outfitTags = wardrobeProvider.outfitTags;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileSection(userProfile, wardrobeProvider),
                const SizedBox(height: 24),
                _buildFavoritesSection(starredOutfits, wardrobeProvider),
                const SizedBox(height: 24),
                _buildTagsSection(outfitTags, wardrobeProvider),
                const SizedBox(height: 24),
                _buildStatsSection(wardrobeProvider),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileSection(
    UserProfile? userProfile,
    WardrobeProvider provider,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  FlutterRemix.user_3_line,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Profile',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (userProfile != null) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    backgroundImage: userProfile.profilePhotoPath != null
                        ? FileImage(File(userProfile.profilePhotoPath!))
                        : null,
                    child: userProfile.profilePhotoPath == null
                        ? Icon(
                            FlutterRemix.user_3_line,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProfile.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (userProfile.birthday != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Born ${_formatDate(userProfile.birthday!)}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                          ),
                        ],
                        if (userProfile.favoriteColors.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: userProfile.favoriteColors.take(3).map((
                              color,
                            ) {
                              return Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Color(
                                    int.parse(color.replaceFirst('#', '0xff')),
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                    width: 1,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(
                      FlutterRemix.user_3_line,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No Profile',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create your profile to get started',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showProfileEditDialog(provider),
                icon: const Icon(FlutterRemix.edit_line),
                label: Text(
                  userProfile != null ? 'Edit Profile' : 'Create Profile',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesSection(
    List<OutfitCombination> starredOutfits,
    WardrobeProvider provider,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  FlutterRemix.heart_line,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Favorite Outfits',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${starredOutfits.length}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (starredOutfits.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      FlutterRemix.heart_line,
                      size: 48,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No favorite outfits yet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Star outfits you love to see them here',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: starredOutfits.length,
                  itemBuilder: (context, index) {
                    final outfit = starredOutfits[index];
                    final outfitDetails = provider.getOutfitDetails(outfit.id);

                    if (outfitDetails == null) return const SizedBox.shrink();

                    final topItem = outfitDetails['topItem'] as ClothingItem;
                    final bottomItem =
                        outfitDetails['bottomItem'] as ClothingItem;

                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(topItem.imagePath),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        child: Icon(
                                          FlutterRemix.shirt_line,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      FlutterRemix.heart_fill,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${topItem.type} + ${bottomItem.type}',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection(
    List<OutfitTag> outfitTags,
    WardrobeProvider provider,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  FlutterRemix.price_tag_3_line,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Outfit Tags',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${outfitTags.length}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (outfitTags.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      FlutterRemix.price_tag_3_line,
                      size: 48,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No tags created yet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create tags to organize your outfits',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: outfitTags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(tag.color.replaceFirst('#', '0xff')),
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color(
                          int.parse(tag.color.replaceFirst('#', '0xff')),
                        ),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      tag.name,
                      style: TextStyle(
                        color: Color(
                          int.parse(tag.color.replaceFirst('#', '0xff')),
                        ),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showOutfitTagsDialog(provider),
                icon: const Icon(FlutterRemix.add_line),
                label: const Text('Manage Tags'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(WardrobeProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  FlutterRemix.bar_chart_line,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Statistics',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Clothing Items',
                    '${provider.clothingItems.length}',
                    FlutterRemix.shirt_line,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Saved Outfits',
                    '${provider.savedOutfits.length}',
                    FlutterRemix.heart_line,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Scheduled Outfits',
                    '${provider.outfitSchedules.length}',
                    FlutterRemix.calendar_line,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Favorite Outfits',
                    '${provider.starredOutfits.length}',
                    FlutterRemix.star_line,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return SizedBox(
      height: 120,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showProfileEditDialog(WardrobeProvider provider) {
    showDialog(
      context: context,
      builder: (context) => ProfileEditDialog(
        userProfile: provider.userProfile,
        onProfileUpdated: (profile) {
          if (provider.userProfile == null) {
            provider.createUserProfile(profile.name);
          } else {
            provider.updateUserProfile(profile);
          }
        },
      ),
    );
  }

  void _showOutfitTagsDialog(WardrobeProvider provider) {
    showDialog(
      context: context,
      builder: (context) => OutfitTagsDialog(
        outfitTags: provider.outfitTags,
        onTagAdded: (tag) => provider.addOutfitTag(tag),
        onTagDeleted: (id) => provider.deleteOutfitTag(id),
      ),
    );
  }
}
