import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hubify/constants/status_data.dart';

class PSWebService {
  static final String _baseUrl = "http://${StatusData.ipAddress}:3000/psn";

  /// Obtiene el perfil de PSN por nombre de usuario (onlineId)
  static Future<Map<String, dynamic>> obtenerPerfilPorNombre(String nombre) async {
  final url = Uri.parse('$_baseUrl/cuenta/nombre/$nombre');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['profile']; // 👈 devolver directamente el perfil
  } else {
    throw Exception('Error al obtener perfil PSN: ${response.statusCode}');
  }
}

  static Future<Map<String, dynamic>> obtenerPerfilPorAccountId(String accountId) async {
    final url = Uri.parse('$_baseUrl/cuenta/accountId/$accountId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final onlineId = data['onlineId'];
      final avatars = data['avatars'] as List<dynamic>?;

      // Estructura compatible con tu widget: avatarUrls (nombre arbitrario pero esperado por tu UI)
      final avatarUrls = avatars != null
          ? avatars.map((a) => {
        'size': a['size'],
        'avatarUrl': a['url'],
      }).toList()
          : [];

      return {
        'onlineId': onlineId,
        'avatarUrls': avatarUrls,
      };
    } else {
      throw Exception('Error al obtener perfil PSN: ${response.statusCode}');
    }
  }




  /// Obtiene la lista de juegos asociada a un accountId de PSN
  static Future<List<Map<String, dynamic>>> obtenerJuegosPorAccountId(String accountId) async {
  final url = Uri.parse('$_baseUrl/cuenta/juegos/$accountId');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data is Map && data['titles'] is List) {
      final List<dynamic> titles = data['titles'];

      return titles.map<Map<String, dynamic>>((title) {
        // Extraer la imagen preferida; si existe 'imageUrl' directo o de media.images
        String imageUrl = title['imageUrl'] ?? '';

        // Podrías también intentar tomar la imagen 'MASTER' dentro de media.images, si quieres ser más preciso:
        if ((title['media']?['images'] ?? []).isNotEmpty) {
          // Buscar imagen tipo "MASTER"
          final masterImage = (title['media']['images'] as List).firstWhere(
            (img) => img['type'] == 'MASTER',
            orElse: () => null,
          );
          if (masterImage != null && masterImage['url'] != null) {
            imageUrl = masterImage['url'];
          }
        }

        return {
          'name': title['name'] ?? 'Nombre no disponible',
          'image': imageUrl,
          'trophies': title['playCount'] ?? 0, // No hay campo 'trophies' en el JSON dado, uso playCount como ejemplo
          'category': title['category'] ?? 'Desconocido',
          'titleId': title['titleId'] ?? '',
          'playDuration': title['playDuration'] ?? 0,
          // Agrega otros campos que necesites
        };
      }).toList();
    } else {
      throw Exception('Formato inesperado: no se encontró la lista de títulos en la respuesta');
    }
  } else {
    throw Exception('Error al obtener juegos PSN: ${response.statusCode}');
  }
}


}
