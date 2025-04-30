import 'package:flutter/material.dart';
import 'package:hubify/utils/text_styles.dart';

class PlatformScreen extends StatelessWidget {
  final String platformName;
  final String platformImage;
  final String platformBackground;

  PlatformScreen({
    required this.platformName,
    required this.platformImage,
    required this.platformBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo
        Positioned.fill(
          child: Image.asset(
            platformBackground,
            fit: BoxFit.cover,
          ),
        ),

        // Contenido
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (platformImage.isNotEmpty)
                Image.asset(platformImage, width: 48, height: 48),
              const SizedBox(height: 12),
              Text(
                'Contenido de $platformName',
                style: TextStyles.headerLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
