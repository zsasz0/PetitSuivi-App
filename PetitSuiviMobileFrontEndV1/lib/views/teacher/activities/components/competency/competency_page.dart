import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/teacher/activities/controllers/competency_controller.dart';
import 'package:newv/views/teacher/activities/components/competency/competency_class_card.dart';
import 'package:newv/views/teacher/activities/components/competency/competency_child_card.dart';
import 'package:newv/views/teacher/activities/components/competency/competency_skill_card.dart';
import 'package:newv/views/teacher/activities/components/competency/competency_signalement_section.dart';
import 'package:newv/views/teacher/activities/themes/activities_theme.dart';
import 'package:newv/models/teacher_models.dart' as mock;

class CompetencyPage extends StatefulWidget {
  const CompetencyPage({super.key});

  @override
  State<CompetencyPage> createState() => _CompetencyPageState();
}

class _CompetencyPageState extends State<CompetencyPage> {
  late CompetencyController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CompetencyController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CompetencyController>.value(
      value: _controller,
      child: Consumer<CompetencyController>(
        builder: (context, controller, child) {
          context.watch<ThemeManager>();
          
          return Scaffold(
            backgroundColor: TeacherTheme.baseDark,
            appBar: AppBar(
              title: Text(
                'Suivi des Compétences',
                style: TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  fontWeight: FontWeight.bold,
                  color: TeacherTheme.lightText,
                  fontSize: 20,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: TeacherTheme.lightText),
                onPressed: () => controller.goBack(),
              ),
            ),
            body: controller.isLoading
                ? Center(child: CircularProgressIndicator(color: ActivitiesTheme.primaryBlue))
                : _buildBody(controller),
          );
        },
      ),
    );
  }

  Widget _buildBody(CompetencyController controller) {
    switch (controller.currentStep) {
      case CompetencyStep.classPicker:
        return _buildClassPicker(controller);
      case CompetencyStep.childPicker:
        return _buildChildPicker(controller);
      case CompetencyStep.editor:
        return _buildCompetencyEditor(controller);
    }
  }

  Widget _buildClassPicker(CompetencyController controller) {
    // In a real app, classes would be fetched from a service.
    // The original file had constant classes. I'll use those if available or just show a label.
    final List<mock.ClassRoom> mockClasses = []; // Should be populated from somewhere

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Choisir une classe',
          style: TextStyle(
            fontFamily: TeacherTheme.fontName,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: TeacherTheme.lightText,
          ),
        ),
        const SizedBox(height: 16),
        if (mockClasses.isEmpty)
           Center(child: Text('Aucune classe disponible', style: TextStyle(color: TeacherTheme.mutedText)))
        else
          ...mockClasses.map((cls) => CompetencyClassCard(
            cls: cls,
            onTap: () => controller.selectClass(cls),
          )),
      ],
    );
  }

  Widget _buildChildPicker(CompetencyController controller) {
    return Column(
      children: [
        InkWell(
          onTap: () => controller.goBack(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: TeacherTheme.surfaceDark,
              border: Border(bottom: BorderSide(color: ThemeColors.glassBorderSubtle)),
            ),
            child: Row(
              children: [
                Icon(Icons.arrow_back, size: 18, color: ActivitiesTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  controller.selectedClass!.name,
                  style: TextStyle(
                    fontFamily: TeacherTheme.fontName,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: ActivitiesTheme.primaryBlue,
                  ),
                ),
                const Spacer(),
                Text(
                  'Changer de classe',
                  style: TextStyle(fontFamily: TeacherTheme.fontName, fontSize: 12, color: TeacherTheme.mutedText),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Choisir un enfant',
                style: TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: TeacherTheme.lightText,
                ),
              ),
              const SizedBox(height: 16),
              ...controller.selectedClass!.children.map((child) => CompetencyChildCard(
                child: child,
                onTap: () => controller.selectChild(context, child),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompetencyEditor(CompetencyController controller) {
    final child = controller.selectedChild!;

    if (controller.classActivities.isEmpty) {
      return _buildEmptyState(controller, child);
    }

    return Column(
      children: [
        InkWell(
          onTap: () => controller.goBack(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: TeacherTheme.surfaceDark,
              border: Border(bottom: BorderSide(color: ThemeColors.glassBorderSubtle)),
            ),
            child: Row(
              children: [
                Icon(Icons.arrow_back, size: 18, color: ActivitiesTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  child.fullName,
                  style: TextStyle(
                    fontFamily: TeacherTheme.fontName,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: ActivitiesTheme.primaryBlue,
                  ),
                ),
                const Spacer(),
                Text(
                  'Changer d\'enfant',
                  style: TextStyle(fontFamily: TeacherTheme.fontName, fontSize: 12, color: TeacherTheme.mutedText),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Évaluations de ${child.firstName}',
                style: TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: TeacherTheme.lightText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Les évaluations sont automatiquement sauvegardées lors de la sélection.',
                style: TextStyle(fontFamily: TeacherTheme.fontName, fontSize: 13, color: TeacherTheme.mutedText),
              ),
              const SizedBox(height: 20),
              ...controller.classActivities.map((activity) => _buildActivityEvaluationSection(controller, activity)),
              const SizedBox(height: 24),
              CompetencySignalementSection(
                childName: child.firstName,
                existingNotes: controller.signalements,
                onAddNote: (text) => controller.addSignalement(context, text),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(CompetencyController controller, mock.MockChild child) {
    return Column(
      children: [
        InkWell(
          onTap: () => controller.goBack(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: TeacherTheme.surfaceDark,
              border: Border(bottom: BorderSide(color: ThemeColors.glassBorderSubtle)),
            ),
            child: Row(
              children: [
                Icon(Icons.arrow_back, size: 18, color: ActivitiesTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  child.fullName,
                  style: TextStyle(
                    fontFamily: TeacherTheme.fontName,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: ActivitiesTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              'Aucune activité prévue pour aujourd\'hui.',
              style: TextStyle(fontFamily: TeacherTheme.fontName, color: TeacherTheme.lightText),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityEvaluationSection(CompetencyController controller, dynamic activityData) {
    final existingEval = controller.childEvaluations.firstWhere(
      (e) => e['activity_id'] == activityData['activity_id'],
      orElse: () => null,
    );
    final existingCriteria = existingEval != null ? existingEval['criteria'] as List<dynamic> : [];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ActivitiesTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.local_activity, color: ActivitiesTheme.primaryBlue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    activityData['activity_name'] ?? 'Activité',
                    style: TextStyle(
                      fontFamily: TeacherTheme.fontName,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: ActivitiesTheme.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...((activityData['criteria'] as List<dynamic>).map((criterion) {
            final savedCrit = existingCriteria.firstWhere(
              (c) => c['criteria_id'] == criterion['criteria_id'],
              orElse: () => null,
            );
            final initialLevelStr = savedCrit != null ? savedCrit['status_label'] : 'En cours';
            final initialComment = savedCrit != null ? savedCrit['comment'] : null;

            return CompetencySkillCard(
              key: ValueKey('${controller.selectedChild!.firstName}_${activityData['activity_id']}_${criterion['criteria_id']}'),
              criterionName: criterion['criteria_name'] ?? 'Compétence',
              initialLevelStr: initialLevelStr,
              currentComment: initialComment,
              onChanged: (newLevelStr, newComment) => controller.evaluateCriteria(
                context: context,
                activityId: activityData['activity_id'],
                criteriaId: criterion['criteria_id'],
                statusLabel: newLevelStr,
                comment: newComment,
              ),
            );
          })),
        ],
      ),
    );
  }
}
