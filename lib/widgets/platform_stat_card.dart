import 'package:flutter/material.dart';

class PlatformStatCard extends StatelessWidget {
  final String platformName;
  final Map<String, dynamic> stats;

  const PlatformStatCard({
    super.key,
    required this.platformName,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              platformName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text('Total de juegos: ${stats['games']}', style: const TextStyle(color: Colors.white)),
            Text('Horas jugadas: ${stats['hours']}', style: const TextStyle(color: Colors.white)),
            // Agrega más estadísticas si lo deseas
          ],
        ),
      ),
    );
  }
}
