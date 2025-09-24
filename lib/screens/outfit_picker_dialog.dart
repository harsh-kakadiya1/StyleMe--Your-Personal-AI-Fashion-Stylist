import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:provider/provider.dart';
import '../providers/wardrobe_provider.dart';
import '../models/outfit_schedule.dart';
import '../models/clothing_item.dart';

class OutfitPickerDialog extends StatefulWidget {
  final DateTime selectedDate;
  final OutfitSchedule? existingSchedule;

  const OutfitPickerDialog({
    super.key,
    required this.selectedDate,
    this.existingSchedule,
  });

  @override
  State<OutfitPickerDialog> createState() => _OutfitPickerDialogState();
}

class _OutfitPickerDialogState extends State<OutfitPickerDialog> {
  String? _selectedTopId;
  String? _selectedBottomId;

  @override
  void initState() {
    super.initState();
    if (widget.existingSchedule != null) {
      _selectedTopId = widget.existingSchedule!.topId;
      _selectedBottomId = widget.existingSchedule!.bottomId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.95,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Flexible(child: _buildOutfitSelector()),
              const SizedBox(height: 16),
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
          FlutterRemix.shirt_line,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Select Outfit for ${_formatDate(widget.selectedDate)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(FlutterRemix.close_line),
        ),
      ],
    );
  }

  Widget _buildOutfitSelector() {
    return Consumer<WardrobeProvider>(
      builder: (context, wardrobeProvider, child) {
        final tops = wardrobeProvider.topWearItems;
        final bottoms = wardrobeProvider.bottomWearItems;

        if (tops.isEmpty || bottoms.isEmpty) {
          return _buildEmptyState();
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildClothingSection(
                title: 'Top',
                items: tops,
                selectedId: _selectedTopId,
                onItemSelected: (id) => setState(() => _selectedTopId = id),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildClothingSection(
                title: 'Bottom',
                items: bottoms,
                selectedId: _selectedBottomId,
                onItemSelected: (id) => setState(() => _selectedBottomId = id),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClothingSection({
    required String title,
    required List<ClothingItem> items,
    required String? selectedId,
    required Function(String) onItemSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 300, // Fixed height to prevent overflow
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = selectedId == item.id;

              return GestureDetector(
                onTap: () => onItemSelected(item.id),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).dividerColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(7),
                          ),
                          child: Image.file(
                            File(item.imagePath),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Theme.of(context).colorScheme.surface,
                                child: Icon(
                                  item.category == 'top'
                                      ? FlutterRemix.shirt_line
                                      : FlutterRemix.shopping_bag_line,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.1)
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(7),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              item.type.toUpperCase(),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 9,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FlutterRemix.shirt_line,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Clothes Available',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add some clothes to your wardrobe first',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final canSave = _selectedTopId != null && _selectedBottomId != null;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: canSave ? _saveOutfit : null,
            child: Text(widget.existingSchedule != null ? 'Update' : 'Save'),
          ),
        ),
      ],
    );
  }

  void _saveOutfit() {
    if (_selectedTopId != null && _selectedBottomId != null) {
      final schedule = OutfitSchedule(
        id:
            widget.existingSchedule?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        date: widget.selectedDate,
        topId: _selectedTopId,
        bottomId: _selectedBottomId,
        note: widget.existingSchedule?.note,
        createdAt: widget.existingSchedule?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      Navigator.of(context).pop(schedule);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
