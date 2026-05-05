import 'package:flutter/material.dart';
import 'package:newv/models/signalement.dart';
import 'package:newv/models/teacher_models.dart' as mock;
import 'package:newv/services/evaluation_service.dart';

enum CompetencyStep { classPicker, childPicker, editor }

class CompetencyController extends ChangeNotifier {
  final EvaluationService _evaluationService = EvaluationService();
  
  CompetencyStep currentStep = CompetencyStep.classPicker;
  
  mock.ClassRoom? selectedClass;
  mock.MockChild? selectedChild;

  bool isLoading = false;
  List<dynamic> classActivities = [];
  List<dynamic> childEvaluations = [];
  List<Signalement> signalements = [];

  final String demoDate = "2026-03-05";
  final int currentTeacherId = 88552233;

  void selectClass(mock.ClassRoom cls) {
    selectedClass = cls;
    currentStep = CompetencyStep.childPicker;
    notifyListeners();
  }

  Future<void> selectChild(BuildContext context, mock.MockChild child) async {
    selectedChild = child;
    isLoading = true;
    notifyListeners();

    try {
      // Real child & class IDs
      int currentClassId = 3; // Demo: Sami's class
      int currentChildId = child.firstName == "Sami" ? 8 : 999;

      final activities = await _evaluationService.getClassActivities(
        currentClassId,
        demoDate,
      );
      final evals = await _evaluationService.getChildEvaluations(
        currentChildId,
        demoDate,
      );
      final signals = await _evaluationService.getSignalementsForChild(
        currentChildId,
      );

      classActivities = activities;
      childEvaluations = evals;
      signalements = signals;
      currentStep = CompetencyStep.editor;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> evaluateCriteria({
    required BuildContext context,
    required int activityId,
    required int criteriaId,
    required String statusLabel,
    required String? comment,
  }) async {
    if (selectedChild == null) return;
    
    try {
      await _evaluationService.evaluateCriteria(
        childId: selectedChild!.firstName == "Sami" ? 8 : 999,
        activityId: activityId,
        teacherId: currentTeacherId,
        date: demoDate,
        criteriaId: criteriaId,
        statusLabel: statusLabel,
        comment: comment,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sauvegardé.'),
            backgroundColor: Color(0xFF00C853),
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> addSignalement(BuildContext context, String text) async {
    if (selectedChild == null) return;
    
    final signalement = Signalement(
      id: 0,
      childId: selectedChild!.firstName == "Sami" ? 8 : 999,
      teacherId: currentTeacherId,
      activityId: classActivities.isNotEmpty ? classActivities.first['activity_id'] : null,
      alertType: 'Humeur',
      comment: text,
      incidentTime: DateTime.now(),
    );

    try {
      await _evaluationService.saveSignalement(signalement);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Note ajoutée pour ${selectedChild!.firstName}'),
            backgroundColor: const Color(0xFF1A1F2B),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
      // Refetch notes
      final currentChildId = selectedChild!.firstName == "Sami" ? 8 : 999;
      signalements = await _evaluationService.getSignalementsForChild(currentChildId);
      notifyListeners();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void goBack() {
    if (currentStep == CompetencyStep.editor) {
      currentStep = CompetencyStep.childPicker;
      selectedChild = null;
      classActivities = [];
      childEvaluations = [];
      signalements = [];
    } else if (currentStep == CompetencyStep.childPicker) {
      currentStep = CompetencyStep.classPicker;
      selectedClass = null;
    }
    notifyListeners();
  }

  void reset() {
    selectedClass = null;
    selectedChild = null;
    currentStep = CompetencyStep.classPicker;
    notifyListeners();
  }
}
