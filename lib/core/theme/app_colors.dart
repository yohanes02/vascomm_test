import 'package:flutter/material.dart';

/// Brand palette lifted from the product design mockups. Centralized here
/// so screens reference names (`AppColors.navy`) instead of scattering hex
/// literals across widgets.
class AppColors {
  AppColors._();

  static const navy = Color(0xFF0C2461);
  static const navyDark = Color(0xFF081A47);
  static const teal = Color(0xFF14B8A6);

  /// Muted teal used for the selected segment of a toggle.
  static const tealSoft = Color(0xFF6ED7CB);
  static const tealLight = Color(0xFFE3F8F5);
  static const background = Color(0xFFF4F6FA);

  /// Muted blue for supporting copy on navy-leaning surfaces (e.g. the
  /// drawer's membership line).
  static const slateBlue = Color(0xFF5B7CA6);

  /// Barely-there grey for de-emphasised footer links.
  static const textFaint = Color(0xFFD3D8E2);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF8A8FA3);
  static const danger = Color(0xFFE5484D);
  static const border = Color(0xFFE7E9F1);
  static const star = Color(0xFFFFE01B);
  static const orange = Color(0xFFF5822B);

  /// "Ready Stok"-style availability badge.
  static const success = Color(0xFF2FA96B);
  static const successLight = Color(0xFFE1F6E9);

  /// Soft navy-tinted drop shadow the design uses on every card/pill in
  /// place of a hairline border.
  static const shadowColor = Color(0x0F0C2461);

  static const cardShadow = [
    BoxShadow(color: shadowColor, blurRadius: 24, offset: Offset(0, 10)),
  ];

  /// Tighter version for small controls (chips, search field, toggles).
  static const softShadow = [
    BoxShadow(color: shadowColor, blurRadius: 14, offset: Offset(0, 6)),
  ];

  /// Form inputs get a fainter, more diffuse shadow: the negative spread
  /// pulls it in from the edges and the downward offset keeps the field's
  /// top edge clean, so the halo only reads as a soft glow underneath.
  static const inputShadow = [
    BoxShadow(
      color: Color(0x0A0C2461),
      blurRadius: 26,
      spreadRadius: -6,
      offset: Offset(0, 10),
    ),
  ];
}
