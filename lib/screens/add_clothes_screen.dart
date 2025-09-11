import 'package:flutter/material.dart';
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
    // Store context before async operations
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final provider = context.read<WardrobeProvider>();

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Show category selection dialog
        final String? category = await _showCategorySelectionDialog();
        if (category != null) {
          // Show type selection dialog
          final String? type = await _showTypeSelectionDialog(category);
          if (type != null) {
            // Save image to local storage
            final String savedPath = await _copyImageToLocalStorage(
              File(pickedFile.path),
            );

            // Create clothing item
            final ClothingItem newItem = ClothingItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              imagePath: savedPath,
              category: category,
              type: type,
              addedDate: DateTime.now(),
            );

            // Add to provider
            await provider.addClothingItem(newItem);

            if (mounted) {
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Clothing item added successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error adding clothing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _showCategorySelectionDialog() async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.checkroom),
                title: const Text('Top Wear'),
                onTap: () => Navigator.of(context).pop('top'),
              ),
              ListTile(
                leading: const Icon(Icons.accessibility),
                title: const Text('Bottom Wear'),
                onTap: () => Navigator.of(context).pop('bottom'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _showTypeSelectionDialog(String category) async {
    List<String> types = [];
    String title = '';

    if (category == 'top') {
      title = 'Select Top Wear Type';
      types = [
        'T-Shirt',
        'Shirt',
        'Sweater',
        'Jacket',
        'Hoodie',
        'Blouse',
        'Tank Top',
      ];
    } else {
      title = 'Select Bottom Wear Type';
      types = [
        'Jeans',
        'Formal Pants',
        'Track Pants',
        'Cargo Pants',
        'Shorts',
        'Skirt',
        'Leggings',
      ];
    }

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: types.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(types[index]),
                  onTap: () => Navigator.of(context).pop(types[index]),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<String> _copyImageToLocalStorage(File imageFile) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory wardrobeDir = Directory('${appDir.path}/wardrobe');

    if (!await wardrobeDir.exists()) {
      await wardrobeDir.create(recursive: true);
    }

    final String fileName =
        'clothing_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String newPath = '${wardrobeDir.path}/$fileName';

    await imageFile.copy(newPath);
    return newPath;
  }

  Future<void> _deleteClothingItem(String id) async {
    try {
      await context.read<WardrobeProvider>().deleteClothingItem(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clothing item removed'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting item: $e'),
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
                child: ElevatedButton.icon(
                  onPressed: _addNewClothing,
                  icon: const Icon(Icons.add_a_photo, size: 24),
                  label: const Text(
                    'Add New Clothing',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
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
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                  onPressed: () => _deleteClothingItem(item.id),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ),
            ),

            // Category and type info
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item.type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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
