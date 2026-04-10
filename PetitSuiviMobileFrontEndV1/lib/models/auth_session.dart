import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the authenticated user's session state and profile information.
///
/// This class extends [ChangeNotifier] to allow the UI to reactively update
/// when session data (tokens, user details, etc.) changes.
class AuthSession extends ChangeNotifier {
  static const String _tokenKey = 'auth_token';
  static const String _cinKey = 'auth_cin';
  static const String _roleKey = 'auth_role';
  static const String _firstNameKey = 'auth_first_name';
  static const String _lastNameKey = 'auth_last_name';
  static const String _emailKey = 'auth_email';
  static const String _phoneKey = 'auth_phone';
  static const String _addressKey = 'auth_address';
  static const String _birthdateKey = 'auth_birthdate';
  static const String _inscriptionDateKey = 'auth_inscription_date';
  static const String _parentHomeTabKey = 'parent_home_tab';
  static const String _teacherHomeTabKey = 'teacher_home_tab';
  static const String _parentChildRouteKey = 'parent_child_route';

  String? _token;
  int? _cin;
  String? _role;
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _phone;
  String? _address;
  String? _birthdate;
  String? _inscriptionDate;
  int _childrenVersion = 0;
  int _syncVersion = 0;

  /// The authentication token for the current session.
  String? get token => _token;

  /// The National Identity Card (CIN) number of the user.
  int? get cin => _cin;

  /// The role assigned to the user (e.g., 'admin', 'parent', 'teacher').
  String? get role => _role;

  /// The user's first name.
  String? get firstName => _firstName;

  /// The user's last name.
  String? get lastName => _lastName;

  /// The user's email address.
  String? get email => _email;

  /// The user's phone number.
  String? get phone => _phone;

  /// The user's physical address.
  String? get address => _address;

  /// The user's birthdate.
  String? get birthdate => _birthdate;

  /// The date the user joined or inscribed.
  String? get inscriptionDate => _inscriptionDate;

  /// Version counter for tracking local changes to children data.
  int get childrenVersion => _childrenVersion;

  /// Version counter for tracking synchronization status.
  int get syncVersion => _syncVersion;

  /// Returns the full name of the user. Defaults to 'Utilisateur' if both names are empty.
  String get fullName {
    final first = (_firstName ?? '').trim();
    final last = (_lastName ?? '').trim();
    final value = '$first $last'.trim();
    return value.isEmpty ? 'Utilisateur' : value;
  }

  /// Returns true if there is a valid session token present.
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  /// Restores a previously persisted session from local storage.
  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final cin = prefs.getInt(_cinKey);
    final role = prefs.getString(_roleKey);

    if (token == null || token.isEmpty || cin == null || role == null) {
      return false;
    }

    _token = token;
    _cin = cin;
    _role = role;
    _firstName = prefs.getString(_firstNameKey);
    _lastName = prefs.getString(_lastNameKey);
    _email = prefs.getString(_emailKey);
    _phone = prefs.getString(_phoneKey);
    _address = prefs.getString(_addressKey);
    _birthdate = prefs.getString(_birthdateKey);
    _inscriptionDate = prefs.getString(_inscriptionDateKey);
    _childrenVersion = 0;
    _syncVersion = 0;
    notifyListeners();
    return true;
  }

  /// Initializes the session with provided user and authentication data.
  void setSession({
    required String token,
    required int cin,
    required String role,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? birthdate,
    String? inscriptionDate,
  }) {
    _token = token;
    _cin = cin;
    _role = role;
    _firstName = firstName;
    _lastName = lastName;
    _email = email;
    _phone = phone;
    _address = address;
    _birthdate = birthdate;
    _inscriptionDate = inscriptionDate;
    _childrenVersion = 0;
    _syncVersion = 0;
    notifyListeners();
    _persistSession();
  }

  /// Increments the children version to trigger local UI refreshes.
  void bumpChildrenVersion() {
    _childrenVersion++;
    notifyListeners();
  }

  /// Increments the sync version for data synchronization logic.
  void bumpSyncVersion() {
    _syncVersion++;
    notifyListeners();
  }

  /// Updates specific fields in the user's profile while retaining others.
  void updateProfileData({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? birthdate,
    String? inscriptionDate,
  }) {
    _firstName = firstName ?? _firstName;
    _lastName = lastName ?? _lastName;
    _email = email ?? _email;
    _phone = phone ?? _phone;
    _address = address ?? _address;
    _birthdate = birthdate ?? _birthdate;
    _inscriptionDate = inscriptionDate ?? _inscriptionDate;
    notifyListeners();
    _persistSession();
  }

  /// Resets the session state and clears all user information.
  void clear() {
    _token = null;
    _cin = null;
    _role = null;
    _firstName = null;
    _lastName = null;
    _email = null;
    _phone = null;
    _address = null;
    _birthdate = null;
    _inscriptionDate = null;
    _childrenVersion = 0;
    _syncVersion = 0;
    notifyListeners();
    _clearPersistedState();
  }

  /// Persists the currently selected home tab for the given role.
  Future<void> saveHomeTab({
    required int userRole,
    required int tabIndex,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = userRole == 1 ? _teacherHomeTabKey : _parentHomeTabKey;
    await prefs.setInt(key, tabIndex);
  }

  /// Loads the last selected home tab for the given role.
  Future<int?> getSavedHomeTab({required int userRole}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = userRole == 1 ? _teacherHomeTabKey : _parentHomeTabKey;
    return prefs.getInt(key);
  }

  /// Persists the last visited child details route for parents.
  Future<void> saveParentChildRoute({
    required int childId,
    required int tabIndex,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _parentChildRouteKey,
      jsonEncode({
        'childId': childId,
        'tabIndex': tabIndex,
      }),
    );
  }

  /// Loads the last visited child details route for parents.
  Future<Map<String, dynamic>?> getSavedParentChildRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_parentChildRouteKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.cast<String, dynamic>();
      }
    } catch (_) {
      await prefs.remove(_parentChildRouteKey);
    }

    return null;
  }

  /// Clears the saved parent child-details route.
  Future<void> clearParentChildRoute() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_parentChildRouteKey);
  }

  Future<void> _persistSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, _token ?? '');
    if (_cin != null) {
      await prefs.setInt(_cinKey, _cin!);
    } else {
      await prefs.remove(_cinKey);
    }
    await prefs.setString(_roleKey, _role ?? '');
    await _setNullableString(prefs, _firstNameKey, _firstName);
    await _setNullableString(prefs, _lastNameKey, _lastName);
    await _setNullableString(prefs, _emailKey, _email);
    await _setNullableString(prefs, _phoneKey, _phone);
    await _setNullableString(prefs, _addressKey, _address);
    await _setNullableString(prefs, _birthdateKey, _birthdate);
    await _setNullableString(prefs, _inscriptionDateKey, _inscriptionDate);
  }

  Future<void> _clearPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_cinKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_firstNameKey);
    await prefs.remove(_lastNameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_addressKey);
    await prefs.remove(_birthdateKey);
    await prefs.remove(_inscriptionDateKey);
    await prefs.remove(_parentHomeTabKey);
    await prefs.remove(_teacherHomeTabKey);
    await prefs.remove(_parentChildRouteKey);
  }

  Future<void> _setNullableString(
    SharedPreferences prefs,
    String key,
    String? value,
  ) async {
    if (value == null || value.isEmpty) {
      await prefs.remove(key);
      return;
    }
    await prefs.setString(key, value);
  }
}
