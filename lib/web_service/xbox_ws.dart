import 'dart:convert';
import 'package:http/http.dart' as http;

class XboxWebService {
  static const String baseUrl = "http://192.168.1.103:3000/xbox";

  static Future<Map<String, dynamic>> getPerfilPorGamertag(String gamertag) async {
    final url = Uri.parse('$baseUrl/perfiles/$gamertag');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener perfil: ${response.statusCode}');
    }
  }

  static Future<Map<String, String>> getDatosCuentaXbox(String xuid) async {
    final url = Uri.parse('$baseUrl/cuenta/nombre/$xuid');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final settings = data['profileUsers'][0]['settings'] as List<dynamic>;

      // Convertimos settings a un Map<String, String> para fácil acceso
      final Map<String, String> perfil = {
        for (var item in settings) item['id']: item['value']
      };

      return perfil;
    } else {
      throw Exception('Error al obtener datos del perfil Xbox');
    }
  }

  static Future<List<Map<String, dynamic>>> getJuegosCuentaXbox(String xuid) async {
    final url = Uri.parse('$baseUrl/cuenta/juegos/$xuid');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> titles = data['titles'];

      // Extraemos los datos relevantes de cada juego
      final List<Map<String, dynamic>> juegos = titles.map<Map<String, dynamic>>((juego) {
        return {
          'name': juego['name'] ?? 'Nombre no disponible',
          'image': juego['displayImage'] ?? '',
          'gamerscore': juego['achievement']?['currentGamerscore'] ?? 0,
          'progress': juego['achievement']?['progressPercentage'] ?? 0,
          'lastPlayed': juego['titleHistory']?['lastTimePlayed'] ?? '',
          'devices': juego['devices'] ?? [],
        };
      }).toList();

      return juegos;
    } else {
      throw Exception('Error al obtener juegos de la cuenta Xbox');
    }
  }

}
