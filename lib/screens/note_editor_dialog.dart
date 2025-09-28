import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import '../models/outfit_schedule.dart';

class NoteEditorDialog extends StatefulWidget {
  final DateTime selectedDate;
  final OutfitSchedule? existingSchedule;

  const NoteEditorDialog({
    super.key,
    required this.selectedDate,
    this.existingSchedule,
  });

  @override
  State<NoteEditorDialog> createState() => _NoteEditorDialogState();
}

class _NoteEditorDialogState extends State<NoteEditorDialog> {
  late TextEditingController _noteController;
  final int _maxLength = 200;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(
      text: widget.existingSchedule?.note ?? '',
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Flexible(child: _buildNoteEditor()),
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
          FlutterRemix.file_text_line,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Add Note for ${_formatDate(widget.selectedDate)}',
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

  Widget _buildNoteEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Note', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 200, // Fixed height to prevent overflow
          child: TextField(
            controller: _noteController,
            maxLines: null,
            expands: true,
            maxLength: _maxLength,
            decoration: InputDecoration(
              hintText: 'Add a note about your outfit for this day...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              counterText: '${_noteController.text.length}/$_maxLength',
            ),
            onChanged: (value) {
              setState(() {}); // Update character count
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tip: You can add notes about the occasion, weather, or any special details about your outfit.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final hasText = _noteController.text.trim().isNotEmpty;

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
            onPressed: hasText ? _saveNote : null,
            child: Text(widget.existingSchedule != null ? 'Update' : 'Save'),
          ),
        ),
      ],
    );
  }

  void _saveNote() {
    final note = _noteController.text.trim();

    if (note.isNotEmpty) {
      final schedule = OutfitSchedule(
        id:
            widget.existingSchedule?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        date: widget.selectedDate,
        topId: widget.existingSchedule?.topId,
        bottomId: widget.existingSchedule?.bottomId,
        note: note,
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
