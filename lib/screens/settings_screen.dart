import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hubify/screens/login_screen.dart';
import 'package:hubify/utilities/text_styles.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // final user = "alex"; // Simulación de usuario logueado

    if (user == null) {
      return const LoginScreen(); // Si no está logueado, mostrar login
    }

    final themeProvider = Provider.of<ThemeProvider>(context);

    final sectionTitleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Ajustes', style: TextStyles.headerLarge),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Cuenta', style: sectionTitleStyle),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () {
              // Navegar a pantalla de perfil
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Correo electrónico'),
            onTap: () {},
          ),
          const Divider(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Notificaciones', style: sectionTitleStyle),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Notificaciones generales'),
            value: notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
          const Divider(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Apariencia', style: sectionTitleStyle),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Tema oscuro'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              setState(() {}); // Fuerza el rebuild para mostrar el login
            },
          ),
        ],
      ),
    );
  }
}
