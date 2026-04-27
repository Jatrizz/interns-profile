import 'package:flutter/material.dart';

class AppTheme {
  final bool isDarkMode;

  const AppTheme._({required this.isDarkMode});

  factory AppTheme.of(bool isDarkMode) => AppTheme._(isDarkMode: isDarkMode);

  // ── Backgrounds ──────────────────────────────────────────
  Color get scaffoldBg =>
      isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF4F6F9);
  Color get sidebarBg =>
      isDarkMode ? const Color(0xFF242424) : const Color(0xFFFFFFFF);
  Color get topBarBg =>
      isDarkMode ? const Color(0xFF242424) : const Color(0xFFFFFFFF);
  Color get cardBg =>
      isDarkMode ? const Color(0xFF2E2E2E) : const Color(0xFFFFFFFF);
  Color get cardInnerBg =>
      isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFEFF2F7);
  Color get rightPanelBg =>
      isDarkMode ? const Color(0xFF242424) : const Color(0xFFFFFFFF);
  Color get internListItemBg =>
      isDarkMode ? const Color(0xFF2E2E2E) : const Color(0xFFF0F3F8);

  // ── Text ─────────────────────────────────────────────────
  Color get textPrimary =>
      isDarkMode ? Colors.white : const Color(0xFF1A1B2E);
  Color get textSecondary =>
      isDarkMode ? const Color(0xFF9E9E9E) : const Color(0xFF6B7280);
  Color get textMuted =>
      isDarkMode ? Colors.grey : const Color(0xFF9CA3AF);

  // ── Borders / Dividers ───────────────────────────────────
  Color get divider =>
      isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE5E7EB);
  Color get navButtonHover =>
      isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFF3F4F6);
  Color get activeNavItem =>
      isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE8EEF8);

  // ── Icons ────────────────────────────────────────────────
  Color get iconColor =>
      isDarkMode ? Colors.white : const Color(0xFF374151);
  Color get iconMuted =>
      isDarkMode ? const Color(0xFF9E9E9E) : const Color(0xFF6B7280);

  // ── Calendar nav buttons ─────────────────────────────────
  Color get calendarNavBg =>
      isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFEEF2FF);

  // ── Shadows ──────────────────────────────────────────────
  List<BoxShadow> get cardShadow => isDarkMode
      ? []
      : [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ];

  // ── Toggle icon ──────────────────────────────────────────
  IconData get themeIcon =>
      isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_outlined;

  // ── Accent ───────────────────────────────────────────────
  static const Color accent = Color(0xFF00BFFF);
}

// ─────────────────────────────────────────────────────────────
//  Landing page theme  (home, about, contact, login, register)
// ─────────────────────────────────────────────────────────────
class LandingTheme {
  final bool isDarkMode;
  const LandingTheme._({required this.isDarkMode});
  factory LandingTheme.of(bool isDarkMode) =>
      LandingTheme._(isDarkMode: isDarkMode);

  // Backgrounds
  Color get scaffoldBg =>
      isDarkMode ? Colors.black : const Color(0xFFF5F6FA);
  Color get navBg => isDarkMode
      ? Colors.black
      : const Color(0xFFFFFFFF);
  Color get cardBg => isDarkMode
      ? const Color(0xFF111111)
      : const Color(0xFFFFFFFF);
  Color get sectionAltBg => isDarkMode
      ? const Color(0xFF0D0D0D)
      : const Color(0xFFEEF2FF);
  Color get inputBg => isDarkMode
      ? const Color(0xFF1A1A1A)
      : const Color(0xFFFFFFFF);
  Color get inputBorder => isDarkMode
      ? const Color(0xFF2E2E2E)
      : const Color(0xFFD1D5DB);
  Color get contactFormBg => isDarkMode
      ? const Color(0xFF111111)
      : const Color(0xFFFFFFFF);

  // Text
  Color get textPrimary =>
      isDarkMode ? Colors.white : const Color(0xFF111827);
  Color get textSecondary =>
      isDarkMode ? const Color(0xFFAAAAAA) : const Color(0xFF6B7280);
  Color get textMuted =>
      isDarkMode ? const Color(0xFF666666) : const Color(0xFF9CA3AF);
  Color get navText =>
      isDarkMode ? Colors.white : const Color(0xFF374151);

  // Dividers / borders
  Color get divider =>
      isDarkMode ? const Color(0xFF1F1F1F) : const Color(0xFFE5E7EB);
  Color get navBorder =>
      isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFE5E7EB);

  // Footer
  Color get footerBg =>
      isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFFFFFF);
  Color get footerText =>
      isDarkMode ? const Color(0xFF666666) : const Color(0xFF9CA3AF);

  // Icons
  Color get iconColor =>
      isDarkMode ? Colors.white : const Color(0xFF374151);

  // Shadows
  List<BoxShadow> get cardShadow => isDarkMode
      ? []
      : [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ];

  // Toggle
  IconData get themeIcon =>
      isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_outlined;

  // Accent (shared)
  static const Color accent = Color(0xFF00BFFF);
  static const Color accentDark = Color(0xFF0066CC);

  // Gradient button
  List<Color> get gradientBtn => isDarkMode
      ? [const Color(0xFF418ECC), const Color(0xFF0004FA)]
      : [const Color(0xFF00BFFF), const Color(0xFF0066CC)];
}