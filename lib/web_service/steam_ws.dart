import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/status_data.dart';

class SteamWebService {
  static final String baseUrl = "http://${StatusData.ipAddress}:3000/steam";

  // Obtener información básica de la cuenta Steam
  static Future<Map<String, dynamic>> getDatosCuentaSteam(String steamId) async {
    final url = Uri.parse('$baseUrl/cuenta/nombre/$steamId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Error al obtener datos del perfil Steam');
    }
  }

  // ✅ Nueva función: Obtener juegos con estadísticas de un usuario
  static Future<List<Map<String, dynamic>>> getJuegosConStats(String steamId) async {
    final url = Uri.parse('$baseUrl/cuenta/juegos/$steamId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al obtener juegos con estadísticas');
    }
  }
}
