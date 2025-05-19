import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Busca usuarios por username
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

  /// Agrega un amigo al usuario actual con validaciones
  Future<String?> addFriend(String friendId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return 'Usuario no autenticado.';
    if (friendId == userId) return 'No puedes agregarte a ti mismo.';

    final userRef = _firestore.collection('users').doc(userId);
    final friendRef = _firestore.collection('users').doc(friendId);

    try {
      // Verificar si el usuario que se quiere agregar existe
      final friendDoc = await friendRef.get();
      if (!friendDoc.exists) return 'El usuario no existe.';

      // Obtener la lista actual de amigos del usuario
      final userDoc = await userRef.get();
      final userData = userDoc.data();
      final List<dynamic> currentFriends = userData?['friends'] ?? [];

      if (currentFriends.contains(friendId)) {
        return 'Este usuario ya está en tu lista de amigos.';
      }

      // Agregar amigo (sin duplicados gracias a arrayUnion)
      await userRef.update({
        'friends': FieldValue.arrayUnion([friendId]),
      });
      await friendRef.update({
        'friends': FieldValue.arrayUnion([userId]),
      });

      return null; // null = éxito
    } catch (e) {
      print('Error al agregar amigo: $e');
      return 'Error al agregar amigo.';
    }
  }

  /// Elimina un amigo del usuario actual
  Future<String?> removeFriend(String friendId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return 'Usuario no autenticado.';

    final userRef = _firestore.collection('users').doc(userId);
    final friendRef = _firestore.collection('users').doc(friendId);

    try {
      // Eliminar el amigo del array del usuario
      await userRef.update({
        'friends': FieldValue.arrayRemove([friendId]),
      });

      // Eliminar al usuario actual del array del amigo
      await friendRef.update({
        'friends': FieldValue.arrayRemove([userId]),
      });

      return null; // null = éxito
    } catch (e) {
      print('Error al eliminar amigo: $e');
      return 'Error al eliminar amigo.';
    }
  }
}
