import 'package:flutter/material.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/views/teacher/photos/components/common/section_card.dart';
import 'package:newv/views/teacher/photos/components/teacher_photo_sharing/children_selector.dart';
import 'package:newv/views/teacher/photos/components/teacher_photo_sharing/class_selector.dart';
import 'package:newv/views/teacher/photos/components/teacher_photo_sharing/photo_upload.dart';
import 'package:newv/views/teacher/photos/components/teacher_photo_sharing/recent_shares.dart';
import 'package:newv/views/teacher/photos/controllers/teacher_photo_sharing_controller.dart';
import 'package:newv/views/teacher/photos/themes/photos_theme.dart';
import 'package:provider/provider.dart';

class TeacherPhotoSharingPage extends StatefulWidget {
  const TeacherPhotoSharingPage({super.key});

  @override
  State<TeacherPhotoSharingPage> createState() => _TeacherPhotoSharingPageState();
}

class _TeacherPhotoSharingPageState extends State<TeacherPhotoSharingPage> {
  late TeacherPhotoSharingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TeacherPhotoSharingController(
      context: context,
      setState: setState,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Scaffold(
      backgroundColor: PhotosTheme.background,
      appBar: AppBar(
        title: Text(
          'Partage Photos Parents',
          style: PhotosTheme.titleStyle,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios, color: PhotosTheme.text),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: PhotosTheme.primary),
            onPressed: _controller.refreshData,
            tooltip: 'Rafraîchir les partages récents',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: PhotosTheme.primary,
        backgroundColor: PhotosTheme.surface,
        onRefresh: _controller.refreshData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoadingClasses) {
      return Center(
        child: CircularProgressIndicator(color: PhotosTheme.primary),
      );
    }

    if (_controller.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _controller.error!,
              style: TextStyle(
                color: PhotosTheme.accentRed,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _controller.loadClasses,
              style: ElevatedButton.styleFrom(
                backgroundColor: PhotosTheme.primary,
                foregroundColor: PhotosTheme.background,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        SectionCard(
          title: '1) Classe',
          child: ClassSelector(controller: _controller),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: '2) Enfants destinataires',
          child: ChildrenSelector(controller: _controller),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: '3) Photo',
          child: PhotoUpload(controller: _controller),
        ),
        const SizedBox(height: 18),
        RecentShares(controller: _controller),
      ],
    );
  }
}
