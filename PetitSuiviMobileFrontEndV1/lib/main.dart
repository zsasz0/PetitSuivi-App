/// @file main.dart
/// @brief The entry point and root configuration for the SmartKids application.
/// @details This file initializes the Flutter engine, sets up persistent state providers,
/// establishes the global visual theme, and manages the initial application navigation 
/// flow through the AnimatedSplashScreen.
library;
import 'dart:io';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/intro/splash/animated_splash_screen.dart';
import 'package:newv/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'models/auth_session.dart';
import 'models/user_profile.dart';
import 'views/themes/theme_manager.dart';



/// The logic of the entry page is expertly handled by [AnimatedSplashScreen].
///
/// The splash screen runs an aesthetic, character-by-character text entrance animation
/// and a persistent glowing orbs background, while asynchronously checking `SharedPreferences`.
///
/// If the introduction was never seen, it beautifully cross-fades into [IntroductionAnimationScreen].
/// If the introduction was complete, it seamlessly transitions into the identical background of [LoginPage].

/// The primary entry point for the application.
void main() async {
  /// Initialize the app binding before executing any UI rendering.
  WidgetsFlutterBinding.ensureInitialized();

  /// Set the preferred orientation of the app to portrait only (up and down).
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(const MyApp()));
}

/// The root widget configuration of the application.
class MyApp extends StatelessWidget {
  /// Creates a new instance of [MyApp].
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    /// MultiProvider wraps the widget tree to provide [UserProfile] and [AuthSession]
    /// state objects to any descendant widgets. Providers allow state to be shared effortlessly across the UI.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProfile()),
        ChangeNotifierProvider(create: (_) => AuthSession()),
        ChangeNotifierProvider.value(value: ThemeManager.instance),
      ],

      /// [MaterialApp] is the core entry widget defining routing, localization, and theming.
      child: Consumer<ThemeManager>(
        builder: (context, theme, _) {
          /// Configure the system status bar and navigation bar UI styles based on theme.
          final isLight = theme.isLightMode;
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isLight
                  ? Brightness.dark
                  : Brightness.light,
              statusBarBrightness: !kIsWeb && Platform.isAndroid
                  ? (isLight ? Brightness.dark : Brightness.light)
                  : (isLight ? Brightness.light : Brightness.dark),
              systemNavigationBarColor: isLight
                  ? const Color(0xFFF0F2F5)
                  : const Color(0xFF141B2D),
              systemNavigationBarDividerColor: Colors.transparent,
              systemNavigationBarIconBrightness: isLight
                  ? Brightness.dark
                  : Brightness.light,
            ),
          );

          return MaterialApp(
            title: 'PETIT SUIVI',
            debugShowCheckedModeBanner: false,
            locale: const Locale('fr'),

            /// Delegates responsible for generating localized strings down the widget tree.
            localizationsDelegates: AppLocalizations.localizationsDelegates,

            /// The list of locales physically supported by the application interfaces.
            supportedLocales: AppLocalizations.supportedLocales,

            /// The global visual theme utilized across the app.
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.amber,
              textTheme: AppTheme.textTheme,
              platform: TargetPlatform.iOS,
              scaffoldBackgroundColor: AppTheme.background,
              dividerTheme: DividerThemeData(
                color: isLight
                    ? const Color(0xFFE0E0E0)
                    : const Color(0xFF2A2F35),
              ),
            ),

            /// The initial screen presented when the app finishes launching.
            home: const AnimatedSplashScreen(),
          );
        },
      ),
    );
  }
}

/// A helpful layout utility extension over [Color] engineered to instantiate a color purely from a hexadecimal string format.
class HexColor extends Color {
  /// Invokes a new [Color] instance dynamically derived from a parsed [hexColor] string.
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  /// Syntactically parses the provided [hexColor] sequence and translates it into an integer valid for the [Color] constructor.
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}
