import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/views/teacher/activities/controllers/suggest_activities_controller.dart';
import 'package:newv/views/teacher/activities/components/suggest_activities/suggest_activities_item.dart';
import 'package:newv/views/teacher/activities/components/suggest_activities/suggest_activities_dialog.dart';

class SuggestActivitiesPage extends StatefulWidget {
  const SuggestActivitiesPage({super.key});

  @override
  State<SuggestActivitiesPage> createState() => _SuggestActivitiesPageState();
}

class _SuggestActivitiesPageState extends State<SuggestActivitiesPage> {
  late SuggestActivitiesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SuggestActivitiesController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadData(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SuggestActivitiesController>.value(
      value: _controller,
      child: Consumer<SuggestActivitiesController>(
        builder: (context, controller, child) {
          context.watch<ThemeManager>();
          
          return Scaffold(
            backgroundColor: AppTheme.background,
            appBar: AppBar(
              title: Text(
                'Suggestions d\'activités',
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkerText,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: AppTheme.darkerText),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh, color: AppTheme.darkerText),
                  onPressed: () => controller.loadData(context),
                ),
              ],
            ),
            body: _buildBody(controller),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddDialog(controller),
              backgroundColor: AppTheme.nearlyDarkBlue,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(SuggestActivitiesController controller) {
    if (controller.isLoadingSuggestions && controller.teacherSuggestions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.suggestionsError != null && controller.teacherSuggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(controller.suggestionsError!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.loadData(context),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      children: [
        if (controller.teacherSuggestions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.history, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Aucune suggestion d\'activité pour le moment.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          ...controller.teacherSuggestions.map((item) => SuggestActivitiesItem(item: item)),
      ],
    );
  }

  void _showAddDialog(SuggestActivitiesController controller) {
    if (controller.teacherClasses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune classe assignée pour proposer une activité.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => SuggestActivitiesDialog(
        teacherClasses: controller.teacherClasses,
        controller: controller,
      ),
    );
  }
}
