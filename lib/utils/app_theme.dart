import 'package:flutter/material.dart';

/// MyStok Design System — single source of truth untuk warna, radius, spacing.
class AppColors {
  // Brand
  static const primary = Color(0xFF0B3BB6);
  static const primaryLight = Color(0xFF3E6BDF);
  static const primaryDark = Color(0xFF082D8C);

  // Accent per fitur (full color)
  static const dashboard = Color(0xFF0B3BB6);
  static const kasir = Color(0xFF0891B2);
  static const barang = Color(0xFF7C3AED);
  static const stok = Color(0xFF0D9488);
  static const barangMasuk = Color(0xFF059669);
  static const barangKeluar = Color(0xFFE11D48);
  static const laporanMasuk = Color(0xFFD97706);
  static const laporanKeluar = Color(0xFFEA580C);
  static const transaksi = Color(0xFF4338CA);
  static const profile = Color(0xFF475569);

  // Status
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFD97706);
  static const danger = Color(0xFFDC2626);
  static const info = Color(0xFF0891B2);

  // Neutral
  static const bg = Color(0xFFF4F6F9);
  static const card = Color(0xFFFFFFFF);
  static const soft = Color(0xFFF8F9FB);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF4B5563);
  static const textMuted = Color(0xFF6C757D);
  static const border = Color(0xFFE5E7EB);
}

class AppRadius {
  static const sm = 8.0;
  static const md = 14.0;
  static const lg = 20.0;
}

class AppShadow {
  static List<BoxShadow> get sm => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.10),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> colored(Color c) => [
        BoxShadow(
          color: c.withValues(alpha: 0.28),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
}

class AppGradients {
  static LinearGradient of(Color c) => LinearGradient(
        colors: [c, Color.lerp(c, Colors.white, 0.28)!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static const primary = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.card,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }
}
