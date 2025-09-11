import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../providers/wardrobe_provider.dart';
import 'dart:io';

class AddClothesScreen extends StatefulWidget {
  const AddClothesScreen({super.key});

  @override
  State<AddClothesScreen> createState() => _AddClothesScreenState();
}

class _AddClothesScreenState extends State<AddClothesScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load clothing items when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WardrobeProvider>().loadClothingItems();
    });
  }

  Future<void> _addNewClothing() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final provider = context.read<WardrobeProvider>();

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final String? category = await _showCategorySelectionDialog();
        if (category != null) {
          final String? type = await _showTypeSelectionDialog(category);
          if (type != null) {
            final String savedPath = await _copyImageToLocalStorage(
              File(pickedFile.path),
            );
            final ClothingItem newItem = ClothingItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              imagePath: savedPath,
              category: category,
              type: type,
              addedDate: DateTime.now(),
            );
            await provider.addClothingItem(newItem);
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Item added to wardrobe.')),
            );
          }
        }
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<String?> _showCategorySelectionDialog() async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Category'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'top'),
              child: const Text('Top Wear'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'bottom'),
              child: const Text('Bottom Wear'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showTypeSelectionDialog(String category) async {
    final types = category == 'top'
        ? ['T-Shirt', 'Shirt', 'Sweater', 'Jacket', 'Hoodie']
        : ['Jeans', 'Pants', 'Shorts', 'Skirt'];
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Select ${category == 'top' ? 'Top' : 'Bottom'} Type'),
          children: types
              .map(
                (type) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, type),
                  child: Text(type),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Future<String> _copyImageToLocalStorage(File imageFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final wardrobeDir = Directory('${appDir.path}/wardrobe');
    if (!await wardrobeDir.exists()) {
      await wardrobeDir.create(recursive: true);
    }
    final fileName = 'clothing_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newPath = '${wardrobeDir.path}/$fileName';
    await imageFile.copy(newPath);
    return newPath;
  }

  Future<void> _deleteClothingItem(String id) async {
    await context.read<WardrobeProvider>().deleteClothingItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item removed from wardrobe.')),
    );
  }

  void _showDeleteDialog(String itemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: const Text(
            'Are you sure you want to delete this clothing item from your wardrobe?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteClothingItem(itemId);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WardrobeProvider>(
      builder: (context, wardrobeProvider, child) {
        final clothingItems = wardrobeProvider.clothingItems;

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
                      Icons.add_a_photo,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Add New Clothing',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${clothingItems.length} clothing items in your wardrobe',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Add clothing button
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: _addNewClothing,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Add New Clothing',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Clothing items grid
              Expanded(
                child: clothingItems.isEmpty
                    ? _buildEmptyState()
                    : _buildClothingGrid(clothingItems),
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
          Icon(Icons.checkroom_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Your wardrobe is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button above to add your first clothing item',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildClothingGrid(List<ClothingItem> clothingItems) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: clothingItems.length,
      itemBuilder: (context, index) {
        return _buildClothingCard(clothingItems[index]);
      },
    );
  }

  Widget _buildClothingCard(ClothingItem item) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Image
            Positioned.fill(
              child: ImageDisplayWidget(imagePath: item.imagePath),
            ),

            // Delete button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _showDeleteDialog(item.id),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Icon(Icons.close, size: 16, color: Colors.grey[600]),
                ),
              ),
            ),

            // Category and type info
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.category == 'top'
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.type,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
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

  Future<bool> _checkFileExists() async {
    return File(imagePath).exists();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkFileExists(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Image.file(File(imagePath), fit: BoxFit.cover);
        }
        return Container(
          color: Colors.grey[200],
          child: Icon(FlutterRemix.error_warning_line, color: Colors.grey[400]),
        );
      },
    );
  }
}
