import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:newv/views/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/auth/login/login_page.dart';
import 'components/skip_button.dart';
import 'components/start_button.dart';
import 'components/fluid_background_painter.dart';

// File: introduction_animation_screen.dart
// Purpose: Multi-page introductory walkthrough for first-time users.
// Usage: Displayed by AppEntryGate if the user hasn't seen the intro.
// API Usage: No.
// Dependencies: LoginPage, SkipButton, StartButton, FluidBackgroundPainter.

/// A stateful screen providing a smooth, animated introduction to the app's core features.
///
/// This screen uses a [PageView] combined with custom background animations
/// to guide first-time users before they proceed to authentication.
///
/// It utilizes [_navigateToHome] to transition the user to the [LoginPage] upon completion or skipping of the walkthrough.
class IntroductionAnimationScreen extends StatefulWidget {
  /// Creates a new [IntroductionAnimationScreen].
  const IntroductionAnimationScreen({super.key});

  @override
  State<IntroductionAnimationScreen> createState() =>
      _IntroductionAnimationScreenState();
}

// this is the state of the introduction screen
class _IntroductionAnimationScreenState
    extends State<IntroductionAnimationScreen>
    with TickerProviderStateMixin {
  //
  int currentPage = 0;
  late PageController _pageController;
  late AnimationController _bgAnimController;
  late AnimationController _floatAnimController;

  static Color get _tealAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF009688)
      : const Color(0xFF4CCEAC);
  static Color get _indigoAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF3F51B5)
      : const Color(0xFF6870FA);
  static Color get _baseDark => ThemeManager.instance.isLightMode
      ? const Color(0xFFF0F2F5)
      : const Color(0xFF141B2D);
  static Color get _lightText => ThemeManager.instance.isLightMode
      ? const Color(0xFF212529)
      : const Color(0xFFF2F0F0);
  static Color get _mutedText => ThemeManager.instance.isLightMode
      ? const Color(0xFF6C757D)
      : const Color(0xFFA1A4AB);

  /*
this is the list of pages that will be displayed in the introduction screen
*/

  final List<_IntroPage> pages = [
    _IntroPage(
      image: 'assets/introduction_animation/welcome_final.png',
      title: 'Bienvenue sur PETIT SUIVI',
      subtitle: 'La plateforme qui connecte\nparents et jardin d\'enfants.',
    ),
    _IntroPage(
      image: 'assets/introduction_animation/tracking_final.png',
      title: 'Suivi Quotidien',
      subtitle:
          'Repas, siestes, activités...\nSuivez la journée de votre enfant.',
    ),
    _IntroPage(
      image: 'assets/introduction_animation/start_final.png',
      title: 'C\'est parti !',
      subtitle: 'Créez votre compte et\ncommencez l\'aventure PETIT SUIVI.',
    ),
  ];

  // init state method responsible for initializing the state of the widget
  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    _floatAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgAnimController.dispose();
    _floatAnimController.dispose();
    super.dispose();
  }

  // build method responsible for building the widget "IntroductionAnimationScreen"
  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Scaffold(
      backgroundColor: _baseDark,
      body: Stack(
        children: [
          // Fluid Animated Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgAnimController,
              builder: (context, child) {
                return CustomPaint(
                  painter: FluidBackgroundPainter(
                    _bgAnimController.value,
                    currentPage,
                  ),
                );
              },
            ),
          ),

          // Main Content that has the pages
          SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _buildPage(pages[index]);
                    },
                  ),
                ),
                // Page indicator dots
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pages.length, (index) {
                      final isActive = currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? _tealAccent
                              : ThemeColors.glassBorderStrong,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: _tealAccent.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                      );
                    }),
                  ),
                ),
                // Bottom Buttons
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 32,
                    left: 24,
                    right: 24,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: currentPage == pages.length - 1
                        /*
core of the widget : 
StartButton(onPressed: _navigateToHome)
and 
SkipButton(onPressed: _navigateToHome)
*/
                        ? StartButton(onPressed: _navigateToHome)
                        : SkipButton(onPressed: _navigateToHome),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // core of the widget :
  // this method is responsible for navigating to the login page
  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  // build method responsible for building the page
  Widget _buildPage(_IntroPage page) {
    return AnimatedBuilder(
      animation: _floatAnimController,
      builder: (context, child) {
        // Smooth floating effect
        final dy = math.sin(_floatAnimController.value * math.pi) * 12.0;
        final screenHeight = MediaQuery.of(context).size.height;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Transform.translate(
              offset: Offset(0, dy),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _indigoAccent.withValues(alpha: 0.1),
                        blurRadius: 50,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    page.image,
                    height: screenHeight * 0.32,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                page.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  color: _lightText,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                page.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: _mutedText,
                  height: 1.5,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _IntroPage {
  final String image;
  final String title;
  final String subtitle;

  const _IntroPage({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}
