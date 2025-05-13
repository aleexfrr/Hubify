import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Obtener la lista de amigos del usuario actual
  Future<List<Map<String, dynamic>>> getFriends() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final userDoc = await _firestore.collection('users').doc(userId).get();
    final List<dynamic> friendIds = userDoc.data()?['friends'] ?? [];

    final friends = await Future.wait(friendIds.map((id) async {
      final friendDoc = await _firestore.collection('users').doc(id).get();
      return {
        'id': friendDoc.id,
        'name': friendDoc['name'],
        'status': friendDoc['status'],
      };
    }));

    return friends;
  }

  /// Buscar usuarios por nombre para poder agregarlos
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final currentUserId = _auth.currentUser?.uid;
    final result = await _firestore
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .get();

    return result.docs
        .where((doc) => doc.id != currentUserId) // Excluir a uno mismo
        .map((doc) => {
      'id': doc.id,
      'name': doc['name'],
      'status': doc['status'],
    })
        .toList();
  }

  /// Agregar un nuevo amigo
  Future<void> addFriend(String friendId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || friendId == userId) return;

    final userRef = _firestore.collection('users').doc(userId);
    final friendRef = _firestore.collection('users').doc(friendId);

    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final friendSnapshot = await transaction.get(friendRef);

      if (!userSnapshot.exists || !friendSnapshot.exists) return;

      List<dynamic> userFriends = userSnapshot['friends'] ?? [];
      List<dynamic> friendFriends = friendSnapshot['friends'] ?? [];

      if (!userFriends.contains(friendId)) {
        transaction.update(userRef, {
          'friends': [...userFriends, friendId],
        });
      }

      if (!friendFriends.contains(userId)) {
        transaction.update(friendRef, {
          'friends': [...friendFriends, userId],
        });
      }
    });
  }
}
