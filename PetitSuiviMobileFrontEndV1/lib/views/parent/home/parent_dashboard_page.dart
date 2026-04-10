import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newv/l10n/app_localizations.dart';

// Import child pages
import '../child_tracking/child_selection_page.dart';
import '../photos/parent_photos_page.dart';
import '../profile/parent_profile_page.dart';
import '../payments/payments_page.dart';
import '../support/support_page.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';

// File: parent_dashboard_page.dart
// Purpose: A standalone navigation hub that provides sub-tabs for Parents.
// Usage: Alternate navigation wrapper (sometimes used instead of or within CombinedHomeScreen).
// API Usage: No.
// Dependencies: ChildSelectionPage, ParentProfilePage, PaymentsPage, ParentPhotosPage, SupportPage.

/// A secondary dashboard layout for Parents with its own floating navigation bar.
class ParentDashboardPage extends StatefulWidget {
  const ParentDashboardPage({super.key});

  @override
  State<ParentDashboardPage> createState() => _ParentDashboardPageState();
}

class _ParentDashboardPageState extends State<ParentDashboardPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _navAnimController;

  // Modern Theme Colors
  static Color get _baseDark => ThemeManager.instance.isLightMode
      ? const Color(0xFFF0F2F5)
      : const Color(0xFF141B2D);
  static Color get _surfaceDark => ThemeManager.instance.isLightMode
      ? const Color(0xFFFFFFFF)
      : const Color(0xFF1A2235);
  static Color get _tealAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF009688)
      : const Color(0xFF4CCEAC);
  static Color get _indigoAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF3F51B5)
      : const Color(0xFF6870FA);
  static Color get _mutedText => ThemeManager.instance.isLightMode
      ? const Color(0xFF6C757D)
      : const Color(0xFFA1A4AB);

  @override
  void initState() {
    super.initState();
    _navAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _navAnimController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      _navAnimController.reset();
      _navAnimController.forward();
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final l10n = AppLocalizations.of(context)!;

    const List<Widget> pages = [
      ChildSelectionPage(),
      ParentProfilePage(),
      PaymentsPage(),
      ParentPhotosPage(),
      SupportPage(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: _baseDark,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _baseDark,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.02),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_selectedIndex),
            child: pages[_selectedIndex],
          ),
        ),
        extendBody: true,
        bottomNavigationBar: _buildFloatingNavBar(l10n),
      ),
    );
  }

  Widget _buildFloatingNavBar(AppLocalizations l10n) {
    final List<_NavItem> items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: l10n.home,
        color: _tealAccent,
      ),
      _NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: l10n.profile,
        color: _tealAccent,
      ),
      _NavItem(
        icon: Icons.account_balance_wallet_outlined,
        activeIcon: Icons.account_balance_wallet_rounded,
        label: l10n.payments,
        color: _indigoAccent,
      ),
      _NavItem(
        icon: Icons.photo_library_outlined,
        activeIcon: Icons.photo_library_rounded,
        label: 'Photos',
        color: _indigoAccent,
      ),
      _NavItem(
        icon: Icons.headset_mic_outlined,
        activeIcon: Icons.headset_mic_rounded,
        label: l10n.support,
        color: _tealAccent,
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: _surfaceDark,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: ThemeColors.glassBorderSubtle),
            boxShadow: [
              BoxShadow(
                color: ThemeColors.shadow,
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: _tealAccent.withValues(alpha: 0.03),
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
                    final isSelected = index == _selectedIndex;

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

  Widget _buildNavItem(_NavItem item, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
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
                    : _mutedText.withValues(alpha: 0.7),
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

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}
