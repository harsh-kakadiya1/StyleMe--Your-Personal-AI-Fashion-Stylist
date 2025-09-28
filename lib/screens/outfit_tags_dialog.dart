import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import '../models/user_profile.dart';

class OutfitTagsDialog extends StatefulWidget {
  final List<OutfitTag> outfitTags;
  final Function(OutfitTag) onTagAdded;
  final Function(String) onTagDeleted;

  const OutfitTagsDialog({
    super.key,
    required this.outfitTags,
    required this.onTagAdded,
    required this.onTagDeleted,
  });

  @override
  State<OutfitTagsDialog> createState() => _OutfitTagsDialogState();
}

class _OutfitTagsDialogState extends State<OutfitTagsDialog> {
  late TextEditingController _tagNameController;
  String _selectedColor = '#2196F3'; // Default blue color

  // Predefined color options
  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Red', 'color': '#FF5722'},
    {'name': 'Pink', 'color': '#E91E63'},
    {'name': 'Purple', 'color': '#9C27B0'},
    {'name': 'Deep Purple', 'color': '#673AB7'},
    {'name': 'Indigo', 'color': '#3F51B5'},
    {'name': 'Blue', 'color': '#2196F3'},
    {'name': 'Light Blue', 'color': '#03A9F4'},
    {'name': 'Cyan', 'color': '#00BCD4'},
    {'name': 'Teal', 'color': '#009688'},
    {'name': 'Green', 'color': '#4CAF50'},
    {'name': 'Light Green', 'color': '#8BC34A'},
    {'name': 'Lime', 'color': '#CDDC39'},
    {'name': 'Yellow', 'color': '#FFEB3B'},
    {'name': 'Amber', 'color': '#FFC107'},
    {'name': 'Orange', 'color': '#FF9800'},
    {'name': 'Deep Orange', 'color': '#FF5722'},
    {'name': 'Brown', 'color': '#795548'},
    {'name': 'Grey', 'color': '#9E9E9E'},
    {'name': 'Blue Grey', 'color': '#607D8B'},
    {'name': 'Black', 'color': '#000000'},
  ];

  @override
  void initState() {
    super.initState();
    _tagNameController = TextEditingController();
  }

  @override
  void dispose() {
    _tagNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAddTagSection(),
                      const SizedBox(height: 24),
                      _buildTagsList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          FlutterRemix.price_tag_3_line,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          'Manage Outfit Tags',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(FlutterRemix.close_line),
        ),
      ],
    );
  }

  Widget _buildAddTagSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Tag',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tagNameController,
              decoration: InputDecoration(
                hintText: 'Enter tag name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(FlutterRemix.price_tag_3_line),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Color',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colorOptions.map((colorOption) {
                final isSelected = _selectedColor == colorOption['color'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = colorOption['color'];
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(
                          colorOption['color'].replaceFirst('#', '0xff'),
                        ),
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Color(
                                  int.parse(
                                    colorOption['color'].replaceFirst(
                                      '#',
                                      '0xff',
                                    ),
                                  ),
                                ).withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(
                            FlutterRemix.check_line,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addTag,
                icon: const Icon(FlutterRemix.add_line),
                label: const Text('Add Tag'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Existing Tags',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (widget.outfitTags.isEmpty)
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
                  'Create your first tag above',
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
            children: widget.outfitTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse(tag.color.replaceFirst('#', '0xff')),
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tag.name,
                      style: TextStyle(
                        color: Color(
                          int.parse(tag.color.replaceFirst('#', '0xff')),
                        ),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _deleteTag(tag.id),
                      child: Icon(
                        FlutterRemix.close_line,
                        size: 14,
                        color: Color(
                          int.parse(tag.color.replaceFirst('#', '0xff')),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }

  void _addTag() {
    final tagName = _tagNameController.text.trim();
    if (tagName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a tag name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if tag name already exists
    if (widget.outfitTags.any(
      (tag) => tag.name.toLowerCase() == tagName.toLowerCase(),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tag name already exists'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final newTag = OutfitTag(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: tagName,
      color: _selectedColor,
      createdAt: DateTime.now(),
    );

    widget.onTagAdded(newTag);
    _tagNameController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tag "$tagName" added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteTag(String tagId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tag'),
        content: const Text(
          'Are you sure you want to delete this tag? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onTagDeleted(tagId);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tag deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
