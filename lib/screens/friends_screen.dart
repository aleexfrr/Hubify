import 'package:flutter/material.dart';
import '../widgets/friend_card.dart';

class FriendsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            // color: Colors.blueAccent,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 1100), // Limita el ancho
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.person_add, color: Colors.white),
                    tooltip: 'Agregar amigo',
                    onPressed: () {
                      // Acción al presionar
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_friends.jpg',
              fit: BoxFit.cover,
            ),
          ),
          ListView(
            children: [
              FriendCard(
                name: 'Sarah Johnson',
                status: 'Online',
                statusColor: Colors.green,
              ),
              FriendCard(
                name: 'Michael Chen',
                status: 'Offline',
                statusColor: Colors.red,
              ),
              FriendCard(
                name: 'Jessica Taylor',
                status: 'Ocupado',
                statusColor: Colors.yellow,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
