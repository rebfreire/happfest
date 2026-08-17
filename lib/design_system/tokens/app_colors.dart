import 'package:flutter/widgets.dart';

/// Extraído ao vivo do site em produção (happ-marketplace.comcode.com.br),
/// via CSS custom properties computadas (`--color-*`, `--p-primary-*`,
/// `--p-surface-*`) — não do protótipo `vibrant_celebration`. Ver
/// AGENTS.md seção 0 e o plano de setup para o detalhamento da extração.
abstract final class AppColors {
  // Marca
  static const primary = Color(0xFFFF3F81);
  static const secondary = Color(0xFF3F8CFF);
  static const accent = Color(0xFF2DF3A1);

  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryHover = Color(0xFFE6356E);
  static const primaryActive = Color(0xFFCC2B5C);

  // Ação / estado
  static const danger = Color(0xFFEF4444);
  static const dangerStrong = Color(0xFFDC2626);
  static const success = Color(0xFF2DF3A1);
  static const successStrong = Color(0xFF15803D);
  static const warning = Color(0xFFF59E0B);

  // Superfície (escala slate do tema PrimeNG do site)
  static const surface0 = Color(0xFFFFFFFF);
  static const surface50 = Color(0xFFF8FAFC);
  static const surface100 = Color(0xFFF1F5F9);
  static const surface200 = Color(0xFFE2E8F0);
  static const surface300 = Color(0xFFCBD5E1);
  static const surface400 = Color(0xFF94A3B8);
  static const surface500 = Color(0xFF64748B);
  static const surface600 = Color(0xFF475569);
  static const surface700 = Color(0xFF334155);
  static const surface800 = Color(0xFF1E293B);
  static const surface900 = Color(0xFF0F172A);

  static const textPrimary = Color(0xFF334155);
  static const textSecondary = Color(0xFF64748B);
  static const outline = Color(0xFFCBD5E1);
}
