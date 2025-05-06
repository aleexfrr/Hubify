import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/navigation_rail_widget.dart';
import '../screens/friends_screen.dart';
import '../screens/platform_screen.dart';
import '../screens/login_screen.dart';
import '../constants/platform_data.dart'; // <-- importamos los logos

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRailWidget(
            selectedIndex: selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: _getScreen(selectedIndex),
          ),
        ],
      ),
    );
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 1:
        return FriendsScreen();
      case 2:
        return _buildPlatformScreen('PlayStation');
      case 3:
        return _buildPlatformScreen('Xbox');
      case 4:
        return _buildPlatformScreen('Ubisoft');
      case 5:
        return _buildPlatformScreen('Steam');
      case 6:
        return _buildPlatformScreen('Epic Games');
      case 7:
        return LoginScreen();
      default:
        return Center(
          child: Text(
            'Inicio',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        );
    }
  }

  Widget _buildPlatformScreen(String name) {
    final image = PlatformData.platformLogos[name] ?? '';
    final background = PlatformData.platformBackgrounds[name] ?? '';
    return PlatformScreen(
      platformName: name,
      platformImage: image,
      platformBackground: background,
    );
  }

}
