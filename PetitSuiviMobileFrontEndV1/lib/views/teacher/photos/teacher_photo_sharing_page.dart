/// teacher_photo_sharing_page.dart
///
/// Multi-step form allowing teachers to capture or pick photos from
/// the gallery and share them with specific children's parents.
/// Steps: **Select Class → Select Children → Pick Photo → Send**.
///
/// ## State Management
/// - [_TeacherPhotoSharingPageState] manages classes, children, photo path,
///   expiration setting, and recent photo history.
/// - Photo operations are delegated to [PhotoService].
///
/// ## Backend API Endpoints
///
/// ### GET /api/teachers/{cin}/classes
/// Fetches teacher's assigned classes for the class dropdown.
/// - **Headers:** `Authorization: Bearer {token}`
/// - **Response 200:** `{ "data": [ { "id": 1, "name": "Moyenne Section B" } ] }`
///
/// ### GET /api/classes/{classId}/students
/// Fetches the children enrolled in a specific class.
/// - **Headers:** `Authorization: Bearer {token}`
/// - **Response 200:**
/// ```json
/// {
///   "data": {
///     "students": [
///       { "id": 8, "firstName": "Sami", "lastName": "Ben Ali" }
///     ]
///   }
/// }
/// ```
///
/// ### POST /api/photos/upload (via [PhotoService])
/// Uploads a photo and associates it with selected children.
/// - **Body (multipart):** `photo` (file), `teacher_id`, `child_ids[]`, `expires_in_days`
/// - **Response 201:** `{ "message": "Photo uploaded." }`
///
/// ### GET /api/teachers/{cin}/photos (via [PhotoService])
/// Retrieves the teacher's recently shared photos with recipient info.
/// - **Response 200:** `{ "data": [ { "id": 1, "created_at": "...", "expired": false, "recipients": [...] } ] }`
///
/// ### DELETE /api/photos/{id} (via [PhotoService])
/// Deletes a previously shared photo.
/// - **Response 200:** `{ "message": "Photo deleted." }`
///
/// ## Dependencies
/// [PhotoService], [AuthSession], [TeacherTheme], [ThemeColors],
/// [ApiConstants], [ThemeManager], [ImagePicker].
library teacher_photo_sharing_page;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/services/photo_service.dart';
import 'package:newv/theme_colors.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/utils/api_constants.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:provider/provider.dart';

class TeacherPhotoSharingPage extends StatefulWidget {
  const TeacherPhotoSharingPage({super.key});

  @override
  State<TeacherPhotoSharingPage> createState() =>
      _TeacherPhotoSharingPageState();
}

class _TeacherPhotoSharingPageState extends State<TeacherPhotoSharingPage> {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  final PhotoService _photoService = PhotoService();

  List<Map<String, dynamic>> _classes = [];
  String? _selectedClassId;
  List<Map<String, dynamic>> _classChildren = [];
  Set<int> _selectedChildIds = {};

  String? _pickedImagePath;
  int _selectedExpirationDays = 30;

  List<dynamic> _recentPhotos = [];

  bool _isLoadingClasses = true;
  bool _isLoadingChildren = false;
  bool _isSending = false;
  bool _isLoadingRecent = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClasses();
      _loadRecentPhotos();
    });
  }

  String get _normalizedApiBaseUrl => _apiBaseUrl.endsWith('/')
      ? _apiBaseUrl.substring(0, _apiBaseUrl.length - 1)
      : _apiBaseUrl;

  Map<String, String> _authHeaders(String token) => {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Map<String, dynamic> _normalizeChild(Map<String, dynamic> rawChild) {
    return {
      'id': rawChild['id'],
      'firstName': rawChild['firstName'] ?? rawChild['first_name'] ?? '',
      'lastName': rawChild['lastName'] ?? rawChild['last_name'] ?? '',
      'birthdate': rawChild['birthdate'],
    };
  }

  Future<void> _loadClasses({bool isRefresh = false}) async {
    final session = context.read<AuthSession>();
    final token = session.token;
    final cin = session.cin;
    if (token == null || cin == null) return;

    if (!isRefresh) {
      setState(() {
        _isLoadingClasses = true;
        _error = null;
      });
    } else {
      setState(() {
        _error = null;
      });
    }

    try {
      final response = await http.get(
        Uri.parse('$_normalizedApiBaseUrl/api/teachers/$cin/classes'),
        headers: _authHeaders(token),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final data = body['data'] as List? ?? [];
        setState(() {
          _classes = data.cast<Map<String, dynamic>>();
          _isLoadingClasses = false;
          if (_classes.isNotEmpty && _selectedClassId == null) {
            _selectedClassId = _classes.first['id'].toString();
            _loadChildrenForClass(_selectedClassId!);
          }
        });
      } else {
        setState(() {
          _isLoadingClasses = false;
          _error = 'Erreur lors du chargement des classes.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingClasses = false;
        _error = 'Erreur réseau.';
      });
    }
  }

  Future<void> _loadChildrenForClass(String classId) async {
    final session = context.read<AuthSession>();
    final token = session.token;
    if (token == null) return;

    setState(() {
      _isLoadingChildren = true;
      _classChildren = [];
      _selectedChildIds = {};
    });

    try {
      final response = await http.get(
        Uri.parse('$_normalizedApiBaseUrl/api/classes/$classId/students'),
        headers: _authHeaders(token),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final dataMap = body['data'] as Map<String, dynamic>? ?? {};
        final students = dataMap['students'] as List? ?? [];
        final normalizedChildren = students
            .whereType<Map>()
            .map((child) => _normalizeChild(child.cast<String, dynamic>()))
            .toList();
        setState(() {
          _classChildren = normalizedChildren;
          _selectedChildIds = _classChildren
              .map<int>((c) => int.tryParse(c['id'].toString()) ?? 0)
              .where((id) => id > 0)
              .toSet();
          _isLoadingChildren = false;
        });
      } else {
        setState(() => _isLoadingChildren = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingChildren = false);
    }
  }

  Future<void> _loadRecentPhotos({bool isRefresh = false}) async {
    final session = context.read<AuthSession>();
    final cin = session.cin;
    final token = session.token;
    if (cin == null || token == null) return;

    if (!isRefresh) {
      setState(() => _isLoadingRecent = true);
    }

    try {
      final photos = await _photoService.getTeacherPhotos(cin, token);
      if (!mounted) return;
      setState(() {
        _recentPhotos = photos;
        _isLoadingRecent = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingRecent = false);
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _loadClasses(isRefresh: true),
      _loadRecentPhotos(isRefresh: true),
    ]);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (file == null) return;
    setState(() {
      _pickedImagePath = file.path;
    });
  }

  Future<void> _sendPhoto() async {
    if (_pickedImagePath == null) {
      _showSnack('Veuillez sélectionner une photo.');
      return;
    }
    if (_selectedChildIds.isEmpty) {
      _showSnack('Sélectionnez au moins un enfant.');
      return;
    }

    final session = context.read<AuthSession>();
    final cin = session.cin;
    final token = session.token;
    if (cin == null || token == null) return;

    setState(() => _isSending = true);

    try {
      await _photoService.uploadPhoto(
        photo: File(_pickedImagePath!),
        teacherId: cin,
        childIds: _selectedChildIds.toList(),
        token: token,
        expiresInDays: _selectedExpirationDays,
      );

      if (!mounted) return;
      setState(() {
        _pickedImagePath = null;
        _isSending = false;
      });
      _showSnack(
        'Photo envoyée à ${_selectedChildIds.length} enfant(s).',
        isSuccess: true,
      );
      _loadRecentPhotos();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);
      _showSnack('Erreur: ${e.toString()}');
    }
  }

  Future<void> _deletePhoto(int photoId) async {
    final session = context.read<AuthSession>();
    final token = session.token;
    if (token == null) return;

    try {
      await _photoService.deletePhoto(photoId, token);
      if (!mounted) return;
      _showSnack('Photo supprimée.', isSuccess: true);
      _loadRecentPhotos();
    } catch (_) {
      _showSnack('Erreur lors de la suppression.');
    }
  }

  void _showSnack(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
      ),
    );
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedChildIds.length == _classChildren.length) {
        _selectedChildIds = {};
      } else {
        _selectedChildIds = _classChildren
            .map<int>((c) => int.tryParse(c['id'].toString()) ?? 0)
            .where((id) => id > 0)
            .toSet();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Scaffold(
      backgroundColor: TeacherTheme.baseDark,
      appBar: AppBar(
        title: Text(
          'Partage Photos Parents',
          style: TextStyle(
            color: TeacherTheme.lightText,
            fontFamily: TeacherTheme.fontName,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios, color: TeacherTheme.lightText),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: TeacherTheme.tealAccent),
            onPressed: _refreshData,
            tooltip: 'Rafraîchir les partages récents',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: TeacherTheme.tealAccent,
        backgroundColor: TeacherTheme.surfaceDark,
        onRefresh: _refreshData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm', 'fr');

    return _isLoadingClasses
        ? Center(
            child: CircularProgressIndicator(color: TeacherTheme.tealAccent),
          )
        : _error != null
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _error!,
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontFamily: TeacherTheme.fontName,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loadClasses,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TeacherTheme.tealAccent,
                    foregroundColor: TeacherTheme.baseDark,
                  ),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          )
        : ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _sectionCard(
                title: '1) Classe',
                child: DropdownButtonFormField<String>(
                  value: _selectedClassId,
                  dropdownColor: TeacherTheme.cardDark,
                  style: TextStyle(
                    color: TeacherTheme.lightText,
                    fontFamily: TeacherTheme.fontName,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Classe',
                    labelStyle: TextStyle(color: TeacherTheme.mutedText),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: ThemeColors.glassBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: TeacherTheme.tealAccent),
                    ),
                  ),
                  items: _classes
                      .map(
                        (c) => DropdownMenuItem<String>(
                          value: c['id'].toString(),
                          child: Text(
                            c['name']?.toString() ?? 'Classe #${c['id']}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedClassId = value);
                    _loadChildrenForClass(value);
                  },
                ),
              ),
              const SizedBox(height: 12),

              _sectionCard(
                title: '2) Enfants destinataires',
                child: _isLoadingChildren
                    ? Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: TeacherTheme.tealAccent,
                          ),
                        ),
                      )
                    : _classChildren.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Aucun enfant dans cette classe.',
                          style: TextStyle(color: TeacherTheme.mutedText),
                        ),
                      )
                    : Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_selectedChildIds.length}/${_classChildren.length} sélectionnés',
                                style: TextStyle(
                                  fontFamily: TeacherTheme.fontName,
                                  fontSize: 13,
                                  color: TeacherTheme.mutedText,
                                ),
                              ),
                              TextButton(
                                onPressed: _toggleSelectAll,
                                child: Text(
                                  _selectedChildIds.length ==
                                          _classChildren.length
                                      ? 'Désélectionner tout'
                                      : 'Sélectionner tout',
                                  style: TextStyle(
                                    color: TeacherTheme.tealAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ..._classChildren.map((child) {
                            final childId =
                                int.tryParse(child['id'].toString()) ?? 0;
                            final firstName =
                                child['firstName']?.toString() ?? '';
                            final lastName =
                                child['lastName']?.toString() ?? '';
                            return CheckboxListTile(
                              dense: true,
                              checkColor: TeacherTheme.baseDark,
                              activeColor: TeacherTheme.tealAccent,
                              value: _selectedChildIds.contains(childId),
                              title: Text(
                                '$firstName $lastName'.trim(),
                                style: TextStyle(
                                  fontFamily: TeacherTheme.fontName,
                                  color: TeacherTheme.lightText,
                                ),
                              ),
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedChildIds.add(childId);
                                  } else {
                                    _selectedChildIds.remove(childId);
                                  }
                                });
                              },
                            );
                          }),
                        ],
                      ),
              ),
              const SizedBox(height: 12),

              _sectionCard(
                title: '3) Photo',
                child: Column(
                  children: [
                    if (_pickedImagePath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_pickedImagePath!),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: ThemeColors.glassBorderSubtle,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ThemeColors.glassBorder),
                        ),
                        child: Center(
                          child: Text(
                            'Aucune photo sélectionnée',
                            style: TextStyle(color: TeacherTheme.mutedText),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TeacherTheme.tealAccent,
                        side: BorderSide(color: TeacherTheme.tealAccent),
                      ),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Choisir une photo'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedExpirationDays,
                      dropdownColor: TeacherTheme.cardDark,
                      style: TextStyle(
                        color: TeacherTheme.lightText,
                        fontFamily: TeacherTheme.fontName,
                      ),
                      decoration: InputDecoration(
                        labelText: "Durée d'expiration",
                        labelStyle: TextStyle(color: TeacherTheme.mutedText),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ThemeColors.glassBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: TeacherTheme.tealAccent,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 3, child: Text('3 Jours')),
                        DropdownMenuItem(value: 7, child: Text('1 Semaine')),
                        DropdownMenuItem(value: 30, child: Text('1 Mois')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedExpirationDays = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSending ? null : _sendPhoto,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TeacherTheme.tealAccent,
                          foregroundColor: TeacherTheme.baseDark,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: _isSending
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: TeacherTheme.baseDark,
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(_isSending ? 'Envoi...' : 'Envoyer'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Text(
                'Partages récents',
                style: TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: TeacherTheme.lightText,
                ),
              ),
              const SizedBox(height: 8),
              if (_isLoadingRecent)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      color: TeacherTheme.tealAccent,
                    ),
                  ),
                )
              else if (_recentPhotos.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: TeacherTheme.surfaceCard(borderRadius: 12),
                  child: Text(
                    'Aucun partage pour le moment.',
                    style: TextStyle(color: TeacherTheme.mutedText),
                  ),
                )
              else
                ..._recentPhotos.take(10).map((photo) {
                  final photoId = photo['id'];
                  final createdAt = DateTime.tryParse(
                    photo['created_at']?.toString() ?? '',
                  );
                  final recipients = photo['recipients'] as List? ?? [];
                  final childNames = recipients
                      .map((r) {
                        final child = r['child'];
                        if (child == null) return '';
                        return '${child['firstName'] ?? ''} ${child['lastName'] ?? ''}'
                            .trim();
                      })
                      .where((n) => n.isNotEmpty)
                      .toList();
                  final expired = photo['expired'] == true;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: TeacherTheme.surfaceCard(borderRadius: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: expired
                            ? Colors.grey.withValues(alpha: 0.15)
                            : TeacherTheme.indigoAccent.withValues(alpha: 0.15),
                        child: Icon(
                          expired ? Icons.timer_off : Icons.photo,
                          color: expired
                              ? TeacherTheme.mutedText
                              : TeacherTheme.indigoAccent,
                        ),
                      ),
                      title: Text(
                        '${childNames.length} enfant(s)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: TeacherTheme.fontName,
                          color: TeacherTheme.lightText,
                        ),
                      ),
                      subtitle: Text(
                        '${childNames.take(3).join(', ')}${childNames.length > 3 ? '...' : ''}\n${createdAt != null ? dateFormatter.format(createdAt) : ''}${expired ? ' • Expirée' : ''}',
                        style: TextStyle(
                          fontFamily: TeacherTheme.fontName,
                          fontSize: 12,
                          color: TeacherTheme.mutedText,
                        ),
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent.withValues(alpha: 0.8),
                          size: 20,
                        ),
                        onPressed: () => _deletePhoto(photoId),
                        tooltip: 'Supprimer',
                      ),
                    ),
                  );
                }),
            ],
          );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: TeacherTheme.surfaceCard(borderRadius: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: TeacherTheme.fontName,
              fontWeight: FontWeight.bold,
              color: TeacherTheme.lightText,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
