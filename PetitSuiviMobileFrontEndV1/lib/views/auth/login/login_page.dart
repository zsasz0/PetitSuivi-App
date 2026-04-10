import 'dart:convert';
import 'package:newv/app_theme.dart';
import 'package:newv/views/home/combined_home_screen.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/views/auth/register/register_page.dart';
import 'package:newv/views/parent/waitingForApproval/pages/waiting_approval_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:newv/utils/api_constants.dart';
import 'package:newv/theme_manager.dart';
import 'components/glass_text_field.dart';
import 'components/login_background_painter.dart';
import 'components/login_button.dart';
import 'components/glass_role_selector.dart';
import 'components/fade_slide_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================================================
/// FILE: login_page.dart
/// PURPOSE: Primary authentication screen for mobile users (Parents & Teachers).
///
/// OVERVIEW:
/// This page renders a glassmorphism-styled login UI with role selection.
/// It interacts directly with the Laravel backend to authenticate users and
/// check global parameter states (like registration availability).
///
/// BACKEND API USAGE:
/// - [POST] /api/login/teacher
///   Expected Payload: { "email": "...", "password": "..." }
///   Expected Response: token string + user object containing cin, role details.
///
/// - [POST] /api/login/parent
///   Expected Payload: { "email": "...", "password": "..." }
///   Expected Response: token string + user object; handles "requires_admin_approval" flag.
///
/// - [GET] /api/parameters
///   Fetches system-wide rules, specifically checking "inscriptions_open"
///   to conditionally render the "Register" navigation link.
/// ============================================================================

/// The primary authentication widget for both parents and teachers.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// The state for [LoginPage].
/// Note: All state variables, themes, metrics, and lifecycle hooks are placed
/// at the TOP for maximum readability and organization.
class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  /// Base API URL constant.
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  // ---------------------------------------------------------------------------
  // STATE VARIABLES
  // ---------------------------------------------------------------------------

  /// Controls the text value for the email address input.
  final TextEditingController _emailController = TextEditingController();

  /// Controls the text value for the password input.
  final TextEditingController _passwordController = TextEditingController();

  /// Tracks if a login request is actively being processed over the network.
  bool _isLoading = false;

  /// Keeps track of the selected user role. (1 = teacher, 2 = parent)
  int _selectedRole = 2;

  /// Evaluates whether the system allows new registrations (inscriptions).
  bool _inscriptionsOpen = true;

  // ---------------------------------------------------------------------------
  // THEME & STYLES (Extracted from UI build)
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // ANIMATION CONTROLLERS
  // ---------------------------------------------------------------------------

  late AnimationController _bgAnimController;
  late AnimationController _staggerController;

  // ---------------------------------------------------------------------------
  // LIFECYCLE HOOKS (INIT / DISPOSE)
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _bgAnimController = AnimationController(
        vsync: this, duration: const Duration(seconds: 20))
      ..repeat();

    _staggerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();

    _loadSavedEmail();
    _checkInscriptionsOpen();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resumePersistedSessionIfAvailable();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bgAnimController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // API & LOGIC METHODS
  // ---------------------------------------------------------------------------

  /// Attempts to automatically log the user in if a persisted session exists.
  Future<void> _resumePersistedSessionIfAvailable() async {
    final session = context.read<AuthSession>();
    if (!session.isLoggedIn) return;

    if (session.role == 'teacher') {
      _openTeacherHome();
    } else if (session.role == 'parent') {
      _openParentHome();
    }
  }

  /// Restores the last used email address using SharedPreferences to reduce repetitive typing.
  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    if (savedEmail != null && savedEmail.isNotEmpty && mounted) {
      _emailController.text = savedEmail;
    }
  }

  /// Queries the API to check if `inscriptions_open` parameter is active.
  /// Modifies local state to show or hide the registration option.
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
    } catch (_) {
      // Gracefully ignore error and default to true (or retain initial state)
    }
  }

  /// Validates input and fires the POST request for user authentication.
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Email et mot de passe sont obligatoires.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final endpoint = _selectedRole == 1 ? '/api/login/teacher' : '/api/login/parent';
    final uri = Uri.parse('$_apiBaseUrl$endpoint');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      final Map<String, dynamic> data = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final user = data['user'] as Map<String, dynamic>?;
        final role = user?['role'] as Map<String, dynamic>?;
        final roleName = (role?['name'] as String?)?.toLowerCase();
        final token = data['token']?.toString();
        
        final cinRaw = user?['cin'];
        final cin = cinRaw is int ? cinRaw : int.tryParse(cinRaw?.toString() ?? '');

        if (token == null || token.isEmpty || cin == null || roleName == null) {
          _showError('Réponse API invalide.');
          return;
        }

        context.read<AuthSession>().setSession(
          token: token,
          cin: cin,
          role: roleName,
          firstName: user?['firstName']?.toString(),
          lastName: user?['lastName']?.toString(),
          email: user?['email']?.toString(),
          phone: user?['phone']?.toString(),
          address: (user?['adresse'] ?? user?['address'])?.toString(),
          birthdate: user?['birthdate']?.toString(),
          inscriptionDate: (user?['inscriptiondate'] ??
                  user?['inscription_date'] ??
                  user?['inscriptionDate'])
              ?.toString(),
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', email);

        if (roleName == 'teacher') {
          _openTeacherHome();
        } else if (roleName == 'parent') {
          _openParentHome();
        } else {
          _showError('Role utilisateur invalide.');
        }
      } else {
        // Handle failed login constraints
        final requiresAdminApproval = data['requires_admin_approval'] == true;
        if (requiresAdminApproval && _selectedRole == 2) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const WaitingApprovalPage(),
            ),
            (route) => false,
          );
          return;
        }

        final message = data['message']?.toString() ?? 'Échec de connexion.';
        _showError(message);
      }
    } catch (_) {
      if (!mounted) return;
      _showError('Impossible de joindre le serveur. Vérifiez l\'URL API.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openTeacherHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CombinedHomeScreen(userRole: 1)),
    );
  }

  void _openParentHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CombinedHomeScreen(userRole: 2)),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGET BUILD & SUB-COMPONENTS
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    
    return Scaffold(
      backgroundColor: _baseDark,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  _buildHeaderInfo(),
                  const SizedBox(height: 48),
                  _buildTextInputs(),
                  const SizedBox(height: 24),
                  _buildRoleSelector(),
                  const SizedBox(height: 32),
                  _buildSubmitAction(),
                  const SizedBox(height: 24),
                  _buildRegisterLink(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the animated colored background utilizing the custom painter.
  Widget _buildAnimatedBackground() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _bgAnimController,
        builder: (context, child) {
          return CustomPaint(
            painter: LoginBackgroundPainter(_bgAnimController.value),
          );
        },
      ),
    );
  }

  /// Builds the Application Logo and Welcome Texts.
  Widget _buildHeaderInfo() {
    return Column(
      children: [
        FadeSlideTransition(
          controller: _staggerController,
          delay: 0.1,
          child: Center(
            child: Image.asset(
              'assets/images/appImage.png',
              width: 104,
              height: 104,
            ),
          ),
        ),
        const SizedBox(height: 32),
        FadeSlideTransition(
          controller: _staggerController,
          delay: 0.2,
          child: Text(
            'Bienvenue !',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.w800,
              fontSize: 32,
              color: _lightText,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        FadeSlideTransition(
          controller: _staggerController,
          delay: 0.3,
          child: Text(
            'Connectez-vous pour continuer',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: 16,
              color: _mutedText,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// Builds the Email and Password glassmorphism input fields.
  Widget _buildTextInputs() {
    return Column(
      children: [
        FadeSlideTransition(
          controller: _staggerController,
          delay: 0.4,
          child: GlassTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 16),
        FadeSlideTransition(
          controller: _staggerController,
          delay: 0.5,
          child: GlassTextField(
            controller: _passwordController,
            label: 'Mot de passe',
            icon: Icons.lock_outline,
            isPassword: true,
          ),
        ),
      ],
    );
  }

  /// Builds the selector toggle between Teacher vs Parent login.
  Widget _buildRoleSelector() {
    return FadeSlideTransition(
      controller: _staggerController,
      delay: 0.6,
      child: GlassRoleSelector(
        selectedRole: _selectedRole,
        onRoleChanged: (role) => setState(() => _selectedRole = role),
      ),
    );
  }

  /// Builds the submit login button or a loading indicator.
  Widget _buildSubmitAction() {
    return FadeSlideTransition(
      controller: _staggerController,
      delay: 0.7,
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: _tealAccent,
              ),
            )
          : LoginButton(
              onPressed: _handleLogin,
            ),
    );
  }

  /// Conditionally displays a register link based on global parameters.
  Widget _buildRegisterLink() {
    if (!_inscriptionsOpen) return const SizedBox.shrink();
    return FadeSlideTransition(
      controller: _staggerController,
      delay: 0.8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Pas encore de compte ? ',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              color: _mutedText,
              fontSize: 15,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegisterPage(),
                ),
              );
            },
            child: Text(
              'S\'inscrire',
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.w700,
                color: _tealAccent,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
