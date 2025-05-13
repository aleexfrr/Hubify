import 'package:flutter/material.dart';
import '../services/friend_service.dart'; // Importa el servicio de amigos
import '../widgets/friend_card.dart';
import 'add_friend_screen.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  // Función para cargar los amigos utilizando FriendService
  Future<List<Map<String, dynamic>>> _getFriends() async {
    final FriendService friendService = FriendService();
    return await friendService.getFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
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
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.2 * 255).toInt()),
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
                SizedBox(width: 12),
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.1 * 255).toInt()),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.person_add, color: Colors.white),
                    tooltip: 'Agregar amigo',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddFriendScreen()),
                      );
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
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _getFriends(), // Llama al método para obtener los amigos
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Error al cargar los amigos"));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                // return Center(child: Text("No tienes amigos aún"));

                final exampleFriends = [
                  {'name': 'Sarah Johnson', 'status': 'Online', 'statusColor': Colors.green},
                  {'name': 'Michael Chen', 'status': 'Offline', 'statusColor': Colors.red},
                  {'name': 'Jessica Taylor', 'status': 'Ocupado', 'statusColor': Colors.yellow},
                ];

                return ListView.builder(
                  itemCount: exampleFriends.length,
                  itemBuilder: (context, index) {
                    final friend = exampleFriends[index];
                    return FriendCard(
                      name: friend['name'] as String,
                      status: friend['status'] as String,
                      statusColor: friend['statusColor'] as Color,
                    );
                  },
                );
              }

              // Carga los amigos en la interfaz
              return ListView(
                children: snapshot.data!.map((friend) {
                  return FriendCard(
                    name: friend['name'],
                    status: friend['status'],
                    statusColor: Color(int.parse(friend['statusColor'])),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
