import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> get friendsStream {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const Stream.empty();

    return _firestore.collection('users').doc(userId).snapshots().asyncMap(
          (snapshot) async {
        final data = snapshot.data();
        if (data == null || data['friends'] == null) return [];

        final List<dynamic> friendIds = data['friends'];
        final friends = await Future.wait(friendIds.map((id) async {
          try {
            final friendDoc =
            await _firestore.collection('users').doc(id).get();
            final friendData = friendDoc.data();
            if (!friendDoc.exists || friendData == null) return null;

            return {
              'id': friendDoc.id,
              'username': friendData['username'] ?? 'Sin apodo',
              'name': friendData['name'] ?? 'Sin nombre',
              'status': friendData['status'] ?? 'offline',
            };
          } catch (e) {
            print('Error al obtener amigo $id: $e');
            return null;
          }
        }));

        return friends.whereType<Map<String, dynamic>>().toList();
      },
    );
  }
}
