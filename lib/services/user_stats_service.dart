// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../web_service/xbox_ws.dart';
// import '../web_service/ps_ws.dart';

class UserStatsService {
  Future<Map<String, dynamic>> getAllPlatformStats() async {
    // Simulación de datos reales
    await Future.delayed(const Duration(seconds: 1));
    return {
      'Steam': {'games': 42, 'hours': 1200},
      'PlayStation': {'games': 30, 'hours': 900},
      'Xbox': {'games': 15, 'hours': 400},
      'Ubisoft': {'games': 5, 'hours': 100},
    };
  }

  // Future<Map<String, dynamic>> getAllPlatformStats() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return {};
  //
  //   final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  //   final platforms = userDoc.data()?['platforms'] as List<dynamic>? ?? [];
  //
  //   final Map<String, dynamic> stats = {};
  //
  //   for (var platform in platforms) {
  //     final type = (platform['type'] ?? '').toString().toLowerCase();
  //     final id = platform['id'];
  //
  //     try {
  //       if (type == 'xbox') {
  //         final result = await XboxWebService.getEstadisticasCuentaXbox(id);
  //         stats['Xbox'] = {
  //           'games': result['totalGames'] ?? 0,
  //           'hours': result['totalHours'] ?? 0,
  //         };
  //       } else if (type == 'playstation') {
  //         final result = await PSWebService.obtenerEstadisticasPorAccountId(id);
  //         stats['PlayStation'] = {
  //           'games': result['totalGames'] ?? 0,
  //           'hours': result['totalHours'] ?? 0,
  //         };
  //       }
  //       // Puedes añadir Steam y Ubisoft cuando sus servicios estén disponibles
  //     } catch (e) {
  //       print('Error obteniendo stats de $type: $e');
  //     }
  //   }
  //
  //   return stats;
  // }
}
