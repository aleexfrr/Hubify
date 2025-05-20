import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Busca usuarios por username (excluyendo al actual)
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final normalizedQuery = query.trim().toLowerCase();

    final results = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: normalizedQuery)
        .where('username', isLessThanOrEqualTo: '$normalizedQuery\uf8ff')
        .get();

    return results.docs
        .where((doc) => doc.id != userId)
        .map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['username'] ?? '',
        'status': data['status'] ?? 'offline',
      };
    }).toList();
  }

  /// Envía una solicitud de amistad
  Future<String?> sendFriendRequest(String targetUserId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return 'Usuario no autenticado.';
    if (userId == targetUserId) return 'No puedes enviarte una solicitud a ti mismo.';

    final userRef = _firestore.collection('users').doc(userId);
    final targetRef = _firestore.collection('users').doc(targetUserId);

    try {
      final userDoc = await userRef.get();
      final userData = userDoc.data();
      if (userData == null) return 'Usuario no encontrado.';

      final requestsSent = List<String>.from(userData['requestsSent'] ?? []);
      final friends = List<String>.from(userData['friends'] ?? []);

      if (requestsSent.contains(targetUserId)) return 'Ya has enviado una solicitud.';
      if (friends.contains(targetUserId)) return 'Este usuario ya es tu amigo.';

      final targetDoc = await targetRef.get();
      if (!targetDoc.exists) return 'El usuario no existe.';

      await userRef.update({
        'requestsSent': FieldValue.arrayUnion([targetUserId]),
      });
      await targetRef.update({
        'friendRequests': FieldValue.arrayUnion([userId]),
      });

      return null;
    } catch (e) {
      print('Error al enviar solicitud: $e');
      return 'Error al enviar la solicitud.';
    }
  }

  /// Acepta una solicitud de amistad
  Future<String?> acceptFriendRequest(String requesterId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return 'Usuario no autenticado.';

    final userRef = _firestore.collection('users').doc(userId);
    final requesterRef = _firestore.collection('users').doc(requesterId);

    try {
      await userRef.update({
        'friends': FieldValue.arrayUnion([requesterId]),
        'friendRequests': FieldValue.arrayRemove([requesterId]),
      });
      await requesterRef.update({
        'friends': FieldValue.arrayUnion([userId]),
        'requestsSent': FieldValue.arrayRemove([userId]),
      });

      return null;
    } catch (e) {
      print('Error al aceptar solicitud: $e');
      return 'Error al aceptar la solicitud.';
    }
  }

  /// Cancela o rechaza una solicitud de amistad
  Future<String?> cancelOrRejectRequest(String otherUserId, {bool sentByMe = true}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return 'Usuario no autenticado.';

    final userRef = _firestore.collection('users').doc(userId);
    final otherRef = _firestore.collection('users').doc(otherUserId);

    try {
      if (sentByMe) {
        await userRef.update({
          'requestsSent': FieldValue.arrayRemove([otherUserId]),
        });
        await otherRef.update({
          'friendRequests': FieldValue.arrayRemove([userId]),
        });
      } else {
        await userRef.update({
          'friendRequests': FieldValue.arrayRemove([otherUserId]),
        });
        await otherRef.update({
          'requestsSent': FieldValue.arrayRemove([userId]),
        });
      }
      return null;
    } catch (e) {
      print('Error al cancelar/rechazar solicitud: $e');
      return 'Error al procesar la solicitud.';
    }
  }

  /// Obtiene las solicitudes recibidas con información de usuario
  Future<List<Map<String, dynamic>>> getReceivedRequestsDetailed() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final userDoc = await _firestore.collection('users').doc(userId).get();
    final data = userDoc.data();
    final requestIds = List<String>.from(data?['friendRequests'] ?? []);
    if (requestIds.isEmpty) return [];

    final users = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: requestIds)
        .get();

    return users.docs.map((doc) => {
      'id': doc.id,
      'name': doc['username'] ?? '',
      'status': doc['status'] ?? 'offline',
    }).toList();
  }

  /// Obtiene las solicitudes enviadas con información de usuario
  Future<List<Map<String, dynamic>>> getSentRequestsDetailed() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final userDoc = await _firestore.collection('users').doc(userId).get();
    final data = userDoc.data();
    final sentIds = List<String>.from(data?['requestsSent'] ?? []);
    if (sentIds.isEmpty) return [];

    final users = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: sentIds)
        .get();

    return users.docs.map((doc) => {
      'id': doc.id,
      'name': doc['username'] ?? '',
      'status': doc['status'] ?? 'offline',
    }).toList();
  }

  /// Elimina un amigo del usuario actual
  Future<String?> removeFriend(String friendId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return 'Usuario no autenticado.';

    final userRef = _firestore.collection('users').doc(userId);
    final friendRef = _firestore.collection('users').doc(friendId);

    try {
      await userRef.update({
        'friends': FieldValue.arrayRemove([friendId]),
      });
      await friendRef.update({
        'friends': FieldValue.arrayRemove([userId]),
      });

      return null;
    } catch (e) {
      print('Error al eliminar amigo: $e');
      return 'Error al eliminar amigo.';
    }
  }

  /// Stream de lista de amigos (con detalles) en tiempo real
  Stream<List<Map<String, dynamic>>> friendListStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const Stream.empty();

    return _firestore.collection('users').doc(userId).snapshots().asyncMap((snapshot) async {
      final data = snapshot.data();
      final friendIds = List<String>.from(data?['friends'] ?? []);
      if (friendIds.isEmpty) return [];

      final friendsSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds)
          .get();

      return friendsSnapshot.docs.map((doc) => {
        'id': doc.id,
        'name': doc['username'] ?? '',
        'status': doc['status'] ?? 'offline',
      }).toList();
    });
  }

  /// Stream de solicitudes recibidas en tiempo real
  Stream<List<Map<String, dynamic>>> receivedRequestsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const Stream.empty();

    return _firestore.collection('users').doc(userId).snapshots().asyncMap((snapshot) async {
      final data = snapshot.data();
      final requestIds = List<String>.from(data?['friendRequests'] ?? []);
      if (requestIds.isEmpty) return [];

      final usersSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: requestIds)
          .get();

      return usersSnapshot.docs.map((doc) => {
        'id': doc.id,
        'name': doc['username'] ?? '',
        'status': doc['status'] ?? 'offline',
      }).toList();
    });
  }
}
