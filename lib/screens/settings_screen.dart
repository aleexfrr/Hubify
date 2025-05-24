import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hubify/screens/linked_accounts_screen.dart';
import 'package:hubify/screens/user_profile_screen.dart';
import 'package:hubify/utilities/text_styles.dart';
import 'package:hubify/widgets/custom_dialog.dart';
import 'package:provider/provider.dart';
import 'package:hubify/providers/theme_provider.dart';
import 'package:hubify/services/user_service.dart';
import 'home_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final userService = UserService();

    try {
      await userService.deleteUserAccount();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      final errorMsg = e.toString();

      if (errorMsg.contains('Debes volver a iniciar sesión')) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Debes volver a iniciar sesión para eliminar tu cuenta.'),
            ),
          );

          await FirebaseAuth.instance.signOut();

          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar la cuenta: $errorMsg')),
          );
        }
      }
    }
  }

  Future<void> _handleDisableAccount(BuildContext context) async {
    final userService = UserService();

    try {
      await userService.disableUserAccount();
      await FirebaseAuth.instance.signOut();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al deshabilitar la cuenta: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserProfileScreen(userId: currentUserId, isCurrentUser: true)),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Conexiones vinculadas'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LinkedAccountsScreen()),
                    );
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

          // ===== Gestión de cuenta =====
          Text('Gestión de cuenta', style: TextStyles.sectionTitleStyle(context)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_off),
                  title: const Text('Deshabilitar cuenta'),
                  onTap: () {
                    CustomDialog.show(context, type: DialogType.desactivateAccount,
                      onConfirm: () async {
                        await _handleDisableAccount(context);
                      },
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                      'Eliminar cuenta',
                      style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    CustomDialog.show(context, type: DialogType.deleteAccount,
                      onConfirm: () async {
                        await _handleDeleteAccount(context);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
                CustomDialog.show(context, type: DialogType.logout);
              },
            ),
          ),
        ],
      ),
    );
  }
}
