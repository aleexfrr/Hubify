import 'package:flutter/material.dart';

class LinkedAccountCard extends StatelessWidget {
  final String platform;
  final String nickname;
  final String profileImage;
  final VoidCallback? onTap;

  const LinkedAccountCard({
    super.key,
    required this.platform,
    required this.nickname,
    required this.profileImage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min, // ¡Esto elimina el espacio extra!
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: profileImage.isNotEmpty
                  ? Image.network(
                profileImage,
                width: double.infinity,
                height: 100,
                fit: BoxFit.cover,
              )
                  : Container(
                width: double.infinity,
                height: 100,
                color: Colors.grey[800],
                child: const Icon(Icons.person, size: 40, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    nickname,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    platform,
                    style: TextStyle(color: Colors.grey[300], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
