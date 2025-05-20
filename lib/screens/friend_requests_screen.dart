import 'package:flutter/material.dart';
import '../services/friend_service.dart';
import '../utilities/text_styles.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen>
    with SingleTickerProviderStateMixin {
  final FriendService _friendService = FriendService();
  late TabController _tabController;

  List<Map<String, dynamic>> _receivedRequests = [];
  List<Map<String, dynamic>> _sentRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final received = await _friendService.getReceivedRequestsDetailed();
      final sent = await _friendService.getSentRequestsDetailed();
      setState(() {
        _receivedRequests = received;
        _sentRequests = sent;
      });
    } catch (e) {
      // Manejo de errores opcional
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _accept(String senderId) async {
    setState(() => _isLoading = true);
    final result = await _friendService.acceptFriendRequest(senderId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result ?? 'Amigo agregado')),
    );
    _loadRequests();
  }

  void _reject(String senderId) async {
    setState(() => _isLoading = true);
    final result = await _friendService.cancelOrRejectRequest(senderId, sentByMe: false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result ?? 'Solicitud rechazada')),
    );
    _loadRequests();
  }

  void _cancel(String targetId) async {
    setState(() => _isLoading = true);
    final result = await _friendService.cancelOrRejectRequest(targetId, sentByMe: true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result ?? 'Solicitud cancelada')),
    );
    _loadRequests();
  }

  Widget _buildReceivedRequests() {
    if (_receivedRequests.isEmpty) {
      return const Center(child: Text('No tienes solicitudes pendientes.'));
    }
    return ListView.builder(
      itemCount: _receivedRequests.length,
      itemBuilder: (context, index) {
        final user = _receivedRequests[index];
        return ListTile(
          title: Text(user['name']),
          subtitle: Text('Estado: ${user['status']}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () => _accept(user['id']),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _reject(user['id']),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSentRequests() {
    if (_sentRequests.isEmpty) {
      return const Center(child: Text('No has enviado solicitudes.'));
    }
    return ListView.builder(
      itemCount: _sentRequests.length,
      itemBuilder: (context, index) {
        final user = _sentRequests[index];
        return ListTile(
          title: Text(user['name']),
          subtitle: Text('Estado: ${user['status']}'),
          trailing: IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => _cancel(user['id']),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitudes de amistad', style: TextStyles.headerLarge),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Recibidas'),
            Tab(text: 'Enviadas'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildReceivedRequests(),
          _buildSentRequests(),
        ],
      ),
    );
  }
}
