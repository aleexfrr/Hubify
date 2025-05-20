import 'package:flutter/material.dart';
import 'package:hubify/constants/status_data.dart';
import 'package:provider/provider.dart';
import '../providers/friend_provider.dart';
import '../widgets/friend_card.dart';
import 'add_friend_screen.dart';
import 'friend_requests_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
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
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.2 * 255).toInt()),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Buscar...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Ver solicitudes
                StreamBuilder<int>(
                  stream: friendProvider.pendingRequestsCountStream,
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;

                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((0.1 * 255).toInt()),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.group, color: Colors.white),
                            tooltip: 'Solicitudes de amistad',
                            onPressed: () {
                              // Aquí puedes abrir una pantalla modal o nueva pantalla
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FriendRequestsScreen(), // debes crear esta pantalla
                                ),
                              );
                            },
                          ),
                        ),
                        if (count > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Center(
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.1 * 255).toInt()),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.person_add, color: Colors.white),
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
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: friendProvider.friendsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text("Error al cargar amigos"));
              }

              final friends = snapshot.data ?? [];

              final filteredFriends = friends.where((friend) {
                final username = friend['username']?.toLowerCase() ?? '';
                return username.contains(_searchText);
              }).toList();

              if (filteredFriends.isEmpty) {
                return const Center(child: Text("No se encontraron amigos"));
              }

              return ListView.builder(
                itemCount: filteredFriends.length,
                itemBuilder: (context, index) {
                  final friend = filteredFriends[index];
                  return FriendCard(
                    username: friend['username']!,
                    status: friend['status']!,
                    statusColor: StatusData.statusColors[friend['status']]!,
                    friendId: friend['id'],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
