import 'package:customer_app/core/constants/appcolors.dart';
import 'package:customer_app/core/constants/appdimensions.dart';
import 'package:flutter/material.dart';


class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true, // Recommended for Flutter 3+
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.cardBackground,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.background,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
    ),

    fontFamily: 'Roboto',

    textTheme: TextTheme(
      displayLarge: TextStyle(
          fontSize: AppDimensions.fontXLarge,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary),
      displayMedium: TextStyle(
          fontSize: AppDimensions.fontLarge,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary),
      bodyLarge: TextStyle(
          fontSize: AppDimensions.fontMedium, color: AppColors.textPrimary),
      bodyMedium: TextStyle(
          fontSize: AppDimensions.fontSmall, color: AppColors.textSecondary),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        ),
        textStyle: TextStyle(fontSize: AppDimensions.fontMedium),
      ),
    ),
  );
}
