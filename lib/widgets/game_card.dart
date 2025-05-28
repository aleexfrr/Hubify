import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  final Map<String, dynamic> juego;

  const GameCard({super.key, required this.juego});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (juego['image'] != null && juego['image'].isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                juego['image'],
                width: double.infinity,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(
                  juego['name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'Gamerscore: ${juego['gamerscore']}',
                  style: TextStyle(color: Colors.grey[300]),
                ),
                Text(
                  'Progreso: ${juego['progress']}%',
                  style: TextStyle(color: Colors.grey[300]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
