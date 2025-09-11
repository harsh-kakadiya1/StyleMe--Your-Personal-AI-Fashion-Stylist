import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wardrobe_provider.dart';
import '../models/clothing_item.dart';
import 'dart:io';

class SavedOutfitsScreen extends StatefulWidget {
  const SavedOutfitsScreen({super.key});

  @override
  State<SavedOutfitsScreen> createState() => _SavedOutfitsScreenState();
}

class _SavedOutfitsScreenState extends State<SavedOutfitsScreen> {
  @override
  void initState() {
    super.initState();
    // Load saved outfits when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WardrobeProvider>();
      provider.loadClothingItems();
      provider.loadSavedOutfits();
    });
  }

  Future<void> _deleteOutfit(String outfitId) async {
    try {
      await context.read<WardrobeProvider>().deleteOutfitCombination(outfitId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Outfit removed'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing outfit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WardrobeProvider>(
      builder: (context, wardrobeProvider, child) {
        final savedOutfits = wardrobeProvider.savedOutfits;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.1),
                Colors.white,
              ],
            ),
          ),
          child: Column(
            children: [
              // Header section
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.checkroom,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Saved Outfits',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${wardrobeProvider.savedOutfits.where((outfit) => wardrobeProvider.isOutfitValid(outfit.id)).length} outfit combinations saved',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Outfits grid
              Expanded(
                child: savedOutfits.isEmpty
                    ? _buildEmptyState()
                    : _buildOutfitsGrid(savedOutfits, wardrobeProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.style_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No saved outfits yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create and save outfit combinations\nin the Make Pair tab',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitsGrid(
    List<dynamic> savedOutfits,
    WardrobeProvider provider,
  ) {
    // Filter out invalid outfits (outfits with missing clothing items)
    final validOutfits = savedOutfits
        .where((outfit) => provider.isOutfitValid(outfit.id))
        .toList();

    if (validOutfits.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: validOutfits.length,
      itemBuilder: (context, index) {
        final outfit = validOutfits[index];
        final outfitDetails = provider.getOutfitDetails(outfit.id);

        if (outfitDetails == null) {
          return _buildErrorCard();
        }

        final topItem = outfitDetails['topItem'] as ClothingItem;
        final bottomItem = outfitDetails['bottomItem'] as ClothingItem;

        return _buildOutfitCard(outfit, topItem, bottomItem);
      },
    );
  }

  Widget _buildOutfitCard(
    dynamic outfit,
    ClothingItem topItem,
    ClothingItem bottomItem,
  ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Outfit combination display
            Positioned.fill(
              child: Column(
                children: [
                  // Top item (50% height)
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: ImageDisplayWidget(imagePath: topItem.imagePath),
                      ),
                    ),
                  ),
                  // Bottom item (50% height)
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      child: ImageDisplayWidget(
                        imagePath: bottomItem.imagePath,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Delete button overlay
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                  onPressed: () => _showDeleteDialog(outfit.id),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),
            ),

            // Outfit info overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${topItem.type} + ${bottomItem.type}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDate(outfit.createdDate),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[100],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              'Outfit not found',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String outfitId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Outfit'),
          content: const Text(
            'Are you sure you want to delete this outfit combination?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteOutfit(outfitId);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class ImageDisplayWidget extends StatelessWidget {
  final String imagePath;

  const ImageDisplayWidget({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkFileExists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data == true) {
          return Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget();
            },
          );
        } else {
          return _buildErrorWidget();
        }
      },
    );
  }

  Future<bool> _checkFileExists() async {
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Image not found',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}

