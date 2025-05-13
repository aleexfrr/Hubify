import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hubify/screens/login_screen.dart';
import 'package:hubify/screens/profile_screen.dart';
import 'package:hubify/utilities/text_styles.dart';
import 'package:hubify/widgets/custom_dialog.dart';
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

    if (user == null) {
      return const LoginScreen();
    }

    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ajustes', style: TextStyles.headerLarge),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== Cuenta =====
          Text('Cuenta', style: TextStyles.sectionTitleStyle(context)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Perfil'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Conexiones vinculadas'),
                  onTap: () {
                    // Acción
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ===== Notificaciones =====
          Text('Notificaciones', style: TextStyles.sectionTitleStyle(context)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications),
              title: const Text('Notificaciones generales'),
              value: notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // ===== Apariencia =====
          Text('Apariencia', style: TextStyles.sectionTitleStyle(context)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: const Text('Tema oscuro'),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
          ),

          const SizedBox(height: 24),

          // ===== Cerrar sesión =====
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                CustomDialog.showLogoutDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
