import 'package:flutter/material.dart';
import 'package:hubify/utilities/text_styles.dart';
import 'package:hubify/screens/user_profile_screen.dart';
import 'package:hubify/services/friend_service.dart';

class FriendCard extends StatelessWidget {
  final String username;
  final String status;
  final Color statusColor;
  final String friendId;

  const FriendCard({
    super.key,
    required this.username,
    required this.status,
    required this.statusColor,
    required this.friendId,
  });

  void _deleteFriend(BuildContext context) async {
    final friendService = FriendService();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            '¿Eliminar amigo?',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
            '¿Estás seguro de que quieres eliminar a $username de tus amigos?',
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await friendService.removeFriend(friendId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result ?? '$username ha sido eliminado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Stack(
          children: [
            const CircleAvatar(
              backgroundImage: NetworkImage(''), // Imagen pendiente
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
        subtitle: Text(status, style: TextStyles.status(statusColor)),
        trailing: Theme(
          data: Theme.of(context).copyWith(
            popupMenuTheme: PopupMenuThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          child: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') _deleteFriend(context);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Eliminar amigo',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfileScreen(userId: friendId),
            ),
          );
        },
      ),
    );
  }
}
