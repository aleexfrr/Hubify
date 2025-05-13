import 'package:flutter/material.dart';
import 'package:hubify/services/friend_service.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FriendService _friendService = FriendService();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String? _searchError;

  void _searchUser() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchError = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchError = null;
    });

    try {
      final results = await _friendService.searchUsers(query);
      setState(() {
        _searchResults = results;
        _searchError = results.isEmpty ? 'No se encontraron usuarios.' : null;
      });
    } catch (e) {
      setState(() {
        _searchError = 'Error al buscar usuarios.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addFriend(String friendId) async {
    try {
      await _friendService.addFriend(friendId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amigo agregado exitosamente')),
      );
      _searchUser(); // Refrescar resultados
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al agregar amigo')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Amigo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _searchController,
              onFieldSubmitted: (_) => _searchUser(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Buscar por nombre',
                labelStyle: const TextStyle(color: Colors.white),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                errorText: _searchError,
                errorStyle: const TextStyle(color: Colors.redAccent),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  return ListTile(
                    title: Text(user['name']),
                    subtitle: Text('Estado: ${user['status']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.person_add),
                      onPressed: () => _addFriend(user['id']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
