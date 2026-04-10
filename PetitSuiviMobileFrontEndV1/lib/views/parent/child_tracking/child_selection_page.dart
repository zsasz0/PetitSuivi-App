import 'package:newv/utils/api_constants.dart';
import 'dart:convert';
import 'dart:ui';

import 'package:newv/app_theme.dart';
import 'package:newv/l10n/app_localizations.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/services/pickup_notification_service.dart';
import 'package:newv/utils/unauthorized_handler.dart';
import 'package:newv/views/parent/child_tracking/child_details_page.dart';
import 'package:newv/views/parent/child_tracking/re_registration_page.dart';
import 'package:flutter/material.dart';
import 'package:newv/models/child.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';

// File: child_selection_page.dart
// Purpose: Parent's main screen for selecting a child to manage or notifying pickup.
// Usage: First tab for Parents in CombinedHomeScreen.
// API Usage:
//   - GET /api/parameters (Check if inscriptions are open)
//   - GET /api/parents/{cin}/children (Load parent's children)
//   - POST /api/notifications/pickup (Via PickupNotificationService)
// Dependencies: AuthSession, PickupNotificationService, ChildDetailsPage, ReRegistrationPage.

/// A page that lists all children associated with the logged-in parent.
class ChildSelectionPage extends StatefulWidget {
  const ChildSelectionPage({super.key});

  @override
  State<ChildSelectionPage> createState() => _ChildSelectionPageState();
}

class _ChildSelectionPageState extends State<ChildSelectionPage> {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  List<Child> _children = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _lastSeenChildrenVersion = -1;
  int _lastSeenSyncVersion = -1;
  final Set<String> _pickupNotifiedChildKeys = <String>{};
  bool _inscriptionsOpen = true; // gate for registration
  bool _didAttemptRouteRestore = false;

  // Modern Theme Colors
  static Color get _baseDark => ThemeManager.instance.isLightMode
      ? const Color(0xFFF0F2F5)
      : const Color(0xFF141B2D);
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

  @override
  void initState() {
    super.initState();
    _checkInscriptionsOpen();
  }

  Future<void> _checkInscriptionsOpen() async {
    try {
      final uri = Uri.parse('$_apiBaseUrl/api/parameters');
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final params = data is List ? data : (data['data'] ?? []);
        for (final p in params) {
          if (p['name'] == 'inscriptions_open') {
            if (mounted) {
              setState(() {
                _inscriptionsOpen = p['value'] == 'true' || p['value'] == '1';
              });
            }
            break;
          }
        }
      }
    } catch (_) {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = context.watch<AuthSession>();
    final childrenVersion = session.childrenVersion;
    final syncVersion = session.syncVersion;
    final shouldReload =
        childrenVersion != _lastSeenChildrenVersion ||
        syncVersion != _lastSeenSyncVersion;

    if (shouldReload) {
      _lastSeenChildrenVersion = childrenVersion;
      _lastSeenSyncVersion = syncVersion;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadChildren());
    }
  }

  Future<void> _loadChildren() async {
    if (!mounted) return;

    final session = context.read<AuthSession>();
    final token = session.token;
    final parentCin = session.cin;

    if (token == null || token.isEmpty || parentCin == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Session parent introuvable. Reconnectez-vous.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final uri = Uri.parse('$_apiBaseUrl/api/parents/$parentCin/children');

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
      ))
        return;

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final rawChildren = body['data'];
        if (rawChildren is List) {
          final parsed = rawChildren.whereType<Map>().map((item) {
            final map = item.cast<String, dynamic>();
            return Child(
              firstName: (map['firstName'] ?? '').toString(),
              lastName: (map['lastName'] ?? '').toString(),
              birthDate: (map['birthdate'] ?? '').toString(),
              description: '',
              medicalRecord: null,
              oldSchool: null,
              extraData: {
                'id': map['id'],
                'inscriptions': map['inscriptions'],
                'classes': map['classes'],
              },
            );
          }).toList();

          setState(() {
            _children = parsed;
            _isLoading = false;
          });
          _restoreSavedChildRoute(parsed);
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Format de réponse invalide.';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              body['message']?.toString() ??
              'Impossible de charger les enfants.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur réseau. Vérifiez l\'API Laravel.';
      });
    }
  }

  Future<void> _restoreSavedChildRoute(List<Child> children) async {
    if (_didAttemptRouteRestore || children.isEmpty) return;
    _didAttemptRouteRestore = true;

    final savedRoute = await context
        .read<AuthSession>()
        .getSavedParentChildRoute();
    if (!mounted || savedRoute == null) return;

    final childId = savedRoute['childId'];
    final savedTabIndex = savedRoute['tabIndex'];
    final resolvedChildId = childId is int
        ? childId
        : int.tryParse(childId?.toString() ?? '');
    final resolvedTabIndex = savedTabIndex is int
        ? savedTabIndex
        : int.tryParse(savedTabIndex?.toString() ?? '') ?? 0;

    if (resolvedChildId == null) {
      await context.read<AuthSession>().clearParentChildRoute();
      return;
    }

    Child? targetChild;
    for (final child in children) {
      final rawId = child.extraData['id'];
      final currentId = rawId is int
          ? rawId
          : int.tryParse(rawId?.toString() ?? '');
      if (currentId == resolvedChildId) {
        targetChild = child;
        break;
      }
    }

    if (targetChild == null || !_isChildApproved(targetChild)) {
      await context.read<AuthSession>().clearParentChildRoute();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _openChildDetails(targetChild!, initialTabIndex: resolvedTabIndex);
    });
  }

  Future<void> _openChildDetails(Child child, {int initialTabIndex = 0}) async {
    final childIdRaw = child.extraData['id'];
    final childId = childIdRaw is int
        ? childIdRaw
        : int.tryParse(childIdRaw?.toString() ?? '');
    if (childId != null) {
      await context.read<AuthSession>().saveParentChildRoute(
        childId: childId,
        tabIndex: initialTabIndex,
      );
    }

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildDetailsPage(
          childData: child.toMap(),
          initialTabIndex: initialTabIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: _baseDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            l10n.selectChild,
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
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: 100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.whoToManage,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: _mutedText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_tealAccent),
                    ),
                  ),
                )
              else if (_errorMessage != null)
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          color: Colors.red.shade300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadChildren,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _tealAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Réessayer',
                        style: TextStyle(
                          color: _baseDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              else if (_children.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: ThemeColors.glassBackgroundSubtle,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: ThemeColors.glassBorder),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.child_care_outlined,
                        size: 64,
                        color: _mutedText,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Aucun enfant trouvé pour ce parent.',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          color: _mutedText,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                _buildChildrenFeed(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildrenFeed(AppLocalizations l10n) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _children.length,
      separatorBuilder: (context, index) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final child = _children[index];
        return _buildChildTile(context, child, l10n);
      },
    );
  }

  Widget _buildChildTile(
    BuildContext context,
    Child child,
    AppLocalizations l10n,
  ) {
    final canOpenProfile = _isChildApproved(child);
    final needsReReg = _needsReRegistration(child);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 200, child: _buildChildCard(context, child, l10n)),
        const SizedBox(height: 16),
        if (needsReReg)
          if (_inscriptionsOpen)
            _buildReRegistrationButton(child)
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'Les inscriptions sont actuellement fermées.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  color: Colors.orange,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
        else if (canOpenProfile)
          _buildPickupNotifierButton(child)
        else
          _buildPickupPendingHint(),
      ],
    );
  }

  Widget _buildChildCard(
    BuildContext context,
    Child child,
    AppLocalizations l10n,
  ) {
    final canOpenProfile = _isChildApproved(child);
    final needsReReg = _needsReRegistration(child);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (needsReReg) {
                if (!_inscriptionsOpen) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Les inscriptions sont actuellement fermées.',
                      ),
                      backgroundColor: Colors.orange.shade800,
                    ),
                  );
                  return;
                }
                // Navigate to re-registration page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReRegistrationPage(
                      childId: (child.extraData['id'] as num?)?.toInt() ?? 0,
                      firstName: child.firstName,
                      lastName: child.lastName,
                      birthDate: child.birthDate,
                    ),
                  ),
                );
                return;
              }

              if (!canOpenProfile) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Profil indisponible: inscription en attente d\'approbation.',
                    ),
                    backgroundColor: Colors.orange.shade800,
                  ),
                );
                return;
              }

              _openChildDetails(child);
            },
            child: Container(
              decoration: BoxDecoration(
                color: canOpenProfile
                    ? ThemeColors.glassBorder
                    : ThemeColors.glassBackgroundSubtle,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: canOpenProfile
                      ? ThemeColors.glassBorderStrong
                      : ThemeColors.glassBorderSubtle,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: canOpenProfile
                          ? _tealAccent.withValues(alpha: 0.2)
                          : ThemeColors.glassBackgroundSubtle,
                      border: Border.all(
                        color: canOpenProfile
                            ? _tealAccent
                            : ThemeColors.glassBorder,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.face_retouching_natural_rounded,
                      size: 40,
                      color: needsReReg
                          ? _indigoAccent
                          : (canOpenProfile ? _tealAccent : _mutedText),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    child.firstName,
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: canOpenProfile ? _lightText : _mutedText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_calculateAge(child.birthDate)} ${l10n.yearsOld}',
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontSize: 14,
                      color: canOpenProfile
                          ? _mutedText
                          : _mutedText.withValues(alpha: 0.5),
                    ),
                  ),
                  if (canOpenProfile &&
                      _getCurrentClassName(child) != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Classe: ${_getCurrentClassName(child)}',
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: 14,
                        color: _tealAccent.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (needsReReg) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _indigoAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _indigoAccent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Nouvelle année — Inscription requise',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _indigoAccent,
                        ),
                      ),
                    ),
                  ] else if (!canOpenProfile) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Text(
                        'En attente',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPickupNotifierButton(Child child) {
    final alreadyNotified = _isPickupNotified(child);

    if (alreadyNotified) {
      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _tealAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _tealAccent.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 22,
              color: _tealAccent,
            ),
            const SizedBox(width: 8),
            Text(
              'Récupération notifiée',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _tealAccent,
              ),
            ),
          ],
        ),
      );
    }

    return OutlinedButton(
      onPressed: () => _handlePickupNotification(child),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: ThemeColors.glassBackgroundSubtle,
        side: BorderSide(color: _indigoAccent.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_active_outlined,
            size: 22,
            color: _indigoAccent,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Notifier la récupération',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _indigoAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReRegistrationButton(Child child) {
    return ElevatedButton(
      onPressed: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => ReRegistrationPage(
              childId: (child.extraData['id'] as num?)?.toInt() ?? 0,
              firstName: child.firstName,
              lastName: child.lastName,
              birthDate: child.birthDate,
            ),
          ),
        );
        if (result == true && mounted) {
          _loadChildren();
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: _indigoAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 22),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'Inscrire pour la nouvelle année',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupPendingHint() {
    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ThemeColors.glassBackgroundSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.glassBorderSubtle),
      ),
      child: Text(
        'Action disponible après approbation',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: AppTheme.fontName,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: _mutedText,
        ),
      ),
    );
  }

  Future<void> _handlePickupNotification(Child child) async {
    int selectedDuration = 15;
    final int? durationMinutes = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _baseDark,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: ThemeColors.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _indigoAccent.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    Icons.directions_car_filled_outlined,
                    size: 32,
                    color: _indigoAccent,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Récupération de ${child.firstName}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _lightText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Dans combien de temps serez-vous là ?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontSize: 14,
                    color: _mutedText,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  '$selectedDuration min',
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: _tealAccent,
                  ),
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _tealAccent,
                    inactiveTrackColor: ThemeColors.glassBorderStrong,
                    thumbColor: _tealAccent,
                    overlayColor: _tealAccent.withValues(alpha: 0.15),
                    trackHeight: 8,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 24,
                    ),
                  ),
                  child: Slider(
                    value: selectedDuration.toDouble(),
                    min: 5,
                    max: 60,
                    divisions: 11,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedDuration = (value / 5).round() * 5;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '5m',
                        style: TextStyle(
                          fontSize: 12,
                          color: _mutedText.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        '60m',
                        style: TextStyle(
                          fontSize: 12,
                          color: _mutedText.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: ThemeColors.glassBorderStrong,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontWeight: FontWeight.bold,
                            color: _mutedText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, selectedDuration),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _tealAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Confirmer',
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (durationMinutes == null) return;
    if (!mounted) return;

    // ── Actually call the backend API ──
    final session = context.read<AuthSession>();
    final token = session.token;
    final childId = child.extraData['id'];

    if (token == null || token.isEmpty || childId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Erreur : données de session ou enfant manquantes.',
          ),
          backgroundColor: Colors.red.shade800,
        ),
      );
      return;
    }

    try {
      final service = PickupNotificationService();
      await service.sendNotification(
        childId is int ? childId : int.parse(childId.toString()),
        token,
        durationMinutes: durationMinutes,
      );

      if (!mounted) return;
      setState(() {
        _pickupNotifiedChildKeys.add(_childKey(child));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Enseignants informés ! Veuillez arriver dans $durationMinutes minutes pour récupérer ${child.firstName}.',
          ),
          backgroundColor: Colors.green.shade800,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi: $e'),
          backgroundColor: Colors.red.shade800,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  bool _isPickupNotified(Child child) {
    return _pickupNotifiedChildKeys.contains(_childKey(child));
  }

  String _childKey(Child child) {
    final id = child.extraData['id']?.toString();
    if (id != null && id.isNotEmpty) {
      return 'id:$id';
    }
    return '${child.firstName}|${child.lastName}|${child.birthDate}';
  }

  bool _needsReRegistration(Child child) {
    final inscriptions = child.extraData['inscriptions'];
    if (inscriptions is! List || inscriptions.isEmpty) return false;
    final latest = inscriptions.last;
    if (latest is! Map) return false;
    final statusObj = latest['status'];
    String status = '';
    if (statusObj is Map) {
      status = statusObj['name']?.toString().toLowerCase() ?? '';
    } else {
      status = statusObj?.toString().toLowerCase() ?? '';
    }
    return status == 'inscription_requise';
  }

  bool _isChildApproved(Child child) {
    final inscriptions = child.extraData['inscriptions'];
    if (inscriptions is! List || inscriptions.isEmpty) {
      return false;
    }

    final latest = inscriptions.last;
    if (latest is! Map) {
      return false;
    }

    final statusObj = latest['status'];
    String status = '';

    if (statusObj is Map) {
      status = statusObj['name']?.toString().toLowerCase() ?? '';
    } else {
      status = statusObj?.toString().toLowerCase() ?? '';
    }

    return status == 'approved';
  }

  int _calculateAge(String birthDateString) {
    try {
      DateTime birthDate = DateTime.parse(birthDateString);
      DateTime today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  String? _getCurrentClassName(Child child) {
    final classes = child.extraData['classes'];
    if (classes is List && classes.isNotEmpty) {
      final latestClass = classes.last;
      if (latestClass is Map && latestClass.containsKey('name')) {
        return latestClass['name']?.toString();
      }
    }
    return null;
  }
}
