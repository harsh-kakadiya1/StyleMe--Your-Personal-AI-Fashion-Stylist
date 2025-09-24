import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/theme_provider.dart';
import '../providers/wardrobe_provider.dart';
import 'about_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, WardrobeProvider>(
      builder: (context, themeProvider, wardrobeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.1),
                Theme.of(context).scaffoldBackgroundColor,
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Consumer<WardrobeProvider>(
                    builder: (context, wardrobeProvider, child) {
                      final userProfile = wardrobeProvider.userProfile;

                      return Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                backgroundImage:
                                    userProfile?.profilePhotoPath != null
                                    ? FileImage(
                                        File(userProfile!.profilePhotoPath!),
                                      )
                                    : null,
                                child: userProfile?.profilePhotoPath == null
                                    ? Icon(
                                        FlutterRemix.user_fill,
                                        size: 60,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SettingsScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      FlutterRemix.edit_line,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            userProfile?.name ?? 'StyleMe User',
                            style: GoogleFonts.prata(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            userProfile?.birthday != null
                                ? 'Born ${_formatDate(userProfile!.birthday!)}'
                                : 'Fashion Enthusiast',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onBackground.withValues(alpha: 0.7),
                            ),
                          ),
                          if (userProfile?.favoriteColors.isNotEmpty ==
                              true) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: userProfile!.favoriteColors.take(5).map(
                                (color) {
                                  return Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Color(
                                        int.parse(
                                          color.replaceFirst('#', '0xff'),
                                        ),
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
                                },
                              ).toList(),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),

                // Settings Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Settings',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),

                      // Theme Toggle
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: themeProvider.isDarkMode
                                    ? const Color(
                                        0xFF3498DB,
                                      ).withValues(alpha: 0.2)
                                    : Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder:
                                    (
                                      Widget child,
                                      Animation<double> animation,
                                    ) {
                                      return RotationTransition(
                                        turns: animation,
                                        child: child,
                                      );
                                    },
                                child: Icon(
                                  themeProvider.isDarkMode
                                      ? FlutterRemix.moon_fill
                                      : FlutterRemix.sun_fill,
                                  key: ValueKey(themeProvider.isDarkMode),
                                  color: themeProvider.isDarkMode
                                      ? const Color(0xFF3498DB)
                                      : Theme.of(context).colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                            ),
                            title: Text(
                              'Dark Mode',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              themeProvider.isDarkMode
                                  ? 'Switch to light theme'
                                  : 'Switch to dark theme',
                              style: GoogleFonts.outfit(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            trailing: Switch.adaptive(
                              value: themeProvider.isDarkMode,
                              onChanged: (value) {
                                themeProvider.toggleTheme();
                              },
                              activeColor: themeProvider.isDarkMode
                                  ? const Color(0xFF3498DB)
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Additional Settings
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'More Options',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),

                      _buildSettingsItem(
                        context,
                        FlutterRemix.settings_line,
                        'Settings',
                        'Manage your profile and preferences',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),

                      _buildSettingsItem(
                        context,
                        FlutterRemix.notification_3_line,
                        'Notifications',
                        'Manage your notifications',
                        () {},
                      ),

                      _buildSettingsItem(
                        context,
                        FlutterRemix.shield_user_line,
                        'Privacy',
                        'Privacy and security settings',
                        () {},
                      ),

                      _buildSettingsItem(
                        context,
                        FlutterRemix.question_line,
                        'Help & Support',
                        'Get help and support',
                        () {},
                      ),

                      _buildSettingsItem(
                        context,
                        FlutterRemix.information_line,
                        'About',
                        'App version and information',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.secondary,
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.outfit(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          trailing: Icon(
            FlutterRemix.arrow_right_s_line,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          onTap: onTap,
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
}
