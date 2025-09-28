import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/wardrobe_provider.dart';
import '../models/outfit_schedule.dart';
import '../models/clothing_item.dart';
import 'outfit_picker_dialog.dart';
import 'note_editor_dialog.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<OutfitSchedule>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));

    // Load outfit schedules
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WardrobeProvider>(
        context,
        listen: false,
      ).loadOutfitSchedules();
    });
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<OutfitSchedule> _getEventsForDay(DateTime day) {
    final wardrobeProvider = Provider.of<WardrobeProvider>(
      context,
      listen: false,
    );
    return wardrobeProvider.outfitSchedules.where((event) {
      return isSameDay(event.date, day);
    }).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Outfit Calendar'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildCalendar(),
                  const SizedBox(height: 20),
                  _buildSelectedDayEvents(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar<OutfitSchedule>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: CalendarFormat.month,
          eventLoader: _getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            markersMaxCount: 1,
            markerDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            formatButtonShowsNext: false,
            titleTextStyle: Theme.of(context).textTheme.titleLarge!,
          ),
          onDaySelected: _onDaySelected,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
      ),
    );
  }

  Widget _buildSelectedDayEvents() {
    return ValueListenableBuilder<List<OutfitSchedule>>(
      valueListenable: _selectedEvents,
      builder: (context, value, _) {
        if (value.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Outfits for ${_formatDate(_selectedDay!)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...value.map((event) => _buildEventCard(event)),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              FlutterRemix.calendar_line,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Outfit Planned',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to plan an outfit for this day',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showOutfitPicker(),
              icon: const Icon(FlutterRemix.add_line),
              label: const Text('Plan Outfit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(OutfitSchedule event) {
    return Consumer<WardrobeProvider>(
      builder: (context, wardrobeProvider, child) {
        final outfitDetails = wardrobeProvider.getScheduleOutfitDetails(
          event.id,
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildClothingItemPreview(
                        outfitDetails?['topItem'] as ClothingItem?,
                        'Top',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildClothingItemPreview(
                        outfitDetails?['bottomItem'] as ClothingItem?,
                        'Bottom',
                      ),
                    ),
                  ],
                ),
                if (event.hasNote) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              FlutterRemix.file_text_line,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Note',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event.note!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showOutfitPicker(existingSchedule: event),
                        icon: const Icon(FlutterRemix.edit_line),
                        label: const Text('Edit Outfit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showNoteEditor(existingSchedule: event),
                        icon: const Icon(FlutterRemix.file_text_line),
                        label: const Text('Edit Note'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => _deleteSchedule(event),
                      icon: const Icon(FlutterRemix.delete_bin_line),
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClothingItemPreview(ClothingItem? item, String label) {
    return Column(
      children: [
        GestureDetector(
          onTap: item != null ? () => _showImageDialog(item) : null,
          child: Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: item != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(item.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: Icon(
                            item.category == 'top'
                                ? FlutterRemix.shirt_line
                                : FlutterRemix.shopping_bag_line,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: Icon(
                      FlutterRemix.add_line,
                      size: 32,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          item?.type.toUpperCase() ?? 'NOT SELECTED',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: item != null
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showImageDialog(ClothingItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              // Full screen image
              Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.95,
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(item.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                item.category == 'top'
                                    ? FlutterRemix.shirt_line
                                    : FlutterRemix.shopping_bag_line,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Image not found',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Close button
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),

              // Item details at bottom
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            item.category == 'top'
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
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
                      const SizedBox(height: 8),
                      Text(
                        '${item.category == 'top' ? 'Top' : 'Bottom'} Wear',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Added: ${_formatDate(item.addedDate)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOutfitPicker({OutfitSchedule? existingSchedule}) async {
    final result = await showDialog<OutfitSchedule>(
      context: context,
      builder: (context) => OutfitPickerDialog(
        selectedDate: _selectedDay!,
        existingSchedule: existingSchedule,
      ),
    );

    if (result != null) {
      final wardrobeProvider = Provider.of<WardrobeProvider>(
        context,
        listen: false,
      );
      await wardrobeProvider.addOrUpdateOutfitSchedule(result);
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    }
  }

  void _showNoteEditor({OutfitSchedule? existingSchedule}) async {
    final result = await showDialog<OutfitSchedule>(
      context: context,
      builder: (context) => NoteEditorDialog(
        selectedDate: _selectedDay!,
        existingSchedule: existingSchedule,
      ),
    );

    if (result != null) {
      final wardrobeProvider = Provider.of<WardrobeProvider>(
        context,
        listen: false,
      );
      await wardrobeProvider.addOrUpdateOutfitSchedule(result);
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    }
  }

  void _deleteSchedule(OutfitSchedule schedule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Outfit'),
        content: const Text(
          'Are you sure you want to delete this outfit plan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final wardrobeProvider = Provider.of<WardrobeProvider>(
        context,
        listen: false,
      );
      await wardrobeProvider.deleteOutfitSchedule(schedule.id);
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    }
  }
}
