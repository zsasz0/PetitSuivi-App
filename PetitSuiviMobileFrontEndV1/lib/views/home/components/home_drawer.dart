import 'package:newv/utils/api_constants.dart';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:newv/app_theme.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/utils/unauthorized_handler.dart';
import 'package:newv/views/auth/login/login_page.dart';
import 'package:newv/models/child.dart';
import 'package:newv/views/parent/child_tracking/child_details_page.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';

// File: home_drawer.dart
// Purpose: Dynamic sidebar navigation menu.
// Usage: Drawer component in CombinedHomeScreen via DrawerUserController.
// API Usage: Yes, GET /api/parents/{cin}/children (for parent role).
// Dependencies: AuthSession, UnauthorizedHandler, ChildDetailsPage, Child model.

/// An index enum for all possible screens accessible via the drawer.
enum DrawerIndex {
  ParentProfile,
  Children,
  Payments,
  ParentPhotos,
  TeacherDashboard,
  ManageClasses,
  AnnualActivities,
  Notifications,
  TeacherProfile,
  TeacherPhotos,
  Help,
}

/// A stateful drawer that builds its menu items based on the user's role and data.
class HomeDrawer extends StatefulWidget {
  const HomeDrawer({
    super.key,
    this.screenIndex,
    this.iconAnimationController,
    this.callBackIndex,
    this.userRole = 2,
  });

  final DrawerIndex? screenIndex;
  final AnimationController? iconAnimationController;
  final Function(DrawerIndex)? callBackIndex;
  final int? userRole;

  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  List<DrawerList>? drawerList;
  List<Child> _parentChildren = [];

  // Modern Theme Colors (dynamic)
  static Color get _baseDark => ThemeManager.instance.isLightMode
      ? const Color(0xFFF5F5F5)
      : const Color(0xFF141B2D);
  static Color get _tealAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF009688)
      : const Color(0xFF4CCEAC);
  static Color get _indigoAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF3F51B5)
      : const Color(0xFF6870FA);
  static Color get _lightText => ThemeManager.instance.isLightMode
      ? const Color(0xFF212529)
      : const Color(0xFFF2F0F0);
  static Color get _mutedText => ThemeManager.instance.isLightMode
      ? const Color(0xFF6C757D)
      : const Color(0xFFA1A4AB);

  @override
  void initState() {
    setDrawerListArray();
    if (widget.userRole != 1) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _loadParentChildren(),
      );
    }
    super.initState();
  }

  void setDrawerListArray() {
    drawerList = <DrawerList>[];

    if (widget.userRole == 1) {
      // Teacher (Keeping original color logic, but we can darken it too if needed)
      drawerList!.add(
        DrawerList(
          index: DrawerIndex.TeacherDashboard,
          labelName: 'Accueil',
          icon: const Icon(Icons.home),
        ),
      );
      drawerList!.add(
        DrawerList(
          index: DrawerIndex.TeacherProfile,
          labelName: 'Mon profil',
          icon: const Icon(Icons.person),
        ),
      );
      drawerList!.add(
        DrawerList(
          index: DrawerIndex.ManageClasses,
          labelName: 'Gérer les classes',
          icon: const Icon(Icons.class_),
        ),
      );

      drawerList!.add(
        DrawerList(
          index: DrawerIndex.AnnualActivities,
          labelName: 'Activités Annuelles',
          icon: const Icon(Icons.calendar_today),
        ),
      );
      drawerList!.add(
        DrawerList(
          index: DrawerIndex.Notifications,
          labelName: 'Notifications',
          icon: const Icon(Icons.notifications),
        ),
      );
      drawerList!.add(
        DrawerList(
          index: DrawerIndex.TeacherPhotos,
          labelName: 'Photos Parents',
          icon: const Icon(Icons.photo_camera_outlined),
        ),
      );
    } else {
      // Parent (2) or others
      drawerList!.add(
        DrawerList(
          index: DrawerIndex.ParentProfile,
          labelName: 'Mon profil',
          icon: const Icon(Icons.person_outline_rounded),
        ),
      );
      drawerList!.add(
        DrawerList(
          index: DrawerIndex.Children,
          labelName: 'Mes enfants',
          icon: const Icon(Icons.child_care_rounded),
          subList: _parentChildren,
        ),
      );
      drawerList!.add(
        DrawerList(
          index: DrawerIndex.Payments,
          labelName: 'Paiements',
          icon: const Icon(Icons.payment_rounded),
        ),
      );
      drawerList!.add(
        DrawerList(
          index: DrawerIndex.ParentPhotos,
          labelName: 'Photos',
          icon: const Icon(Icons.photo_library_outlined),
        ),
      );
      drawerList!.add(
        DrawerList(
          index: DrawerIndex.Notifications,
          labelName: 'Notifications',
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      );
    }

    // Common items
    drawerList!.addAll([
      DrawerList(
        index: DrawerIndex.Help,
        labelName: 'Aide & Contact',
        isAssetsImage: true,
        imageName: 'assets/images/supportIcon.png',
      ),
    ]);
  }

  Future<void> _loadParentChildren() async {
    final session = context.read<AuthSession>();
    final token = session.token;
    final parentCin = session.cin;

    if (token == null || token.isEmpty || parentCin == null) {
      return;
    }

    final uri = Uri.parse('$_apiBaseUrl/api/parents/$parentCin/children');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (!mounted) return;
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: response.statusCode,
      )) {
        return;
      }

      if (response.statusCode < 200 || response.statusCode >= 300) return;

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      final rawChildren = body['data'];
      if (rawChildren is! List) return;

      final parsed = rawChildren.whereType<Map>().map((item) {
        final map = item.cast<String, dynamic>();
        return Child(
          firstName: (map['firstName'] ?? '').toString(),
          lastName: (map['lastName'] ?? '').toString(),
          birthDate: (map['birthdate'] ?? '').toString(),
          description: '',
          medicalRecord: null,
          oldSchool: null,
          extraData: {
            'id': map['id'],
            'inscriptions': map['inscriptions'],
            'classes': map['classes'],
          },
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _parentChildren = parsed;
        setDrawerListArray();
      });
    } catch (_) {
      // Keep drawer usable with no children list if API is unreachable.
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    // If it's a teacher, we might want to keep the light mode or use a specific teacher theme.
    // For now, since this is a shared drawer and the redesign is heavily parent-focused,
    // we use the dark glass theme for everyone to keep it unified, or specialize based on role.
    final bool isParent = widget.userRole != 1;
    final Color bgColor = _baseDark.withValues(alpha: 0.95);
    final Color textColor = _lightText;
    final Color divColor = ThemeColors.glassBorder;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 40.0,
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            child: Row(
              children: <Widget>[
                Image.asset(
                  'assets/images/appImage.png',
                  width: 48,
                  height: 48,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 16),
                Text(
                  'PETIT SUIVI',
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: divColor),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: drawerList?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                if (drawerList![index].subList != null &&
                    drawerList![index].subList!.isNotEmpty) {
                  return _buildExpandableItem(drawerList![index], isParent);
                }
                return inkwell(drawerList![index], isParent);
              },
            ),
          ),
          Divider(height: 1, color: divColor),
          Consumer<ThemeManager>(
            builder: (context, theme, child) {
              return SwitchListTile(
                title: Text(
                  'Mode Clair',
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                secondary: Icon(
                  theme.isLightMode ? Icons.light_mode : Icons.dark_mode,
                  color: textColor,
                ),
                value: theme.isLightMode,
                onChanged: (val) {
                  theme.toggleTheme();
                },
                activeColor: _tealAccent,
              );
            },
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              top: 8,
            ),
            child: ListTile(
              title: Text(
                'Déconnexion',
                style: const TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.redAccent,
                ),
                textAlign: TextAlign.left,
              ),
              trailing: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
              ),
              onTap: onTapped,
            ),
          ),
        ],
      ),
    );
  }

  void onTapped() {
    context.read<AuthSession>().clear();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Widget inkwell(DrawerList listData, bool isParent) {
    bool isSelected = widget.screenIndex == listData.index;

    // Theme adaptations
    final Color selectedAccent = _tealAccent;
    final Color unselectedText = _mutedText;
    final Color selectedText = _lightText;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: selectedAccent.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        onTap: () {
          navigationToScreen(listData.index!);
        },
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 6.0,
                    height: 38.0,
                    decoration: BoxDecoration(
                      color: isSelected ? selectedAccent : Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _tealAccent.withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ]
                          : [],
                    ),
                  ),
                  const SizedBox(width: 16),
                  listData.isAssetsImage
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              isParent // Replace asset icon with vector if parent to guarantee color styling
                              ? Icon(
                                  Icons.support_agent_rounded,
                                  color: isSelected
                                      ? selectedAccent
                                      : unselectedText,
                                )
                              : Image.asset(
                                  listData.imageName,
                                  color: isSelected
                                      ? selectedAccent
                                      : unselectedText,
                                ),
                        )
                      : Icon(
                          listData.icon?.icon,
                          color: isSelected ? selectedAccent : unselectedText,
                        ),
                  const SizedBox(width: 16),
                  Text(
                    listData.labelName,
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 16,
                      color: isSelected ? selectedText : unselectedText,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.65,
                      decoration: BoxDecoration(
                        color: selectedAccent.withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(28),
                          bottomRight: Radius.circular(28),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableItem(DrawerList listData, bool isParent) {
    return Column(
      children: [
        inkwell(listData, isParent),
        ...listData.subList!
            .map((child) => _buildChildItem(child, isParent))
            .toList(),
      ],
    );
  }

  Widget _buildChildItem(Child child, bool isParent) {
    final canOpenProfile = _isChildApproved(child);
    final Color textColor = canOpenProfile
        ? _lightText
        : _mutedText.withValues(alpha: 0.5);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (!canOpenProfile) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Profil indisponible: inscription en attente d\'approbation.',
                ),
                backgroundColor: Colors.orangeAccent,
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChildDetailsPage(childData: child.toMap()),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 56, top: 12, bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.face_retouching_natural_rounded,
                size: 20,
                color: textColor.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 16),
              Text(
                child.firstName,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isChildApproved(Child child) {
    final inscriptions = child.extraData['inscriptions'];
    if (inscriptions is! List || inscriptions.isEmpty) {
      return false;
    }

    final latest = inscriptions.last;
    if (latest is! Map) {
      return false;
    }

    final status = latest['status']?.toString().toLowerCase();
    return status == 'approved';
  }

  Future<void> navigationToScreen(DrawerIndex indexScreen) async {
    widget.callBackIndex!(indexScreen);
  }
}

class DrawerList {
  DrawerList({
    this.isAssetsImage = false,
    this.labelName = '',
    this.icon,
    this.index,
    this.imageName = '',
    this.subList,
  });

  String labelName;
  Icon? icon;
  bool isAssetsImage;
  String imageName;
  DrawerIndex? index;
  List<Child>? subList;
}
