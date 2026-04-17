import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:newv/l10n/app_localizations.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/parent/home/themes/home_theme.dart';

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}

class FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const FloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<NavItem> items = [
      NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: l10n.home,
        color: HomeTheme.tealAccent,
      ),
      NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: l10n.profile,
        color: HomeTheme.tealAccent,
      ),
      NavItem(
        icon: Icons.account_balance_wallet_outlined,
        activeIcon: Icons.account_balance_wallet_rounded,
        label: l10n.payments,
        color: HomeTheme.indigoAccent,
      ),
      NavItem(
        icon: Icons.photo_library_outlined,
        activeIcon: Icons.photo_library_rounded,
        label: 'Photos',
        color: HomeTheme.indigoAccent,
      ),
      NavItem(
        icon: Icons.headset_mic_outlined,
        activeIcon: Icons.headset_mic_rounded,
        label: l10n.support,
        color: HomeTheme.tealAccent,
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: HomeTheme.surfaceDark,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: ThemeColors.glassBorderSubtle),
            boxShadow: [
              BoxShadow(
                color: ThemeColors.shadow,
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: HomeTheme.tealAccent.withValues(alpha: 0.03),
                blurRadius: 40,
                spreadRadius: -10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final isSelected = index == selectedIndex;

                    return _buildNavItem(item, isSelected, index);
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavItem item, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutQuint,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? item.color.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                key: ValueKey<bool>(isSelected),
                color: isSelected
                    ? item.color
                    : HomeTheme.mutedText.withValues(alpha: 0.7),
                size: isSelected ? 26 : 22,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuint,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: item.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
