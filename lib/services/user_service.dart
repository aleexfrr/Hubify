import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Función para crear un documento de usuario en Firestore
  Future<void> createUserDocument({
    required String apodo,
    required String nombre,
    required String apellido,
    required String email,
    required String estado,
    required List<String> amigos,
  }) async {
    final user = _auth.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': apodo,
          'name': nombre,
          'lastname': apellido,
          'email': email,
          'status': estado,
          'friends':amigos,
          'createdAt': Timestamp.now(),
        });
      } catch (e) {
        throw Exception('Error al crear el documento de usuario: $e');
      }
    }
  }

  // Función para obtener los datos del usuario desde Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return userDoc.exists ? userDoc.data() : null;
    } catch (e) {
      throw Exception('Error al obtener los datos del usuario: $e');
    }
  }
}
