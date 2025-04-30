import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  bool isExpanded = false; // Estado para controlar si la barra está expandida
  int selectedIndex = 0; // Índice del elemento seleccionado en el NavigationRail

  @override
  Widget build(BuildContext context) {
    final TextStyle unselectedTextStyle = GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    );

    final TextStyle selectedTextStyle = GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color.fromARGB(255, 40, 126, 240),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // NavigationRail para el menú lateral
          NavigationRail(
            backgroundColor: Color(0xFF121212),
            extended: isExpanded, // Controla si la barra está expandida o colapsada
            selectedIndex: selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                selectedIndex = index;
              });
            },
            leading: GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded; // Cambia el estado al pulsar
                });
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.menu, color: Colors.white),
                  ),
                  if (isExpanded)
                    Text(
                      'Menú',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.home, color: Colors.white),
                selectedIcon: Icon(Icons.home, color: Color.fromARGB(255, 40, 126, 240)),
                label: Text(
                  'Inicio',
                  style: selectedIndex == 0 ? selectedTextStyle : unselectedTextStyle,
                ),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people, color: Colors.white),
                selectedIcon: Icon(Icons.people, color: Color.fromARGB(255, 40, 126, 240)),
                label: Text(
                  'Amigos',
                  style: selectedIndex == 1 ? selectedTextStyle : unselectedTextStyle,
                ),
              ),
              NavigationRailDestination(
                icon: Image.asset('assets/icons/ps.png', width: 24, height: 24),
                selectedIcon: Image.asset('assets/icons/ps.png', width: 24, height: 24, color: Color.fromARGB(255, 40, 126, 240)),
                label: Text(
                  'PlayStation',
                  style: selectedIndex == 2 ? selectedTextStyle : unselectedTextStyle,
                ),
              ),
              NavigationRailDestination(
                icon: Image.asset('assets/icons/xbox.png', width: 24, height: 24),
                selectedIcon: Image.asset('assets/icons/xbox.png', width: 24, height: 24, color: Color.fromARGB(255, 40, 126, 240)),
                label: Text(
                  'Xbox',
                  style: selectedIndex == 3 ? selectedTextStyle : unselectedTextStyle,
                ),
              ),
              NavigationRailDestination(
                icon: Image.asset('assets/icons/nintendo.png', width: 24, height: 24),
                selectedIcon: Image.asset('assets/icons/nintendo.png', width: 24, height: 24, color: Color.fromARGB(255, 40, 126, 240)),
                label: Text(
                  'Nintendo',
                  style: selectedIndex == 4 ? selectedTextStyle : unselectedTextStyle,
                ),
              ),
              NavigationRailDestination(
                icon: Image.asset('assets/icons/steam.png', width: 24, height: 24),
                selectedIcon: Image.asset('assets/icons/steam.png', width: 24, height: 24, color: Color.fromARGB(255, 40, 126, 240)),
                label: Text(
                  'Steam',
                  style: selectedIndex == 5 ? selectedTextStyle : unselectedTextStyle,
                ),
              ),
              NavigationRailDestination(
                icon: Image.asset('assets/icons/epicgames.png', width: 24, height: 24),
                selectedIcon: Image.asset('assets/icons/epicgames.png', width: 24, height: 24, color: Color.fromARGB(255, 40, 126, 240)),
                label: Text(
                  'Epic Games',
                  style: selectedIndex == 6 ? selectedTextStyle : unselectedTextStyle,
                ),
              ),
              // Espaciador para empujar "Ajustes" hacia abajo
              NavigationRailDestination(
                icon: SizedBox.shrink(), // Empty space
                label: SizedBox.shrink(),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings, color: Colors.white),
                selectedIcon: Icon(Icons.settings, color: Color.fromARGB(255, 40, 126, 240)),
                label: Text(
                  'Ajustes',
                  style: selectedIndex == 7 ? selectedTextStyle : unselectedTextStyle,
                ),
              ),
            ],
          ),
          // Contenido principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Divider(color: Colors.white.withOpacity(0.2)),
                  Expanded(
                    child: ListView(
                      children: [
                        if (selectedIndex == 0) ...[
                          Center(
                            child: Text(
                              'Inicio vacío',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ] else if (selectedIndex == 1) ...[
                          _buildFriendCard(
                            name: 'Sarah Johnson',
                            status: 'Online',
                            statusColor: Colors.green,
                            bodyLargeStyle: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            bodySmallStyle: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          _buildFriendCard(
                            name: 'Michael Chen',
                            status: 'Offline',
                            statusColor: Color(0xFFFF5963),
                            bodyLargeStyle: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            bodySmallStyle: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          _buildFriendCard(
                            name: 'Jessica Taylor',
                            status: 'Ocupado',
                            statusColor: Color(0xFFF9A825), // Amarillo oscuro
                            bodyLargeStyle: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            bodySmallStyle: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ] else if (selectedIndex >= 2 && selectedIndex <= 7) ...[
                          Center(
                            child: Text(
                              'Contenido de ${_getPlatformName(selectedIndex)}',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPlatformName(int index) {
    switch (index) {
      case 2:
        return 'PlayStation';
      case 3:
        return 'Xbox';
      case 4:
        return 'Nintendo';
      case 5:
        return 'Steam';
      case 6:
        return 'Epic Games';
      case 7:
        return 'Ajustes';
      default:
        return '';
    }
  }

  Widget _buildFriendCard({
    required String name,
    required String status,
    required Color statusColor,
    required TextStyle bodyLargeStyle,
    required TextStyle bodySmallStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF121212),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFF1E1E1E),
                    backgroundImage: NetworkImage(''), // Add image URL here
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 6,
                      backgroundColor: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: bodyLargeStyle),
                    Text(status, style: bodySmallStyle.copyWith(color: statusColor)),
                  ],
                ),
              ),
              Icon(Icons.more_vert, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}