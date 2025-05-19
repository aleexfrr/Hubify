import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/status_data.dart';
import '../utilities/text_styles.dart';
import 'edit_profile_screen.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;
  final bool isCurrentUser;

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isCurrentUser ? 'Mi Perfil' : 'Perfil del Amigo',
          style: TextStyles.headerLarge,
        ),
        centerTitle: true,
        actions: isCurrentUser
            ? [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
            },
          )
        ]
            : null,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyles.body));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Usuario no encontrado'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/default_avatar.png'),
                  backgroundColor: Colors.grey[800],
                ),
                const SizedBox(height: 20),
                Text(
                  data['name'] ?? 'Nombre no disponible',
                  style: TextStyles.headerLarge.copyWith(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  '@${data['username'] ?? 'sin_apodo'}',
                  style: TextStyles.caption.copyWith(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 30),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  color: Colors.grey[900],
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email, color: Colors.white),
                        title: Text(
                          'Correo electrónico',
                          style: TextStyles.sectionTitleStyle(context),
                        ),
                        subtitle: Text(
                          data['email'] ?? 'No disponible',
                          style: TextStyles.body,
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.circle, color: StatusData.statusColors[data['status']], size: 16),
                        title: Text(
                          'Estado',
                          style: TextStyles.sectionTitleStyle(context),
                        ),
                        subtitle: Text(
                          data['status'] ?? 'No disponible',
                          style: TextStyles.body.copyWith(
                            color: StatusData.statusColors[data['status']] ?? Colors.white,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.group, color: Colors.white),
                        title: Text(
                          'Amigos',
                          style: TextStyles.sectionTitleStyle(context),
                        ),
                        subtitle: Text(
                          '${(data['friends'] as List?)?.length ?? 0} amigos',
                          style: TextStyles.body,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
