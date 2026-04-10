import 'package:provider/provider.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/views/home/components/home_drawer.dart';
import 'package:flutter/material.dart';

// File: drawer_user_controller.dart
// Purpose: Structural wrapper for the Home screen, managing the Scaffold and Drawer.
// Usage: Used exclusively by CombinedHomeScreen.
// API Usage: No.
// Dependencies: HomeDrawer.

/// A stateful controller that manages the drawer state and main screen layout.
class DrawerUserController extends StatefulWidget {
  const DrawerUserController({
    Key? key,
    this.drawerWidth = 250,
    this.onDrawerCall,
    this.screenView,
    this.animatedIconData = AnimatedIcons.arrow_menu,
    this.menuView,
    this.drawerIsOpen,
    this.screenIndex,
    this.userRole,
    this.bottomNavigationBar,
    this.drawerButtonVisibility,
  }) : super(key: key);

  final double drawerWidth;
  final Function(DrawerIndex)? onDrawerCall;
  final Widget? screenView;
  final AnimatedIconData? animatedIconData;
  final Widget? menuView;
  final Function(bool)? drawerIsOpen;
  final DrawerIndex? screenIndex;
  final int? userRole;
  final Widget? bottomNavigationBar;
  final ValueNotifier<bool>? drawerButtonVisibility;

  @override
  _DrawerUserControllerState createState() => _DrawerUserControllerState();
}

class _DrawerUserControllerState extends State<DrawerUserController> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final bool isLight = ThemeManager.instance.isLightMode;
    final Color baseDark = isLight
        ? const Color(0xFFF0F2F5)
        : const Color(0xFF141B2D);
    final Color lightText = isLight
        ? const Color(0xFF212529)
        : const Color(0xFFF2F0F0);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: baseDark,
      drawer: SizedBox(
        width: widget.drawerWidth,
        child: Drawer(
          child: HomeDrawer(
            screenIndex: widget.screenIndex ?? DrawerIndex.Children,
            userRole: widget.userRole,
            iconAnimationController: null,
            callBackIndex: (DrawerIndex indexType) {
              Navigator.pop(context); // close drawer
              try {
                widget.onDrawerCall!(indexType);
              } catch (e) {}
            },
          ),
        ),
      ),
      bottomNavigationBar: widget.bottomNavigationBar,
      body: Stack(
        children: <Widget>[
          widget.screenView ?? const SizedBox(),
          // Hamburger menu button (3 dashes)
          ValueListenableBuilder<bool>(
            valueListenable:
                widget.drawerButtonVisibility ?? ValueNotifier(true),
            builder: (context, visible, child) {
              if (!visible) return const SizedBox();
              return Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                child: SizedBox(
                  width: AppBar().preferredSize.height - 8,
                  height: AppBar().preferredSize.height - 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        AppBar().preferredSize.height,
                      ),
                      onTap: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                      child: Center(child: Icon(Icons.menu, color: lightText)),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
