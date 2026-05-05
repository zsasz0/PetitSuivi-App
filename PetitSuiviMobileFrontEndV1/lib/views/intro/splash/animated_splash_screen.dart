import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/views/intro/introduction/introduction_animation_screen.dart';
import 'package:newv/views/auth/login/login_page.dart';
import 'package:newv/views/auth/login/components/common/login_background_painter.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/themes/theme_manager.dart';

/// An animated entry interface that actively masks the initial data load.
///
/// [AnimatedSplashScreen] dynamically queries `package_info_plus` for the true app name
/// and stylizes it with staggered text entry. It utilizes the [LoginBackgroundPainter] to
/// provide an immersive entrance that perfectly maps to the [LoginPage] environment.
class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  // Changed to TickerProviderStateMixin to support multiple controllers
  late AnimationController _textAnimController;
  late AnimationController _bgAnimController;

  static const String _introSeenKey = 'intro_seen_v1';
  String _appName = "";
  bool _isNameLoaded = false;
  bool _fadeOut = false;

  @override
  void initState() {
    super.initState();

    // Background animation replicating login page
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Text entrance animation
    _textAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appName = packageInfo.appName;
      _isNameLoaded = true;
    });

    int totalMillis = (_appName.length * 150) + 1200;
    _textAnimController.duration = Duration(milliseconds: totalMillis);

    _textAnimController.forward();

    final List<dynamic> results = await Future.wait([
      _shouldShowIntro(),
      Future.delayed(Duration(milliseconds: totalMillis + 600)),
    ]);

    final bool showIntro = results[0] as bool;

    if (!mounted) return;

    // Always clear any persisted session so the user must log in fresh
    final authSession = context.read<AuthSession>();
    authSession.clear();

    if (!mounted) return;

    Widget nextPage;
    if (showIntro) {
      nextPage = const IntroductionAnimationScreen();
    } else {
      nextPage = const LoginPage();
    }

    // Trigger the disappearance of the majestic splash text
    setState(() {
      _fadeOut = true;
    });

    // Wait for the text to elegantly fade away leaving only the animated background
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(
          milliseconds: 300,
        ), // Snappier crossfade
        pageBuilder: (context, animation, secondaryAnimation) => nextPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  // true = show intro, false = show login
  Future<bool> _shouldShowIntro() async {
    final prefs = await SharedPreferences.getInstance();
    final introSeen = prefs.getBool(_introSeenKey) ?? false;

    if (!introSeen) {
      await prefs.setBool(_introSeenKey, true);
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _textAnimController.dispose();
    _bgAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    if (!_isNameLoaded) {
      return Scaffold(
        backgroundColor: ThemeManager.instance.isLightMode
            ? const Color(0xFFF0F2F5)
            : const Color(0xFF141B2D),
      );
    }

    List<Widget> animatedChars = [];

    for (int i = 0; i < _appName.length; i++) {
      double start = i / (_appName.length + 5);
      double end = (i + 5) / (_appName.length + 5);
      if (end > 1.0) end = 1.0;

      final Animation<double> opacityAnim = Tween<double>(begin: 0.0, end: 1.0)
          .animate(
            CurvedAnimation(
              parent: _textAnimController,
              curve: Interval(start, end, curve: Curves.easeIn),
            ),
          );

      final Animation<Offset> slideAnim =
          Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _textAnimController,
              curve: Interval(start, end, curve: Curves.easeOutCubic),
            ),
          );

      animatedChars.add(
        FadeTransition(
          opacity: opacityAnim,
          child: SlideTransition(
            position: slideAnim,
            child: Text(
              _appName[i],
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: ThemeManager.instance.isLightMode
                    ? Colors.black87
                    : Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ThemeManager.instance.isLightMode
          ? const Color(0xFFF0F2F5)
          : const Color(0xFF141B2D),
      body: Stack(
        children: [
          // Match the login page's glowing orbs background perfectly
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgAnimController,
              builder: (context, child) {
                return CustomPaint(
                  painter: LoginBackgroundPainter(_bgAnimController.value),
                );
              },
            ),
          ),
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: _fadeOut ? 0.0 : 1.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: animatedChars,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
