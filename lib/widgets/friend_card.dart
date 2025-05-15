import 'package:flutter/material.dart';
import 'package:hubify/utilities/text_styles.dart';
import 'package:hubify/screens/user_profile_screen.dart';  // Asegúrate de importar la pantalla de detalles

class FriendCard extends StatelessWidget {
  final String username;
  final String status;
  final Color statusColor;
  final String friendId;  // Añadimos el friendId para navegar a la pantalla de detalles

  const FriendCard({
    super.key,
    required this.username,
    required this.status,
    required this.statusColor,
    required this.friendId,  // Recibimos el friendId
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(''), // URL de la imagen
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
        title: Text(username),
        subtitle:
        Text(
            status,
            style: TextStyles.status(statusColor)
        ),
        trailing: Icon(Icons.more_vert),
        onTap: () {
          // Navegar a la pantalla de detalles del amigo
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfileScreen(userId: friendId),  // Pasamos el friendId
            ),
          );
        },
      ),
    );
  }
}
