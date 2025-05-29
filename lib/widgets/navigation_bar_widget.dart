import 'package:flutter/material.dart';
import '../constants/platform_data.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const BottomNavigationBarWidget({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  Widget _platformIcon(String platformName) {
    final logoPath = PlatformData.platformLogos[platformName];
    return logoPath != null
        ? Image.asset(logoPath, width: 24, height: 24)
        : const Icon(Icons.videogame_asset);
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: _platformIcon('PlayStation'),
              title: const Text('PlayStation'),
              onTap: () {
                Navigator.pop(context);
                onItemTapped(2);
              },
            ),
            ListTile(
              leading: _platformIcon('Xbox'),
              title: const Text('Xbox'),
              onTap: () {
                Navigator.pop(context);
                onItemTapped(3);
              },
            ),
            ListTile(
              leading: _platformIcon('Ubisoft'),
              title: const Text('Ubisoft'),
              onTap: () {
                Navigator.pop(context);
                onItemTapped(4);
              },
            ),
            ListTile(
              leading: _platformIcon('Steam'),
              title: const Text('Steam'),
              onTap: () {
                Navigator.pop(context);
                onItemTapped(5);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ajuste: mapeo del índice real a visual para el NavigationBar
    int visualIndex;
    if (selectedIndex == 0 || selectedIndex == 1) {
      visualIndex = selectedIndex;
    } else if (selectedIndex == 6) {
      visualIndex = 3; // Ajustes
    } else {
      visualIndex = 2; // Plataformas
    }

    return NavigationBar(
      selectedIndex: visualIndex,
      onDestinationSelected: (int index) {
        switch (index) {
          case 0:
          case 1:
            onItemTapped(index);
            break;
          case 2:
            _showMoreOptions(context);
            break;
          case 3:
            onItemTapped(6); // Ajustes
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.people),
          label: 'Amigos',
        ),
        NavigationDestination(
          icon: Icon(Icons.videogame_asset),
          label: 'Plataformas',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: 'Ajustes',
        ),
      ],
    );
  }
}
