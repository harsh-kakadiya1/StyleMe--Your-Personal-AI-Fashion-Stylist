import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../providers/wardrobe_provider.dart';
import 'dart:io';

class MakePairScreen extends StatefulWidget {
  const MakePairScreen({super.key});

  @override
  State<MakePairScreen> createState() => _MakePairScreenState();
}

class _MakePairScreenState extends State<MakePairScreen> {
  int _selectedTopIndex = 0;
  int _selectedBottomIndex = 0;
  final PageController _topPageController = PageController();
  final PageController _bottomPageController = PageController();

  @override
  void initState() {
    super.initState();
    // Initialize page controllers at middle for infinite swipe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WardrobeProvider>();
      provider.loadClothingItems();
      provider.loadSavedOutfits();

      if (_topPageController.hasClients && provider.topWearItems.isNotEmpty) {
        _topPageController.jumpToPage(5000);
      }
      if (_bottomPageController.hasClients &&
          provider.bottomWearItems.isNotEmpty) {
        _bottomPageController.jumpToPage(5000);
      }
    });
  }

  @override
  void dispose() {
    _topPageController.dispose();
    _bottomPageController.dispose();
    super.dispose();
  }

  void _onTopPageChanged(int index) {
    setState(() {
      _selectedTopIndex = index;
    });

    // Implement infinite swipe by resetting to middle when reaching boundaries
    if (index >= 9500 || index <= 500) {
      final provider = context.read<WardrobeProvider>();
      if (provider.topWearItems.isNotEmpty) {
        final middleIndex = 5000 + (index % provider.topWearItems.length);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _topPageController.jumpToPage(middleIndex);
        });
      }
    }
  }

  void _onBottomPageChanged(int index) {
    setState(() {
      _selectedBottomIndex = index;
    });

    // Implement infinite swipe by resetting to middle when reaching boundaries
    if (index >= 9500 || index <= 500) {
      final provider = context.read<WardrobeProvider>();
      if (provider.bottomWearItems.isNotEmpty) {
        final middleIndex = 5000 + (index % provider.bottomWearItems.length);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _bottomPageController.jumpToPage(middleIndex);
        });
      }
    }
  }

  Future<void> _saveOutfitCombination() async {
    final provider = context.read<WardrobeProvider>();
    final topItems = provider.topWearItems;
    final bottomItems = provider.bottomWearItems;

    if (topItems.isNotEmpty && bottomItems.isNotEmpty) {
      final selectedTop = topItems[_selectedTopIndex % topItems.length];
      final selectedBottom =
          bottomItems[_selectedBottomIndex % bottomItems.length];

      await provider.saveOutfitCombination(selectedTop.id, selectedBottom.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Outfit saved: ${selectedTop.type} + ${selectedBottom.type}',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add both top and bottom wear items first'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WardrobeProvider>(
      builder: (context, wardrobeProvider, child) {
        final topItems = wardrobeProvider.topWearItems;
        final bottomItems = wardrobeProvider.bottomWearItems;

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
              // Main content area with two sections
              Expanded(
                child: Column(
                  children: [
                    // Top section (50% height) - Tops
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            // Section header
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.checkroom,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Top',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (topItems.isNotEmpty)
                                    Text(
                                      '${(_selectedTopIndex % topItems.length) + 1}/${topItems.length}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Tops PageView
                            Expanded(
                              child: topItems.isEmpty
                                  ? _buildEmptySection('top')
                                  : PageView.builder(
                                      controller: _topPageController,
                                      onPageChanged: _onTopPageChanged,
                                      itemCount: topItems.isEmpty
                                          ? 0
                                          : 10000, // Large number for infinite swipe
                                      itemBuilder: (context, index) {
                                        final actualIndex =
                                            index % topItems.length;
                                        return _buildClothingPageView(
                                          topItems[actualIndex],
                                          'top',
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Divider
                    Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    // Bottom section (50% height) - Bottoms
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            // Section header
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.accessibility,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'BOTTOM',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (bottomItems.isNotEmpty)
                                    Text(
                                      '${(_selectedBottomIndex % bottomItems.length) + 1}/${bottomItems.length}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Bottoms PageView with Save Button positioned at bottom right
                            Expanded(
                              child: Stack(
                                children: [
                                  // PageView for bottom items
                                  bottomItems.isEmpty
                                      ? _buildEmptySection('bottom')
                                      : PageView.builder(
                                          controller: _bottomPageController,
                                          onPageChanged: _onBottomPageChanged,
                                          itemCount: bottomItems.isEmpty
                                              ? 0
                                              : 10000, // Large number for infinite swipe
                                          itemBuilder: (context, index) {
                                            final actualIndex =
                                                index % bottomItems.length;
                                            return _buildClothingPageView(
                                              bottomItems[actualIndex],
                                              'bottom',
                                            );
                                          },
                                        ),

                                  // Save Combination Button positioned at bottom right
                                  if (bottomItems.isNotEmpty)
                                    Positioned(
                                      bottom: 16,
                                      right: 16,
                                      child: GestureDetector(
                                        onTap:
                                            (topItems.isNotEmpty &&
                                                bottomItems.isNotEmpty)
                                            ? _saveOutfitCombination
                                            : null,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.7,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.bookmark,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Save',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptySection(String category) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            category == 'top'
                ? Icons.checkroom_outlined
                : Icons.accessibility_new_outlined,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No ${category == 'top' ? 'top' : 'bottom'} wear items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some ${category == 'top' ? 'tops' : 'bottoms'} in the Add Clothes tab',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildClothingPageView(ClothingItem item, String category) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Image
            Positioned.fill(
              child: ImageDisplayWidget(imagePath: item.imagePath),
            ),

            // Category and type info overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
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
                      item.category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      item.type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
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
