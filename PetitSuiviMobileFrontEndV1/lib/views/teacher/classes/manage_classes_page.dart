import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/views/teacher/classes/components/class_detail/class_detail_page.dart';
import 'package:newv/views/teacher/classes/components/manage_classes/classes_list_section.dart';
import 'package:newv/views/teacher/classes/controllers/manage_classes_controller.dart';
import 'package:newv/views/teacher/classes/themes/teacher_classes_theme.dart';

/// Page that fetches and displays a list of classes assigned to the logged-in teacher.
class ManageClassesPage extends StatefulWidget {
  const ManageClassesPage({super.key});

  @override
  State<ManageClassesPage> createState() => _ManageClassesPageState();
}

class _ManageClassesPageState extends State<ManageClassesPage> {
  final ManageClassesController _controller = ManageClassesController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final session = context.read<AuthSession>();
    _controller.loadTeacherClasses(
      context: context,
      token: session.token,
      teacherCin: session.cin,
      setState: setState,
      isMounted: () => mounted,
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Scaffold(
      backgroundColor: TeacherClassesTheme.baseDark,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Gérer les Classes',
        style: TeacherClassesTheme.appBarTitleStyle,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: TeacherClassesTheme.lightText,
              ),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: TeacherClassesTheme.tealAccent),
      );
    }

    if (_controller.error != null) {
      return _buildErrorView();
    }

    return ClassesListSection(
      classrooms: _controller.classrooms,
      onOpenClass: (classroom) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClassDetailPage(classroom: classroom),
          ),
        );
      },
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
            const SizedBox(height: 16),
            Text(
              _controller.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: TeacherClassesTheme.fontName,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: TeacherClassesTheme.tealAccent,
                foregroundColor: TeacherClassesTheme.baseDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _loadData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
