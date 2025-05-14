import 'package:flutter/material.dart';
import 'package:hubify/utilities/text_styles.dart';

class FriendCard extends StatelessWidget {
  final String username;
  final String status;
  final Color statusColor;

  const FriendCard({
    super.key,
    required this.username,
    required this.status,
    required this.statusColor,
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
      ),
    );
  }
}
