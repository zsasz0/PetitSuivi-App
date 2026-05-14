import 'package:newv/views/auth/login/controllers/login_controller.dart';
import 'package:newv/views/shared/sharedHome/combined_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'components/login/login_header.dart';
import 'components/login/login_forgot_password_link.dart';
import 'components/login/login_inputs.dart';
import 'components/login/login_register_link.dart';
import 'components/login/login_role_selector.dart';
import 'components/login/login_submit_action.dart';
import 'components/login/login_background.dart';
import 'themes/login_theme.dart';
import '../../themes/app_theme.dart';
import '../register/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// The state for [LoginPage].
class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
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

  /// Controls the background animation.
  late AnimationController _bgAnimController;

  /// Controls the stagger animation.
  late AnimationController _staggerController;

  /// The login controller.
  late final LoginController _controller;

  /// Initializes the controller and animations.
  @override
  void initState() {
    super.initState();
    _controller = LoginController(context);

    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _loadSavedEmail();
    _checkInscriptionsOpen();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resumePersistedSessionIfAvailable();
    });
  }

  /// Disposes of the controller and animations.
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
    await _controller.resumePersistedSessionIfAvailable(
      onTeacherHome: _openTeacherHome,
      onParentHome: _openParentHome,
      onError: _showError,
    );
  }

  /// Restores the last used email address using SharedPreferences to reduce repetitive typing.
  Future<void> _loadSavedEmail() async {
    final email = await _controller.getSavedEmail();
    if (email != null && email.isNotEmpty && mounted) {
      _emailController.text = email;
    }
  }

  /// Queries the API to check if `inscriptions_open` parameter is active.
  /// Modifies local state to show or hide the registration option.
  Future<void> _checkInscriptionsOpen() async {
    final status = await _controller.checkInscriptionsOpen();
    if (mounted) {
      setState(() {
        _inscriptionsOpen = status;
      });
    }
  }

  /// Validates input and fires the POST request for user authentication.
  Future<void> _handleLogin() async {
    await _controller.handleLogin(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      selectedRole: _selectedRole,
      onLoadingChanged: (loading) {
        if (mounted) setState(() => _isLoading = loading);
      },
      onError: _showError,
      onTeacherHome: _openTeacherHome,
      onParentHome: _openParentHome,
    );
  }

  /// Navigates to the teacher home screen.
  void _openTeacherHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const CombinedHomeScreen(userRole: 1),
      ),
    );
  }

  /// Navigates to the parent home screen.
  void _openParentHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const CombinedHomeScreen(userRole: 2),
      ),
    );
  }

  /// Opens the registration page only if an active school-year planning exists.
  Future<void> _handleRegister() async {
    final hasActive = await _controller.checkActivePlanning();
    if (!mounted) return;
    if (!hasActive) {
      _showError(
        'Les inscriptions sont fermées. '
        'Aucune année scolaire active n\'est en cours. '
        'Veuillez contacter l\'administration.',
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  /// Displays an error message in a SnackBar.
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

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _openForgotPasswordDialog() async {
    var forgotEmail = _emailController.text.trim();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool isSending = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: LoginTheme.baseDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Mot de passe oublie',
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  color: LoginTheme.lightText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Entrez votre email pour recevoir un nouveau mot de passe.',
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      color: LoginTheme.mutedText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: forgotEmail,
                    onChanged: (value) => forgotEmail = value,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      color: LoginTheme.lightText,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        fontFamily: AppTheme.fontName,
                        color: LoginTheme.mutedText,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: LoginTheme.mutedText.withValues(alpha: 0.4),
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: LoginTheme.tealAccent),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSending
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: Text(
                    'Annuler',
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      color: LoginTheme.mutedText,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          FocusScope.of(dialogContext).unfocus();
                          setDialogState(() => isSending = true);

                          final result = await _controller.handleForgotPassword(
                            email: forgotEmail.trim(),
                            selectedRole: _selectedRole,
                          );

                          if (!mounted || !dialogContext.mounted) return;

                          setDialogState(() => isSending = false);

                          final success = result['success'] == true;
                          final message =
                              result['message']?.toString() ??
                              'Une erreur est survenue.';

                          if (success) {
                            Navigator.of(dialogContext).pop();
                            _showSuccess(message);
                            return;
                          }

                          _showError(message);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LoginTheme.tealAccent,
                    foregroundColor: LoginTheme.baseDark,
                  ),
                  child: isSending
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: LoginTheme.baseDark,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Envoyer',
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGET BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Scaffold(
      backgroundColor: LoginTheme.baseDark,
      body: Stack(
        children: [
          LoginBackground(bgAnimController: _bgAnimController),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  LoginHeader(staggerController: _staggerController),
                  const SizedBox(height: 48),
                  LoginInputs(
                    staggerController: _staggerController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                  ),
                  const SizedBox(height: 24),
                  LoginRoleSelector(
                    selectedRole: _selectedRole,
                    onRoleChanged: (role) =>
                        setState(() => _selectedRole = role),
                  ),
                  const SizedBox(height: 6),
                  LoginForgotPasswordLink(
                    staggerController: _staggerController,
                    onPressed: _openForgotPasswordDialog,
                  ),
                  const SizedBox(height: 10),
                  LoginSubmitAction(
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: 12),
                  LoginRegisterLink(
                    inscriptionsOpen: _inscriptionsOpen,
                    staggerController: _staggerController,
                    onRegisterPressed: _handleRegister,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
