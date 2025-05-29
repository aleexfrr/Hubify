import 'package:flutter/material.dart';

class PlatformData {
  static const Map<String, String> platformLogos = {
    'PlayStation': 'assets/icons/ps.png',
    'Xbox': 'assets/icons/xbox.png',
    'Ubisoft': 'assets/icons/ubisoft.png',
    'Steam': 'assets/icons/steam.png',
  };

  static const Map<String, Color> platformColors = {
    'PlayStation': Color(0xFF003791),
    'Xbox': Color(0xFF107C10),
    'Ubisoft': Color(0xFF5A5AFF),
    'Steam': Color(0xFF171A21),
  };

  static const Map<String, String> platformBackgrounds = {
    'PlayStation': 'assets/images/bg_ps.jpg',
    'Xbox': 'assets/images/bg_xbox.jpg',
    'Ubisoft': 'assets/images/bg_ubisoft.jpeg',
    'Steam': 'assets/images/bg_steam.jpg',
  };
}
