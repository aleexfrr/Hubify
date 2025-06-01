import 'package:cloud_firestore/cloud_firestore.dart';

import '../web_service/ps_ws.dart';
import '../web_service/steam_ws.dart';
import '../web_service/xbox_ws.dart';

class LinkedAccountsService {
  /// Obtiene las IDs de cuentas vinculadas para el usuario y plataforma indicada
  static Future<List<String>> getLinkedAccountIds({
    required String userId,
    required String platformName,
  }) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final platforms = userDoc.data()?['platforms'] as List<dynamic>? ?? [];
    final filtered = platforms.where((p) =>
    p['type']?.toString().toLowerCase() == platformName.toLowerCase());
    return filtered.map((p) => p['id'] as String).whereType<String>().toList();
  }

  /// Obtiene la información del perfil para una cuenta dada y plataforma
  static Future<Map<String, String>?> getProfile({
    required String platformName,
    required String accountId,
  }) async {
    switch (platformName.toLowerCase()) {
      case 'xbox':
        final profile = await XboxWebService.getDatosCuentaXbox(accountId);
        if (profile['Gamertag'] != null && profile['GameDisplayPicRaw'] != null) {
          return {
            'accountId': accountId,
            'nickname': profile['Gamertag'] ?? '',
            'profileImage': profile['GameDisplayPicRaw'] ?? '',
          };
        }
        break;

      case 'playstation':
        final profile = await PSWebService.obtenerPerfilPorAccountId(accountId);
        if (profile['onlineId'] != null && profile['avatarUrls'] != null) {
          final avatarList = profile['avatarUrls'] as List;
          final avatar = avatarList.isNotEmpty ? avatarList.last['avatarUrl'] : null;
          if (avatar != null) {
            return {
              'accountId': accountId,
              'nickname': profile['onlineId'],
              'profileImage': avatar,
            };
          }
        }
        break;

      case 'steam':
        final profile = await SteamWebService.getDatosCuentaSteam(accountId);
        if (profile['steamid'] != null && profile['avatarfull'] != null) {
          return {
            'accountId': accountId,
            'nickname': profile['personaname'] ?? '',
            'profileImage': profile['avatarfull'] ?? '',
          };
        }
        break;

      default:
        return null;
    }
    return null;
  }

  /// Función que obtiene todas las cuentas vinculadas con perfiles completos
  static Future<List<Map<String, String>>> getLinkedAccounts({
    required String userId,
    required String platformName,
  }) async {
    final accountIds = await getLinkedAccountIds(userId: userId, platformName: platformName);
    final List<Map<String, String>> accounts = [];

    for (final id in accountIds) {
      final profile = await getProfile(platformName: platformName, accountId: id);
      if (profile != null) {
        accounts.add(profile);
      }
    }
    return accounts;
  }

  /// Elimina una cuenta vinculada del usuario
  static Future<void> unlinkAccount({
    required String userId,
    required String platformName,
    required String accountId,
  }) async {
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final userDoc = await userDocRef.get();

    if (!userDoc.exists) return;

    final platforms = userDoc.data()?['platforms'] as List<dynamic>? ?? [];

    final updatedPlatforms = platforms.where((p) {
      final type = p['type']?.toString().toLowerCase() ?? '';
      final id = p['id']?.toString() ?? '';
      return !(type == platformName.toLowerCase() && id == accountId);
    }).toList();

    await userDocRef.update({'platforms': updatedPlatforms});
  }
}
