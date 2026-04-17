import 'package:flutter/material.dart';
import 'theme_manager.dart';

/// Centralized theme-aware colors for glassmorphism effects and common UI patterns.
///
/// This utility class provides dynamic colors that adapt to light/dark mode
/// using the ThemeManager singleton. Use these instead of hardcoding
/// Colors.white.withValues() or Colors.black.withValues().
class ThemeColors {
  ThemeColors._(); // Private constructor to prevent instantiation

  static bool get _isLight => ThemeManager.instance.isLightMode;

  // ============================================================
  // BASE COLORS
  // ============================================================

  /// Primary dark background color (cards, containers)
  /// Dark mode: deep navy blue | Light mode: light gray
  static Color get baseDark =>
      _isLight ? const Color(0xFFF0F2F5) : const Color(0xFF141B2D);

  /// Secondary dark background (slightly lighter than baseDark)
  /// Dark mode: navy blue | Light mode: white
  static Color get surfaceDark =>
      _isLight ? Colors.white : const Color(0xFF1F2940);

  // ============================================================
  // GLASSMORPHISM BORDERS
  // ============================================================

  /// Standard glassmorphism border (opacity 0.1)
  static Color get glassBorder => _isLight
      ? Colors.black.withValues(alpha: 0.1)
      : Colors.white.withValues(alpha: 0.1);

  /// Subtle glassmorphism border (opacity 0.05)
  static Color get glassBorderSubtle => _isLight
      ? Colors.black.withValues(alpha: 0.05)
      : Colors.white.withValues(alpha: 0.05);

  /// Medium glassmorphism border (opacity 0.15)
  static Color get glassBorderMedium => _isLight
      ? Colors.black.withValues(alpha: 0.15)
      : Colors.white.withValues(alpha: 0.15);

  /// Strong glassmorphism border (opacity 0.2)
  static Color get glassBorderStrong => _isLight
      ? Colors.black.withValues(alpha: 0.2)
      : Colors.white.withValues(alpha: 0.2);

  // ============================================================
  // GLASSMORPHISM BACKGROUNDS
  // ============================================================

  /// Standard glassmorphism background (opacity 0.1)
  static Color get glassBackground => _isLight
      ? Colors.black.withValues(alpha: 0.05)
      : Colors.white.withValues(alpha: 0.1);

  /// Subtle glassmorphism background (opacity 0.05)
  static Color get glassBackgroundSubtle => _isLight
      ? Colors.black.withValues(alpha: 0.03)
      : Colors.white.withValues(alpha: 0.05);

  /// Medium glassmorphism background (opacity 0.15)
  static Color get glassBackgroundMedium => _isLight
      ? Colors.black.withValues(alpha: 0.08)
      : Colors.white.withValues(alpha: 0.15);

  /// Strong glassmorphism background (opacity 0.2)
  static Color get glassBackgroundStrong => _isLight
      ? Colors.black.withValues(alpha: 0.1)
      : Colors.white.withValues(alpha: 0.2);

  // ============================================================
  // DIVIDERS & SEPARATORS
  // ============================================================

  /// Standard divider color
  static Color get divider => _isLight
      ? Colors.black.withValues(alpha: 0.1)
      : Colors.white.withValues(alpha: 0.1);

  /// Subtle divider color
  static Color get dividerSubtle => _isLight
      ? Colors.black.withValues(alpha: 0.05)
      : Colors.white.withValues(alpha: 0.05);

  // ============================================================
  // TEXT COLORS
  // ============================================================

  /// Primary text color
  static Color get textPrimary => _isLight ? Colors.black87 : Colors.white;

  /// Secondary text color (less emphasis)
  static Color get textSecondary => _isLight ? Colors.black54 : Colors.white70;

  /// Tertiary text color (hints, placeholders)
  static Color get textTertiary => _isLight ? Colors.black38 : Colors.white54;

  // ============================================================
  // ICON COLORS
  // ============================================================

  /// Primary icon color
  static Color get iconPrimary => _isLight ? Colors.black87 : Colors.white;

  /// Secondary icon color
  static Color get iconSecondary => _isLight ? Colors.black54 : Colors.white70;

  // ============================================================
  // SHADOWS & OVERLAYS
  // ============================================================

  /// Shadow color for elevated elements
  static Color get shadow => _isLight
      ? Colors.black.withValues(alpha: 0.1)
      : Colors.black.withValues(alpha: 0.3);

  /// Overlay color for modals, dialogs
  static Color get overlay => _isLight
      ? Colors.black.withValues(alpha: 0.3)
      : Colors.black.withValues(alpha: 0.5);

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Get a custom opacity glass border
  static Color glassBorderWithOpacity(double opacity) => _isLight
      ? Colors.black.withValues(alpha: opacity)
      : Colors.white.withValues(alpha: opacity);

  /// Get a custom opacity glass background
  static Color glassBackgroundWithOpacity(double opacity) => _isLight
      ? Colors.black.withValues(
          alpha: opacity * 0.5,
        ) // Light mode uses less opacity
      : Colors.white.withValues(alpha: opacity);
}
