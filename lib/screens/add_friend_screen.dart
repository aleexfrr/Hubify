import 'package:flutter/material.dart';
import '../services/friend_service.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FriendService _friendService = FriendService();

  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _sentRequests = [];
  bool _isLoading = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _loadSentRequests();
  }

  Future<void> _loadSentRequests() async {
    final requests = await _friendService.getSentRequestsDetailed();
    setState(() {
      _sentRequests = requests;
    });
  }

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

  void _sendFriendRequest(String friendId) async {
    setState(() => _isLoading = true);
    final result = await _friendService.sendFriendRequest(friendId);
    setState(() => _isLoading = false);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud enviada con éxito')),
      );
      _loadSentRequests(); // Refresca la lista de solicitudes enviadas
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
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
                labelText: 'Buscar por nickname',
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
                  final alreadyRequested = _sentRequests.contains(user['id']);

                  return ListTile(
                    title: Text(user['name']),
                    subtitle: Text('Estado: ${user['status']}'),
                    trailing: alreadyRequested
                        ? const Text('Solicitado', style: TextStyle(color: Colors.grey))
                        : IconButton(
                      icon: const Icon(Icons.person_add),
                      onPressed: () => _sendFriendRequest(user['id']),
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
