import 'package:flutter/material.dart';
import 'package:newv/views/teacher/home/components/home/dashboard_card.dart';
import 'package:newv/views/teacher/home/controllers/home_controller.dart';

// File: dashboard_grid.dart
// Purpose: Renders the 2-column grid of DashboardCard widgets using menu items
//          provided by HomeController.

class DashboardGrid extends StatelessWidget {
  final AnimationController animController;
  final void Function(int)? onTabSwitch;

  const DashboardGrid({
    super.key,
    required this.animController,
    required this.onTabSwitch,
  });

  @override
  Widget build(BuildContext context) {
    final menuItems = HomeController.buildMenuItems();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return DashboardCard(
            item: item,
            index: index,
            totalItems: menuItems.length,
            animController: animController,
            onTap: () => HomeController.handleCardTap(
              context: context,
              item: item,
              onTabSwitch: onTabSwitch,
            ),
          );
        },
      ),
    );
  }
}
