import 'package:flutter/material.dart';
import '../constants/platform_data.dart';

class NavigationRailWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const NavigationRailWidget({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  Widget _platformIcon(String platformName) {
    final logoPath = PlatformData.platformLogos[platformName];
    return logoPath != null
        ? Image.asset(
      logoPath,
      width: 24,
      height: 24,
    )
        : Icon(Icons.videogame_asset); // Fallback por si falta algún logo
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Fondo del rail (puedes cambiar el color)
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30), // Esquina superior derecha redondeada
          bottomRight: Radius.circular(30), // Esquina inferior derecha redondeada
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26, // Sombra del borde
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // Desplazamiento de la sombra
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30), // Asegúrate de que el contenedor también tenga el borde redondeado
          bottomRight: Radius.circular(30),
        ),
        child: NavigationRail(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          labelType: NavigationRailLabelType.all,
          destinations: [
            NavigationRailDestination(
              icon: Icon(Icons.home),
              label: Text('Inicio'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.people),
              label: Text('Amigos'),
            ),
            NavigationRailDestination(
              icon: _platformIcon('PlayStation'),
              label: Text('PlayStation'),
            ),
            NavigationRailDestination(
              icon: _platformIcon('Xbox'),
              label: Text('Xbox'),
            ),
            NavigationRailDestination(
              icon: _platformIcon('Ubisoft'),
              label: Text('Ubisoft'),
            ),
            NavigationRailDestination(
              icon: _platformIcon('Steam'),
              label: Text('Steam'),
            ),
            NavigationRailDestination(
              icon: _platformIcon('Epic Games'),
              label: Text('Epic Games'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.settings),
              label: Text('Ajustes'),
            ),
          ],
        ),
      ),
    );
  }
}
