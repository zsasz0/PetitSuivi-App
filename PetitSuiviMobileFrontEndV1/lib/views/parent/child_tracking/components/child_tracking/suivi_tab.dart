import 'package:newv/utils/api_constants.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/utils/unauthorized_handler.dart';
import 'package:provider/provider.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/views/themes/theme_colors.dart';

// File: suivi_tab.dart
// Purpose: Displays the daily activity program for a child's class.
// Usage: Tab item in ChildDetailsPage.
// API Usage: Yes, GET /api/classes/{classId}/activities/date/{today}.
// Dependencies: AuthSession, UnauthorizedHandler, ApiConstants.

/// A timeline-style view showing scheduled activities for the child's class.
class ChildTrackingSuiviTab extends StatefulWidget {
  final int? classId;

  const ChildTrackingSuiviTab({super.key, this.classId});

  @override
  State<ChildTrackingSuiviTab> createState() => _ChildTrackingSuiviTabState();
}

class _ChildTrackingSuiviTabState extends State<ChildTrackingSuiviTab> {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  // Modern Theme Colors
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

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _activities = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadActivities());
  }

  Future<void> _loadActivities() async {
    if (widget.classId == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Classe de l\'enfant introuvable';
      });
      return;
    }

    final session = context.read<AuthSession>();
    final token = session.token;
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Session expirée. Veuillez vous reconnecter.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final uri = Uri.parse(
      '$_apiBaseUrl/api/classes/${widget.classId}/activities/date/$dateStr',
    );

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

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        final data = body['data'];

        // Debugging to ensure we're getting the right activities for the given date.
        debugPrint('[SuiviTab] Fetched activities data for $dateStr: $data');

        if (data is Map && data['activities'] is List) {
          final dataActivities = data['activities'] as List;
          final mappedActivities = dataActivities
              .whereType<Map<String, dynamic>>()
              .map((item) {
                String formatTime(dynamic timeVal) {
                  if (timeVal == null) return '';
                  final str = timeVal.toString();
                  if (str.contains(':')) {
                    final parts = str.split(':');
                    if (parts.length >= 2) {
                      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
                    }
                  }
                  return str;
                }

                final start = formatTime(item['start_time']);
                final end = formatTime(item['end_time']);

                String timeStr = 'Heure inconnue';
                if (start.isNotEmpty && end.isNotEmpty) {
                  timeStr = '$start - $end';
                } else if (start.isNotEmpty) {
                  timeStr = start;
                }

                return {
                  'time': timeStr,
                  'title':
                      item['activity_name']?.toString() ??
                      'Activité sans titre',
                  'description': item['description']?.toString() ?? '',
                };
              })
              .toList();

          setState(() {
            _activities = mappedActivities;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Format de réponse inattendu.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Erreur lors du chargement des activités (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Impossible de contacter le serveur.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Programme du jour',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _lightText,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_tealAccent),
                ),
              ),
            )
          else if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            )
          else if (_activities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Aucune activité prévue pour aujourd\'hui.',
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    color: _mutedText,
                  ),
                ),
              ),
            )
          else
            ..._activities.map(
              (activity) => _buildTimelineItem(
                activity['time'] as String,
                activity['title'] as String,
                activity['description'] as String,
                Icons.palette_outlined,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String time,
    String title,
    String description,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _indigoAccent.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: _indigoAccent, size: 20),
              ),
              Container(
                width: 2,
                height: 50,
                color: ThemeColors.glassBorderStrong,
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeColors.glassBorderSubtle,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ThemeColors.glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      color: _mutedText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _lightText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      color: _mutedText.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
