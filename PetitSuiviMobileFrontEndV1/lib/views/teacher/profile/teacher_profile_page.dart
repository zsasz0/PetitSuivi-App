import 'package:flutter/material.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/views/shared/components/profile_action_button.dart';
import 'package:newv/views/teacher/profile/components/profile/change_password_dialog.dart';
import 'package:newv/views/teacher/profile/components/profile/profile_header.dart';
import 'package:newv/views/teacher/profile/components/profile/profile_info_card.dart';
import 'package:newv/views/teacher/profile/components/profile/profile_stats_row.dart';
import 'package:newv/views/teacher/profile/controllers/teacher_profile_controller.dart';
import 'package:newv/views/teacher/profile/themes/teacher_profile_theme.dart';
import 'package:provider/provider.dart';

class TeacherProfilePage extends StatefulWidget {
  const TeacherProfilePage({super.key});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  late final TeacherProfileController _controller;
  int _classCount = 0;
  int _enfantCount = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _controller = TeacherProfileController(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchStats());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchStats() async {
    final stats = await _controller.fetchStats();
    if (!mounted) return;
    
    if (stats != null) {
      setState(() {
        _classCount = stats['classes'] ?? 0;
        _enfantCount = stats['enfants'] ?? 0;
        _isLoadingStats = false;
      });
    } else {
      setState(() => _isLoadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final session = context.watch<AuthSession>();
    
    final firstName = session.firstName ?? '';
    final lastName = session.lastName ?? '';
    final fullName = '$firstName $lastName'.trim();
    final email = session.email ?? '';
    final phone = session.phone ?? '';
    final address = session.address ?? '-';
    
    final age = _controller.calculateAge(session.birthdate);
    final yearsOfTeaching = _controller.calculateYearsOfTeaching(session.inscriptionDate);

    return Scaffold(
      backgroundColor: TeacherProfileTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Mon Profil',
          style: TeacherProfileTheme.titleStyle,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios, color: TeacherProfileTheme.textColor),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: EdgeInsets.only(
          bottom: 100 + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          const SizedBox(height: 16),
          ProfileHeader(
            firstName: firstName,
            lastName: lastName,
            fullName: fullName,
          ),
          const SizedBox(height: 32),
          ProfileInfoCard(
            email: email,
            phone: phone,
            address: address,
            yearsOfTeaching: yearsOfTeaching,
            age: age,
          ),
          const SizedBox(height: 24),
          ProfileStatsRow(
            isLoading: _isLoadingStats,
            classCount: _classCount,
            enfantCount: _enfantCount,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ProfileActionButton(
                  icon: Icons.lock,
                  text: 'Changer le mot de passe',
                  color: TeacherProfileTheme.primaryColor,
                  onTap: () => _showChangePasswordDialog(context),
                ),
                const SizedBox(height: 16),
                ProfileActionButton(
                  icon: Icons.logout,
                  text: 'Déconnexion',
                  color: Colors.redAccent,
                  onTap: () => _controller.handleLogout(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => ChangePasswordDialog(controller: _controller),
    );
  }
}
