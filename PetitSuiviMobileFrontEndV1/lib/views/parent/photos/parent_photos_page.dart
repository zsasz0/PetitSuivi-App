import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/views/parent/photos/components/photos/child_selector.dart';
import 'package:newv/views/parent/photos/components/photos/empty_state.dart';
import 'package:newv/views/parent/photos/components/photos/photos_list.dart';
import 'package:newv/views/parent/photos/controllers/photos_controller.dart';
import 'package:newv/views/parent/photos/themes/photos_theme.dart';
import 'package:provider/provider.dart';

class ParentPhotosPage extends StatefulWidget {
  const ParentPhotosPage({super.key});

  @override
  State<ParentPhotosPage> createState() => _ParentPhotosPageState();
}

class _ParentPhotosPageState extends State<ParentPhotosPage> {
  late final PhotosController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PhotosController(session: context.read<AuthSession>());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadChildren(onUpdate: () {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();

    return Container(
      color: PhotosTheme.baseDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Photos',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: PhotosTheme.lightText,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () => _controller.refresh(
                onUpdate: () {
                  if (mounted) setState(() {});
                },
              ),
              icon: Icon(Icons.refresh_rounded, color: PhotosTheme.tealAccent),
              tooltip: 'Actualiser',
            ),
          ],
        ),
        body: _controller.isLoadingChildren
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    PhotosTheme.tealAccent,
                  ),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: ChildSelector(
                      children: _controller.children,
                      selectedChildId: _controller.selectedChildId,
                      onChanged: (value) {
                        _controller.selectChild(
                          value,
                          onUpdate: () {
                            if (mounted) setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _controller.selectedChildId == null
                        ? const PhotosEmptyState()
                        : PhotosList(controller: _controller),
                  ),
                ],
              ),
      ),
    );
  }
}
