import 'package:flutter/material.dart';

const primaryColor = Color(0xFF009DC1);
const secondaryColor = Color(0xFF006F88);


themeData(){
  return ThemeData(
    scaffoldBackgroundColor: Color(0xFFF8F8F8),
    fontFamily: 'Manrope',
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFFF8F8F8),
    ),
    inputDecorationTheme: inputDecoration(),
    textTheme: TextTheme(
        displayLarge: TextStyle(
          letterSpacing: -0.5
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0
        ),
        bodyMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0
        ),
      )
  );
}

InputDecorationTheme inputDecoration() {
  var outlineInputBorder = const OutlineInputBorder(
      borderSide: BorderSide(width: 1, color: Color(0xFFB4B4B4)),
      borderRadius: BorderRadius.all(Radius.circular(50)),
      gapPadding: 2);
  return InputDecorationTheme(
    fillColor: Colors.grey.shade200,
    filled: true,
    contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 20),
    labelStyle:
        TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
    hintStyle:
        TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
    hintFadeDuration: Durations.medium3,
    enabledBorder: outlineInputBorder,
    focusedBorder: outlineInputBorder,
    border: outlineInputBorder,
    errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(16)),
        gapPadding: 5),
  );
}