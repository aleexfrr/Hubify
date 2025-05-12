import 'package:flutter/material.dart';
import 'package:hubify/utilities/text_styles.dart';
import 'package:hubify/widgets/profile_card.dart';

import '../constants/platform_data.dart';

class PlatformScreen extends StatelessWidget {
  final String platformName;
  final String platformImage;
  final String platformBackground;

  const PlatformScreen({
    super.key,
    required this.platformName,
    required this.platformImage,
    required this.platformBackground,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> accountData =
        PlatformData.platformAccounts[platformName] ?? [];

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
        Column(
          children: [
            const SizedBox(height: 60),
            if (platformImage.isNotEmpty)
              Image.asset(platformImage, width: 48, height: 48),
            const SizedBox(height: 12),
            Text(
              'Cuentas de $platformName',
              style: TextStyles.headerLarge,
            ),
            const SizedBox(height: 16),

            // Grid centrado con ProfileCards
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 450,
                  child: GridView.builder(
                    itemCount: accountData.length,
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      final account = accountData[index];
                      return ProfileCard(
                        profileImage: account['profileImage']!,
                        nickname: account['nickname']!,
                        email: account['email']!,
                        onTap: () {
                          // Acción personalizada
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
