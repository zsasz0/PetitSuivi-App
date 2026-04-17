import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/parent/photos/themes/photos_theme.dart';

class PhotosEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const PhotosEmptyState({
    super.key,
    this.message = 'Aucun enfant disponible.',
    this.icon = Icons.child_care_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: ThemeColors.glassBackgroundSubtle,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ThemeColors.glassBorderSubtle),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: PhotosTheme.mutedText),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                color: PhotosTheme.mutedText,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
