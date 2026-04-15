import 'package:newv/theme_manager.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:flutter/services.dart';
import 'package:newv/views/home/components/drawer_nav_observer.dart';
import 'package:newv/views/home/components/combined_bottom_nav_bar.dart';
import 'package:newv/views/home/components/drawer_user_controller.dart';
import 'package:newv/views/home/components/home_drawer.dart';
import 'package:newv/help_screen.dart';
import 'package:newv/views/parent/child_tracking/child_selection_page.dart';
import 'package:newv/views/parent/payments/payments_page.dart';
import 'package:newv/views/teacher/home/teacher_dashboard_page.dart';
import 'package:newv/views/teacher/classes/manage_classes_page.dart';
import 'package:newv/views/teacher/activities/activities_calendar_page.dart';
import 'package:newv/views/teacher/notifications/teacher_notifications_page.dart';
import 'package:newv/views/teacher/photos/teacher_photo_sharing_page.dart';
import 'package:newv/views/teacher/profile/teacher_profile_page.dart';
import 'package:newv/views/parent/notifications/parent_notifications_page.dart';
import 'package:newv/views/parent/photos/parent_photos_page.dart';
import 'package:newv/views/parent/profile/parent_profile_page.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/services/notification_service.dart';
import 'package:newv/services/pickup_notification_service.dart';
import 'dart:async';

// File: combined_home_screen.dart
// Purpose: Multi-role dashboard serving both Parents and Teachers.
// Usage: Primary post-login destination.
// API Usage:
//   - GET /api/notifications/unread-count (Polling via NotificationService)
// Dependencies: AuthSession, NotificationService, DrawerUserController, HomeDrawer, CombinedBottomNavBar.

/// The main application container after a successful login.
///
/// It coordinates the drawer, bottom navigation, and top-level pages
/// for both Parent and Teacher roles using an [IndexedStack] and nested [Navigator].
class CombinedHomeScreen extends StatefulWidget {
  /// The user's role: 1 for Teacher, 2 for Parent.
  final int userRole;

  /// Creates a [CombinedHomeScreen].
  const CombinedHomeScreen({super.key, this.userRole = 2});

  @override
  State<CombinedHomeScreen> createState() => _CombinedHomeScreenState();
}

class _CombinedHomeScreenState extends State<CombinedHomeScreen> {
  /*
  index in drawer used for drawer controller
  This index tracks the currently selected screen from the side drawer,
  determining which content widget is displayed in the main view.
  */
  DrawerIndex? drawerIndex; // the index of the drawer
  int _bottomSelectedIndex = 0; // the index of the bottom navigation bar
  final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>(); // the key of the navigator
  late final ValueNotifier<int> _indexNotifier; // the notifier of the index
  late final ValueNotifier<bool>
  _drawerButtonVisibility; // the notifier of the drawer button visibility
  late final DrawerNavObserver _navObserver; // the observer of the navigator

  // notification service to get the unread count of notifications
  final NotificationService _notificationService = NotificationService();
  final PickupNotificationService _pickupService = PickupNotificationService();
  int _unreadCount = 0; // the unread count of notifications
  Timer? _badgeTimer; // the timer to fetch the unread count of notifications

  // init state
  @override
  void initState() {
    _indexNotifier = ValueNotifier(_bottomSelectedIndex);
    _drawerButtonVisibility = ValueNotifier(true);
    _navObserver = DrawerNavObserver(_drawerButtonVisibility);
    if (widget.userRole == 1) {
      drawerIndex = DrawerIndex.teacherDashboard;
    } else {
      drawerIndex = DrawerIndex.children;
    }
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreShellState();
      _fetchUnreadCount();
      _badgeTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        _fetchUnreadCount();
      });
    });
  }

  // dispose
  @override
  void dispose() {
    _indexNotifier.dispose();
    _drawerButtonVisibility.dispose();
    _badgeTimer?.cancel();
    super.dispose();
  }

  // fetch unread count of notifications
  Future<void> _fetchUnreadCount() async {
    // get the token from the auth session
    final token = context.read<AuthSession>().token;
    // if the token is null or empty, skip the fetch
    if (token == null || token.isEmpty) {
      debugPrint('[Badge] No token, skipping unread count fetch');
      return;
    }
    // get the role from the user role
    final role = widget.userRole == 1 ? 'teacher' : 'parent';
    // try to fetch the unread count
    try {
      // fetch the unread count from the notification service
      final count = await _notificationService.getUnreadCount(token, role);

      // For teachers, also count pickup notifications (separate table)
      int pickupCount = 0;
      if (widget.userRole == 1) {
        try {
          final pickups = await _pickupService.getTeacherNotifications(token);
          pickupCount = pickups.length;
        } catch (_) {
          // Pickup fetch may fail independently; don't block badge
        }
      }

      final totalCount = count + pickupCount;
      debugPrint(
        '[Badge] Fetched unread count: $totalCount (notif=$count, pickup=$pickupCount, role=$role)',
      );

      if (mounted && totalCount != _unreadCount) {
        setState(() => _unreadCount = totalCount);
      }
    } catch (e) {
      debugPrint('[Badge] Error fetching unread count: $e');
    }
  }

  // build the body of the combined home screen
  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();

    return Container(
      color: TeacherTheme.baseDark,
      child: SafeArea(
        top: false,
        bottom: false,
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, dynamic result) async {
            if (didPop) return;

            final NavigatorState? innerNavigator = _navigatorKey.currentState;
            if (innerNavigator != null && innerNavigator.canPop()) {
              innerNavigator.pop();
              return;
            }

            // If we can't pop the nested navigator, check the tabs
            if (_bottomSelectedIndex != 0) {
              _onBottomTabSelected(0);
            } else {
              // Already on home tab — exit the app
              SystemNavigator.pop();
            }
          },
          child: Scaffold(
            // this scaffold is the main scaffold of the app
            backgroundColor: TeacherTheme.baseDark,
            // this drawer user controller is the main controller of the app
            body: DrawerUserController(
              // used from drawer_user_controller.dart to control the drawer
              screenIndex: drawerIndex, // the index of the drawer
              drawerWidth: MediaQuery.of(context).size.width * 0.75,
              onDrawerCall: (DrawerIndex drawerIndexdata) {
                changeIndex(drawerIndexdata);
              }, //  onDrawerCall used to change the index of the drawer
              screenView: _buildBody(), // the body of the app
              userRole: widget.userRole,
              bottomNavigationBar: CombinedBottomNavBar(
                userRole: widget.userRole,
                unreadCount: _unreadCount,
                currentIndex: _bottomSelectedIndex,
                onTap: _onBottomTabSelected,
              ),
              drawerButtonVisibility: _drawerButtonVisibility,
            ),
          ),
        ),
      ),
    );
  }

  DrawerIndex _drawerIndexForTab(int index) {
    if (widget.userRole == 1) {
      switch (index) {
        case 1:
          return DrawerIndex.annualActivities;
        case 2:
          return DrawerIndex.teacherPhotos;
        case 3:
          return DrawerIndex.notifications;
        case 4:
          return DrawerIndex.teacherProfile;
        case 0:
        default:
          return DrawerIndex.teacherDashboard;
      }
    }

    switch (index) {
      case 1:
        return DrawerIndex.notifications;
      case 2:
        return DrawerIndex.payments;
      case 3:
        return DrawerIndex.parentPhotos;
      case 4:
        return DrawerIndex.parentProfile;
      case 0:
      default:
        return DrawerIndex.children;
    }
  }

  Future<void> _restoreShellState() async {
    final savedIndex = await context.read<AuthSession>().getSavedHomeTab(
      userRole: widget.userRole,
    );
    if (!mounted) return;

    final clampedIndex = (savedIndex ?? 0).clamp(0, 4);
    setState(() {
      _bottomSelectedIndex = clampedIndex;
      _indexNotifier.value = clampedIndex;
      _drawerButtonVisibility.value = (clampedIndex == 0);
      drawerIndex = _drawerIndexForTab(clampedIndex);
    });
  }

  Future<void> _persistShellState() async {
    await context.read<AuthSession>().saveHomeTab(
      userRole: widget.userRole,
      tabIndex: _bottomSelectedIndex,
    );
  }

  /*
  The Main Content Area & Nested Routing
  ( its like a board u can draw on it )
  This method defines the main visual content that sits behind the drawer and above the bottom nav bar.
  - It returns an IndexedStack, which pre-loads all pages (Teacher/Parent screens) but only displays one.
    This makes switching tabs instant and preserves the state (like scroll position) of each page.
  - It wraps the IndexedStack in a local Navigator. This is a "Nested Routing" pattern. 
    It allows you to navigate deeper into a specific tab (like viewing a child's details) 
    WITHOUT losing the bottom navigation bar or the drawer on the screen.
  */
  Widget _buildBody() {
    return Navigator(
      // flutter widget that manages a stack of routes (screens)
      key:
          _navigatorKey, // this navigator is used to navigate between the pages
      observers: [
        _navObserver,
      ], // this observer is used to control the visibility of the drawer button
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          // this is used to create a new route
          builder: (context) {
            return ValueListenableBuilder<int>(
              valueListenable:
                  _indexNotifier, // this is used to listen to the index of the bottom navigation bar
              builder: (context, index, child) {
                if (widget.userRole == 1) {
                  // Teacher Pages
                  return IndexedStack(
                    index: index,
                    children: [
                      TeacherDashboardPage(
                        onTabSwitch: (tabIndex) => _switchTab(
                          tabIndex,
                        ), // this is used to switch between the tabs of the teacher dashboard
                      ),
                      const ActivitiesCalendarPage(),
                      const TeacherPhotoSharingPage(),
                      const TeacherNotificationsPage(),
                      const TeacherProfilePage(),
                    ],
                  );
                } else {
                  // Parent Pages
                  return IndexedStack(
                    index: index,
                    children: const [
                      ChildSelectionPage(),
                      ParentNotificationsPage(),
                      PaymentsPage(),
                      ParentPhotosPage(),
                      ParentProfilePage(),
                    ],
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  void _onBottomTabSelected(int index) {
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    setState(() {
      _bottomSelectedIndex = index;
      _indexNotifier.value = index;

      _drawerButtonVisibility.value = (index == 0);

      if (widget.userRole == 1) {
        switch (index) {
          case 0:
            drawerIndex = DrawerIndex.teacherDashboard;
            break;
          case 1:
            drawerIndex = DrawerIndex.annualActivities;
            break;
          case 2:
            drawerIndex = DrawerIndex.teacherPhotos;
            break;
          case 3:
            drawerIndex = DrawerIndex.notifications;
            break;
          case 4:
            drawerIndex = DrawerIndex.teacherProfile;
            break;
        }
      } else {
        switch (index) {
          case 0:
            drawerIndex = DrawerIndex.children;
            break;
          case 1:
            drawerIndex = DrawerIndex.notifications;
            break;
          case 2:
            drawerIndex = DrawerIndex.payments;
            break;
          case 3:
            drawerIndex = DrawerIndex.parentPhotos;
            break;
          case 4:
            drawerIndex = DrawerIndex.parentProfile;
            break;
        }
      }
    });
    _persistShellState();
    _fetchUnreadCount();
    if (widget.userRole != 1) {
      context.read<AuthSession>().bumpSyncVersion();
    }
  }

  /// Switch to a bottom tab from the dashboard grid.
  /// Pops any pushed routes first, then updates index + drawer.
  void _switchTab(int tabIndex) {
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    setState(() {
      _bottomSelectedIndex = tabIndex;
      _indexNotifier.value = tabIndex;
      // Hide hamburger on non-dashboard tabs
      _drawerButtonVisibility.value = (tabIndex == 0);
      if (widget.userRole == 1) {
        switch (tabIndex) {
          case 0:
            drawerIndex = DrawerIndex.teacherDashboard;
            break;
          case 1:
            drawerIndex = DrawerIndex.annualActivities;
            break;
          case 2:
            drawerIndex = DrawerIndex.teacherPhotos;
            break;
          case 3:
            drawerIndex = DrawerIndex.notifications;
            break;
          case 4:
            drawerIndex = DrawerIndex.teacherProfile;
            break;
        }
      }
    });
    _persistShellState();
  }

  // this is used to change the index of the drawer
  void changeIndex(DrawerIndex drawerIndexdata) {
    if (drawerIndex != drawerIndexdata) {
      drawerIndex = drawerIndexdata;
      setState(() {
        if (widget.userRole == 1) {
          // Teacher Logic
          switch (drawerIndex) {
            case DrawerIndex.teacherDashboard:
              _bottomSelectedIndex = 0;
              break;
            case DrawerIndex.annualActivities:
              _bottomSelectedIndex = 1;
              break;
            case DrawerIndex.teacherPhotos:
              _bottomSelectedIndex = 2;
              break;
            case DrawerIndex.notifications:
              _bottomSelectedIndex = 3;
              break;
            case DrawerIndex.teacherProfile:
              _bottomSelectedIndex = 4;
              break;
            default:
              break; // Help etc handled separately if needed
          }
        } else {
          // Parent Logic
          switch (drawerIndex) {
            case DrawerIndex.children:
              _bottomSelectedIndex = 0;
              break;
            case DrawerIndex.notifications:
              _bottomSelectedIndex = 1;
              break;
            case DrawerIndex.payments:
              _bottomSelectedIndex = 2;
              break;
            case DrawerIndex.parentPhotos:
              _bottomSelectedIndex = 3;
              break;
            case DrawerIndex.parentProfile:
              _bottomSelectedIndex = 4;
              break;
            default:
              break;
          }
        }
        _indexNotifier.value = _bottomSelectedIndex;
      });
      _persistShellState();
      // Handle special screens that are NOT in bottom tabs (like Help, Manage Classes)
      if (drawerIndex == DrawerIndex.help) {
        _navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => HelpScreen()),
        );
      } else if (drawerIndex == DrawerIndex.manageClasses) {
        _navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => const ManageClassesPage()),
        );
      }
    }
  }
}
