import 'package:flutter/material.dart';

// Text: #ffffff - rgb(255, 255, 255) - hsl(0, 0%, 100%)
// Background: #161837 - rgb(22, 24, 55) - hsl(236, 43%, 15%)
// Primary: #9d5ec9 - rgb(157, 94, 201) - hsl(275, 50%, 58%)
// Secondary: #c5a9c7 - rgb(197, 169, 199) - hsl(296, 21%, 72%)
// Accent: #b78fa8 - rgb(183, 143, 168) - hsl(323, 22%, 64%)
// Bg2: #20213F
// Tiles: #524966
ThemeData defaultTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    surface: Color(0xFF161837),
    primary: Color(0xFF9d5ec9),
    secondary: Color(0xFFc5a9c7),
    tertiary: Color(0xFFb78fa8),
    surfaceBright: Color(0xFF20213F),
    secondaryContainer: Color(0xFF524966),
  ),
  textTheme: ThemeData.dark().textTheme.apply(
        fontFamily: 'Inter',
        // bodyColor: Colors.grey[800],
        // displayColor: Colors.white,
        bodyColor: Colors.white,
      ),
);
