import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:newv/views/parent/profile/themes/profile_theme.dart';

class ChildSkeleton extends StatelessWidget {
  const ChildSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ProfileTheme.glassBackgroundSubtle,
      highlightColor: ProfileTheme.glassBorderWithOpacity(0.1),
      child: Column(
        children: List.generate(
          2,
          (index) => Container(
            height: 80,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
