import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'dart:io';
import '../models/user_profile.dart';

class ProfileEditDialog extends StatefulWidget {
  final UserProfile? userProfile;
  final Function(UserProfile) onProfileUpdated;

  const ProfileEditDialog({
    super.key,
    this.userProfile,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late TextEditingController _nameController;
  DateTime? _selectedBirthday;
  String? _profilePhotoPath;
  List<String> _favoriteColors = [];
  final ImagePicker _imagePicker = ImagePicker();

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
    _nameController = TextEditingController(
      text: widget.userProfile?.name ?? '',
    );
    _selectedBirthday = widget.userProfile?.birthday;
    _profilePhotoPath = widget.userProfile?.profilePhotoPath;
    _favoriteColors = List.from(widget.userProfile?.favoriteColors ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                      _buildProfilePhotoSection(),
                      const SizedBox(height: 20),
                      _buildNameSection(),
                      const SizedBox(height: 20),
                      _buildBirthdaySection(),
                      const SizedBox(height: 20),
                      _buildFavoriteColorsSection(),
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
          FlutterRemix.user_3_line,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          widget.userProfile != null ? 'Edit Profile' : 'Create Profile',
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

  Widget _buildProfilePhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Photo',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                backgroundImage: _profilePhotoPath != null
                    ? FileImage(File(_profilePhotoPath!))
                    : null,
                child: _profilePhotoPath == null
                    ? Icon(
                        FlutterRemix.user_3_line,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      FlutterRemix.camera_line,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(FlutterRemix.camera_line),
            label: const Text('Change Photo'),
          ),
        ),
        if (_profilePhotoPath != null)
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _profilePhotoPath = null;
                });
              },
              icon: const Icon(FlutterRemix.delete_bin_line),
              label: const Text('Remove Photo'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Name',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(FlutterRemix.user_3_line),
          ),
        ),
      ],
    );
  }

  Widget _buildBirthdaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birthday',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectBirthday,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  FlutterRemix.calendar_line,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedBirthday != null
                        ? _formatDate(_selectedBirthday!)
                        : 'Select your birthday',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: _selectedBirthday != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_selectedBirthday != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedBirthday = null;
                      });
                    },
                    icon: const Icon(FlutterRemix.close_line),
                    iconSize: 16,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteColorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Favorite Colors',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Select your favorite colors (max 5)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _colorOptions.map((colorOption) {
            final isSelected = _favoriteColors.contains(colorOption['color']);
            final canSelect = _favoriteColors.length < 5 || isSelected;

            return GestureDetector(
              onTap: canSelect
                  ? () => _toggleColor(colorOption['color'])
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Color(
                          int.parse(
                            colorOption['color'].replaceFirst('#', '0xff'),
                          ),
                        )
                      : Color(
                          int.parse(
                            colorOption['color'].replaceFirst('#', '0xff'),
                          ),
                        ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color(
                      int.parse(colorOption['color'].replaceFirst('#', '0xff')),
                    ),
                    width: isSelected ? 2 : 1,
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
                          int.parse(
                            colorOption['color'].replaceFirst('#', '0xff'),
                          ),
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      colorOption['name'],
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Color(
                                int.parse(
                                  colorOption['color'].replaceFirst(
                                    '#',
                                    '0xff',
                                  ),
                                ),
                              ),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        FlutterRemix.check_line,
                        size: 12,
                        color: Colors.white,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (_favoriteColors.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Selected: ${_favoriteColors.length}/5',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    final hasName = _nameController.text.trim().isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: hasName ? _saveProfile : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(widget.userProfile != null ? 'Update' : 'Create'),
          ),
        ),
      ],
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

  void _toggleColor(String color) {
    setState(() {
      if (_favoriteColors.contains(color)) {
        _favoriteColors.remove(color);
      } else {
        _favoriteColors.add(color);
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _profilePhotoPath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedBirthday ??
          DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  void _saveProfile() {
    final profile = UserProfile(
      id:
          widget.userProfile?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      birthday: _selectedBirthday,
      profilePhotoPath: _profilePhotoPath,
      favoriteColors: _favoriteColors,
      createdAt: widget.userProfile?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onProfileUpdated(profile);
    Navigator.of(context).pop();
  }
}
