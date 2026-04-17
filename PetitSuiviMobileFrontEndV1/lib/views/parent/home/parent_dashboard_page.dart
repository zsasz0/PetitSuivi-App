import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newv/views/themes/theme_manager.dart';

// Import child pages
import 'package:newv/views/parent/child_tracking/child_tracking_page.dart';
import 'package:newv/views/parent/photos/parent_photos_page.dart';
import 'package:newv/views/parent/profile/parent_profile_page.dart';
import 'package:newv/views/parent/payments/payments_page.dart';
import 'package:newv/views/shared/support/support_page.dart';

// Modular Architecture Imports
import 'package:newv/views/parent/home/controllers/home_controller.dart';
import 'package:newv/views/parent/home/themes/home_theme.dart';
import 'package:newv/views/parent/home/components/home/floating_nav_bar.dart';

/// A secondary dashboard layout for Parents with its own floating navigation bar.
/// Standardized into the PetitSuivi Modular Architecture.
class ParentDashboardPage extends StatefulWidget {
  const ParentDashboardPage({super.key});

  @override
  State<ParentDashboardPage> createState() => _ParentDashboardPageState();
}

class _ParentDashboardPageState extends State<ParentDashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _navAnimController;
  late HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _navAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _navAnimController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _controller.setSelectedIndex(index, onPageChanged: () {
      _navAnimController.reset();
      _navAnimController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch ThemeManager to rebuild on theme changes
    context.watch<ThemeManager>();

    return ChangeNotifierProvider<HomeController>.value(
      value: _controller,
      child: Consumer<HomeController>(
        builder: (context, controller, child) {
          const List<Widget> pages = [
            ChildTrackingPage(),
            ParentProfilePage(),
            PaymentsPage(),
            ParentPhotosPage(),
            SupportPage(),
          ];

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              systemNavigationBarColor: HomeTheme.baseDark,
              systemNavigationBarIconBrightness: Brightness.light,
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
            child: Scaffold(
              backgroundColor: HomeTheme.baseDark,
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
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
                  key: ValueKey<int>(controller.selectedIndex),
                  child: pages[controller.selectedIndex],
                ),
              ),
              extendBody: true,
              bottomNavigationBar: FloatingNavBar(
                selectedIndex: controller.selectedIndex,
                onItemTapped: _onItemTapped,
              ),
            ),
          );
        },
      ),
    );
  }
}
