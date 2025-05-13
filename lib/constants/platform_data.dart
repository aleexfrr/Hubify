import 'package:flutter/material.dart';

class PlatformData {
  static const Map<String, String> platformLogos = {
    'PlayStation': 'assets/icons/ps.png',
    'Xbox': 'assets/icons/xbox.png',
    'Ubisoft': 'assets/icons/ubisoft.png',
    'Steam': 'assets/icons/steam.png',
    'Epic Games': 'assets/icons/epicgames.png',
  };

  static const Map<String, Color> platformColors = {
    'PlayStation': Color(0xFF003791),
    'Xbox': Color(0xFF107C10),
    'Ubisoft': Color(0xFF5A5AFF),
    'Steam': Color(0xFF171A21),
    'Epic Games': Color(0xFF313131),
  };

  static const Map<String, String> platformBackgrounds = {
    'PlayStation': 'assets/images/bg_ps.jpg',
    'Xbox': 'assets/images/bg_xbox.jpg',
    'Ubisoft': 'assets/images/bg_ubisoft.jpeg',
    'Steam': 'assets/images/bg_steam.jpg',
    'Epic Games': 'assets/images/bg_epic.jpg',
  };

  static const Map<String, String> platformNames = {
    'PlayStation': 'PlayStation',
    'Xbox': 'Xbox',
    'Ubisoft': 'Ubisoft',
    'Steam': 'Steam',
    'Epic Games': 'Epic Games',
  };

  static const Map<String, List<Map<String, String>>> platformAccounts = {
    'PlayStation': [
      {
        'profileImage': 'assets/icons/profile.jpeg',
        'nickname': 'GamerX',
        'email': 'gamerx@example.com',
      },
      {
        'profileImage': 'assets/icons/profile.jpeg',
        'nickname': 'SniperQueen',
        'email': 'sniperq@example.com',
      },
    ],
    'Xbox': [
      {
        'profileImage': 'assets/icons/profile.jpeg',
        'nickname': 'ProDestroyer',
        'email': 'prodestroyer@example.com',
      },
      {
        'profileImage': 'assets/icons/profile.jpeg',
        'nickname': 'AceHunter',
        'email': 'acehunter@example.com',
      },
    ],
    // Agrega más plataformas si deseas
  };
}
