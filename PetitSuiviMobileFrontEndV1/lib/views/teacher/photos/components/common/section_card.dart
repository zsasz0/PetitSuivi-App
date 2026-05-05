import 'package:flutter/material.dart';
import 'package:newv/views/teacher/photos/themes/photos_theme.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: PhotosTheme.sectionDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: PhotosTheme.titleStyle,
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
