import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/views/parent/child_tracking/photos/photos_tab.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newv/utils/api_constants.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';

// File: parent_photos_page.dart
// Purpose: A gallery view for parents to see photos of their children.
// Usage: Accessed via the "Photos" tab or drawer.
// API Usage:
//   - GET /api/parents/{cin}/children (Fetch list of approved children)
// Dependencies: AuthSession, ApiConstants, ChildTrackingPhotosTab, AppTheme.

/// A page that allows parents to select a child and view their related photo gallery.
class ParentPhotosPage extends StatefulWidget {
  const ParentPhotosPage({super.key});

  @override
  State<ParentPhotosPage> createState() => _ParentPhotosPageState();
}

class _ParentPhotosPageState extends State<ParentPhotosPage> {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  List<Map<String, dynamic>> _children = [];
  String? _selectedChildId;
  bool _isLoading = true;

  // Modern Theme Colors
  static Color get _baseDark => ThemeManager.instance.isLightMode
      ? const Color(0xFFF0F2F5)
      : const Color(0xFF141B2D);
  static Color get _tealAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF009688)
      : const Color(0xFF4CCEAC);
  static Color get _lightText => ThemeManager.instance.isLightMode
      ? const Color(0xFF212529)
      : const Color(0xFFF2F0F0);
  static Color get _mutedText => ThemeManager.instance.isLightMode
      ? const Color(0xFF6C757D)
      : const Color(0xFFA1A4AB);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadChildren());
  }

  String get _normalizedApiBaseUrl => _apiBaseUrl.endsWith('/')
      ? _apiBaseUrl.substring(0, _apiBaseUrl.length - 1)
      : _apiBaseUrl;

  Future<void> _loadChildren() async {
    final session = context.read<AuthSession>();
    final token = session.token;
    final cin = session.cin;
    if (token == null || cin == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$_normalizedApiBaseUrl/api/parents/$cin/children'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final data = body['data'] as List? ?? [];
        setState(() {
          _children = data.cast<Map<String, dynamic>>().where((child) {
            final inscriptions = child['inscriptions'] as List? ?? [];
            if (inscriptions.isEmpty) return false;
            final latestStatus = (inscriptions.last as Map?)?['status'];
            final statusName = latestStatus is Map
                ? latestStatus['name']?.toString().toLowerCase()
                : latestStatus?.toString().toLowerCase();
            return statusName == 'approved';
          }).toList();
          if (_children.isNotEmpty) {
            _selectedChildId = _children.first['id'].toString();
          }
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Container(
      color: _baseDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Photos',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: _lightText,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _selectedChildId = null;
                  _children = [];
                });
                _loadChildren();
              },
              icon: Icon(Icons.refresh_rounded, color: _tealAccent),
              tooltip: 'Actualiser',
            ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_tealAccent),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: _buildChildSelector(),
                  ),
                  Expanded(
                    child: _selectedChildId == null
                        ? _buildEmptyState()
                        : ChildTrackingPhotosTab(
                            childId: int.tryParse(_selectedChildId!) ?? 0,
                            childFirstName: _getSelectedChildName(),
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  String _getSelectedChildName() {
    if (_selectedChildId == null) return '';
    final child = _children.firstWhere(
      (c) => c['id'].toString() == _selectedChildId,
      orElse: () => <String, dynamic>{},
    );
    return child['firstName']?.toString() ?? '';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: ThemeColors.glassBackgroundSubtle,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ThemeColors.glassBorderSubtle),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.child_care_rounded, size: 48, color: _mutedText),
            SizedBox(height: 16),
            Text(
              'Aucun enfant disponible.',
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                color: _mutedText,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildSelector() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: ThemeColors.glassBorderSubtle,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ThemeColors.glassBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedChildId,
              dropdownColor: _baseDark.withValues(alpha: 0.95),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: _tealAccent),
              hint: Text(
                'Choisir un enfant',
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  color: _mutedText,
                ),
              ),
              items: _children
                  .map(
                    (child) => DropdownMenuItem<String>(
                      value: child['id'].toString(),
                      child: Text(
                        '${child['firstName'] ?? ''} ${child['lastName'] ?? ''}'
                            .trim(),
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontWeight: FontWeight.w600,
                          color: _lightText,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedChildId = value;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
