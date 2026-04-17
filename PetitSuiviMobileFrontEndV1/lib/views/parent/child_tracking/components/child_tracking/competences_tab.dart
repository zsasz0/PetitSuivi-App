import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/services/evaluation_service.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/views/themes/theme_colors.dart';

// File: competences_tab.dart
// Purpose: Displays a child's educational evaluations and skill acquisition status.
// Usage: Tab item in ChildDetailsPage.
// API Usage: Yes, GET /api/children/{childId}/evaluations (via EvaluationService).
// Dependencies: EvaluationService, AppTheme.

/// A tab page that summarizes and detail's a child's academic competencies.
class ChildTrackingCompetencesTab extends StatefulWidget {
  final String childName;
  final DateTime minDate;
  final DateTime maxDate;
  final int? childId;

  const ChildTrackingCompetencesTab({
    super.key,
    required this.childName,
    required this.minDate,
    required this.maxDate,
    this.childId,
  });

  @override
  State<ChildTrackingCompetencesTab> createState() =>
      _ChildTrackingCompetencesTabState();
}

class _ChildTrackingCompetencesTabState
    extends State<ChildTrackingCompetencesTab> {
  final EvaluationService _evaluationService = EvaluationService();
  bool _isLoading = true;
  String? _error;
  List<dynamic> _todayEvaluations = [];
  List<dynamic> _historicEvaluations = [];
  DateTime? _selectedHistoryDate;
  int _todayCurrentPage = 1;
  static const int _todayItemsPerPage = 2;
  int _historyCurrentPage = 1;
  static const int _historyItemsPerPage = 2;

  // Modern Theme Colors
  static Color get _baseDark => ThemeManager.instance.isLightMode
      ? const Color(0xFFF0F2F5)
      : const Color(0xFF141B2D);
  static Color get _surfaceDark => ThemeManager.instance.isLightMode
      ? const Color(0xFFFFFFFF)
      : const Color(0xFF1A2235);
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

  // Real date for fetching today's evaluation demo
  final String _todayString = DateTime.now()
      .toString()
      .split(' ')[0]
      .substring(0, 10);

  @override
  void initState() {
    super.initState();
    _fetchEvaluations();
  }

  Future<void> _fetchEvaluations() async {
    if (widget.childId == null) {
      setState(() {
        _isLoading = false;
        _error =
            'Impossible de charger l\'identifiant de l\'enfant. Veuillez vous reconnecter.';
      });
      return;
    }

    try {
      final evals = await _evaluationService.getParentCompetences(
        widget.childId!,
      );

      final todayList = [];
      final historicList = [];

      String minDateStr =
          "${widget.minDate.year}-${widget.minDate.month.toString().padLeft(2, '0')}-${widget.minDate.day.toString().padLeft(2, '0')}";
      String maxDateStr =
          "${widget.maxDate.year}-${widget.maxDate.month.toString().padLeft(2, '0')}-${widget.maxDate.day.toString().padLeft(2, '0')}";

      for (var eval in evals) {
        // Try multiple potential keys for date
        String evalDate = (eval['evaluation_date'] ?? eval['date'] ?? '').toString();

        if (evalDate.isEmpty) continue;
        
        // Handle full ISO strings by taking only the date part
        if (evalDate.contains('T')) {
          evalDate = evalDate.split('T')[0];
        }

        if (evalDate.compareTo(minDateStr) < 0 ||
            evalDate.compareTo(maxDateStr) > 0) {
          continue;
        }

        if (evalDate == _todayString) {
          todayList.add(eval);
        } else {
          historicList.add(eval);
        }
      }

      if (!mounted) return;
      setState(() {
        _todayEvaluations = todayList;
        _historicEvaluations = historicList;
        _selectedHistoryDate = null;
        _todayCurrentPage = 1;
        _historyCurrentPage = 1;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Oups! Erreur de chargement des évaluations. ($e)';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_tealAccent),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: _mutedText.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontSize: 16,
                  color: _mutedText,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _fetchEvaluations();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _tealAccent,
                  foregroundColor: _baseDark,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_todayEvaluations.isEmpty && _historicEvaluations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.school_outlined,
                size: 64,
                color: _mutedText.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune évaluation disponible pour le moment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontSize: 16,
                  color: _mutedText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Flatten all criteria to calculate the summaries
    final List<dynamic> allCriteria = [];
    for (var eval in _todayEvaluations) {
      allCriteria.addAll(eval['criteria'] ?? []);
    }
    for (var eval in _historicEvaluations) {
      allCriteria.addAll(eval['criteria'] ?? []);
    }

    final acquiredCount = allCriteria
        .where((c) => c['status_label'] == 'Acquise')
        .length;
    final needsWorkCount = allCriteria
        .where((c) => c['status_label'] == 'À renforcer')
        .length;

    final filteredHistory = _selectedHistoryDate == null
        ? _historicEvaluations
        : _historicEvaluations.where((eval) {
            final dateStr = eval['date'] ?? '';
            return dateStr.startsWith(
              _selectedHistoryDate!.toString().substring(0, 10),
            );
          }).toList();

    final totalTodayItems = _todayEvaluations.length;
    final totalTodayPages = (totalTodayItems / _todayItemsPerPage).ceil();
    final todayStartIndex = (_todayCurrentPage - 1) * _todayItemsPerPage;
    final todayStartLabel = totalTodayItems == 0 ? 0 : todayStartIndex + 1;
    final todayEndIndex =
        (todayStartIndex + _todayItemsPerPage > totalTodayItems)
        ? totalTodayItems
        : todayStartIndex + _todayItemsPerPage;
    final paginatedToday = _todayEvaluations.isNotEmpty
        ? _todayEvaluations.sublist(todayStartIndex, todayEndIndex)
        : [];

    // Pagination calculations
    final totalHistoryItems = filteredHistory.length;
    final totalHistoryPages = (totalHistoryItems / _historyItemsPerPage).ceil();
    final startIndex = (_historyCurrentPage - 1) * _historyItemsPerPage;
    final endIndex = (startIndex + _historyItemsPerPage > totalHistoryItems)
        ? totalHistoryItems
        : startIndex + _historyItemsPerPage;
    final paginatedHistory = filteredHistory.isNotEmpty
        ? filteredHistory.sublist(startIndex, endIndex)
        : [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...() {
            // Keep fake pedagogical alerts for visual display until backed up via /signalements
            final alerts = const <dynamic>[];
            final childAlert = alerts
                .where((a) => a.childId == widget.childName)
                .toList();
            if (childAlert.isEmpty) return <Widget>[];
            final alert = childAlert.first;
            return <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange[300],
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alerte pédagogique',
                            style: TextStyle(
                              fontFamily: AppTheme.fontName,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.orange[300],
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...alert.reasons.map(
                            (r) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 6,
                                    color: Colors.orange[400],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      r,
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontSize: 13,
                                        color: _lightText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nous vous recommandons de contacter l\'éducatrice pour en discuter.',
                            style: TextStyle(
                              fontFamily: AppTheme.fontName,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: _mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ];
          }(),

          Text(
            'Points forts & axes de progrès',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _lightText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSummaryChip(
                'Acquise',
                acquiredCount,
                const Color(0xFF00C853),
              ),
              const SizedBox(width: 12),
              _buildSummaryChip(
                'À renforcer',
                needsWorkCount,
                const Color(0xFFEF5350),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'Détail par Activité',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _lightText,
            ),
          ),
          const SizedBox(height: 16),

          if (_todayEvaluations.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aujourd\'hui',
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _tealAccent,
                  ),
                ),
                if (totalTodayPages > 1)
                  Text(
                    'Page $_todayCurrentPage/$totalTodayPages',
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontSize: 12,
                      color: _mutedText,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ...paginatedToday.map((eval) => _buildActivityEvaluationCard(eval)),
            if (totalTodayPages > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.chevron_left,
                        color: _todayCurrentPage > 1
                            ? _tealAccent
                            : _mutedText.withValues(alpha: 0.5),
                      ),
                      onPressed: _todayCurrentPage > 1
                          ? () {
                              setState(() {
                                _todayCurrentPage--;
                              });
                            }
                          : null,
                    ),
                    Text(
                      '$todayStartLabel-$todayEndIndex sur $totalTodayItems',
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        color: _lightText,
                        fontSize: 13,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_right,
                        color: _todayCurrentPage < totalTodayPages
                            ? _tealAccent
                            : _mutedText.withValues(alpha: 0.5),
                      ),
                      onPressed: _todayCurrentPage < totalTodayPages
                          ? () {
                              setState(() {
                                _todayCurrentPage++;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
          ],

          if (_historicEvaluations.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Historique',
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _indigoAccent,
                  ),
                ),
                Row(
                  children: [
                    if (_selectedHistoryDate != null)
                      IconButton(
                        icon: Icon(Icons.clear, size: 20, color: _mutedText),
                        onPressed: () {
                          setState(() {
                            _selectedHistoryDate = null;
                            _historyCurrentPage = 1;
                          });
                        },
                        tooltip: 'Effacer le filtre',
                      ),
                    IconButton(
                      icon: Icon(Icons.calendar_month, color: _indigoAccent),
                      onPressed: _pickHistoryDate,
                      tooltip: 'Filtrer par date',
                    ),
                  ],
                ),
              ],
            ),
            if (filteredHistory.isEmpty && _selectedHistoryDate != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Aucune évaluation à cette date.',
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      color: _mutedText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else ...[
              const SizedBox(height: 8),
              ...paginatedHistory.map(
                (eval) => _buildActivityEvaluationCard(eval),
              ),
              if (totalHistoryPages > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.chevron_left,
                          color: _historyCurrentPage > 1
                              ? _indigoAccent
                              : _mutedText.withValues(alpha: 0.5),
                        ),
                        onPressed: _historyCurrentPage > 1
                            ? () {
                                setState(() {
                                  _historyCurrentPage--;
                                });
                              }
                            : null,
                      ),
                      Text(
                        'Page $_historyCurrentPage sur $totalHistoryPages',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          color: _lightText,
                          fontSize: 14,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.chevron_right,
                          color: _historyCurrentPage < totalHistoryPages
                              ? _indigoAccent
                              : _mutedText.withValues(alpha: 0.5),
                        ),
                        onPressed: _historyCurrentPage < totalHistoryPages
                            ? () {
                                setState(() {
                                  _historyCurrentPage++;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
            ],
          ],

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeColors.glassBackgroundSubtle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeColors.glassBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Légende',
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _lightText,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLegendRow(
                  const Color(0xFF00C853),
                  'Acquise',
                  'Compétence maîtrisée',
                ),
                const SizedBox(height: 8),
                _buildLegendRow(
                  const Color(0xFFFFA726),
                  'En cours',
                  'En voie d\'acquisition',
                ),
                const SizedBox(height: 8),
                _buildLegendRow(
                  const Color(0xFFEF5350),
                  'À renforcer',
                  'Nécessite un accompagnement',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickHistoryDate() async {
    final now = DateTime.now();
    DateTime last = widget.maxDate;
    if (last.isBefore(widget.minDate)) last = widget.minDate;

    DateTime initial =
        _selectedHistoryDate ?? now.subtract(const Duration(days: 1));
    if (initial.isBefore(widget.minDate)) initial = widget.minDate;
    if (initial.isAfter(last)) initial = last;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: widget.minDate,
      lastDate: last,
      builder: (context, child) {
        final isLight = ThemeManager.instance.isLightMode;
        return Theme(
          data: (isLight ? ThemeData.light() : ThemeData.dark()).copyWith(
            colorScheme:
                (isLight ? const ColorScheme.light() : const ColorScheme.dark())
                    .copyWith(
                      primary: _tealAccent,
                      onPrimary: isLight ? Colors.white : _surfaceDark,
                      surface: _surfaceDark,
                      onSurface: _lightText,
                    ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedHistoryDate = picked;
        _historyCurrentPage = 1;
      });
    }
  }

  Widget _buildSummaryChip(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityEvaluationCard(dynamic evaluation) {
    // Parent UI uses the exact date of the evaluation returned from backend
    // Try multiple keys for date and activity details
    String dateStr = (evaluation['evaluation_date'] ?? evaluation['date'] ?? 'Date inconnue').toString();
    if (dateStr.contains('T')) dateStr = dateStr.split('T')[0];
    
    final teacherMap = evaluation['teacher'];
    final teacherName = evaluation['teacher_name'] ?? 
                      (teacherMap is Map ? '${teacherMap['firstName']} ${teacherMap['lastName']}' : 'Éducatrice');
    
    final activityMap = evaluation['activity'];
    final activityName = evaluation['activity_name'] ?? 
                        (activityMap is Map ? activityMap['title'] : 'Activité ${evaluation['activity_id']}');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ThemeColors.glassBackgroundSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _indigoAccent.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header of Activity Level
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _indigoAccent.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _indigoAccent.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star_border,
                    color: _indigoAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activityName,
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _lightText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person, size: 12, color: _mutedText),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Par $teacherName',
                              style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontSize: 12,
                                color: _mutedText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: _mutedText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontFamily: AppTheme.fontName,
                              fontSize: 12,
                              color: _mutedText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List Criteria inside this activity
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (evaluation['criteria'] as List<dynamic>)
                  .map((crit) => _buildCriterionRow(crit))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriterionRow(dynamic record) {
    String levelLabel = record['status_label'] ?? 'Non évalué';
    Color levelColor;
    IconData levelIcon;

    if (levelLabel.toLowerCase().contains('acquise')) {
      levelColor = const Color(0xFF00C853);
      levelIcon = Icons.check_circle;
    } else if (levelLabel.toLowerCase().contains('en cours')) {
      levelColor = const Color(0xFFFFA726);
      levelIcon = Icons.timelapse;
    } else {
      levelColor = const Color(0xFFEF5350);
      levelIcon = Icons.warning_amber_rounded;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: levelColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  record['criteria_name'] ?? 'Critère ${record['criteria_id']}',
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _lightText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: levelColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(levelIcon, size: 12, color: levelColor),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          levelLabel,
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: levelColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(Color color, String label, String description) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: _lightText,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            '— $description',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: 12,
              color: _mutedText,
            ),
          ),
        ),
      ],
    );
  }
}
