import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../web_service/steam_ws.dart';

class SteamProfileScreen extends StatelessWidget {
  final Map<String, dynamic> steamData;

  const SteamProfileScreen({super.key, required this.steamData});

  Map<String, dynamic> get profile => steamData['profile'] ?? steamData;

  String get steamId => profile['steamid'] ?? 'Desconocido';
  String get displayName => profile['personaname'] ?? 'Nombre no disponible';
  String get realName => profile['realname'] ?? 'No disponible';
  String get avatarUrl => profile['avatarfull'] ?? '';
  String get profileUrl => profile['profileurl'] ?? '';
  String get location => profile['loccountrycode'] ?? 'No disponible';

  String get visibilityStatus {
    switch (profile['communityvisibilitystate']) {
      case 3:
        return 'Público';
      case 1:
        return 'Privado';
      default:
        return 'Desconocido';
    }
  }

  String _personaStateText(int? state) {
    switch (state) {
      case 0:
        return 'Offline';
      case 1:
        return 'En línea';
      case 2:
        return 'Ocupado';
      case 3:
        return 'Ausente';
      case 4:
        return 'Saliendo';
      default:
        return 'Desconocido';
    }
  }

  String _timestampToDateTime(dynamic timestamp) {
    if (timestamp == null || timestamp == 0) return 'No disponible';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatPlaytime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Steam'),
        actions: [
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: 'Vincular cuenta',
            onPressed: () async {
              try {
                await UserService().addPlatform(
                  platformType: 'steam',
                  accountId: steamId,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cuenta Steam vinculada exitosamente: $steamId')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al vincular cuenta: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              child: avatarUrl.isEmpty ? const Icon(Icons.person, size: 60) : null,
            ),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text('SteamID: $steamId', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow(Icons.person, 'Nombre real', realName),
                    _infoRow(Icons.flag, 'País', location),
                    _infoRow(Icons.lock_open, 'Visibilidad', visibilityStatus),
                    _infoRow(Icons.wifi, 'Estado', _personaStateText(profile['personastate'])),
                    _infoRow(Icons.logout, 'Última conexión', _timestampToDateTime(profile['lastlogoff'])),
                    _infoRow(Icons.calendar_today, 'Miembro desde', _timestampToDateTime(profile['timecreated'])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Divider(thickness: 1.2),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Juegos recientes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: SteamWebService.getJuegosConStats(steamId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar los juegos: ${snapshot.error}'));
                }

                final games = snapshot.data ?? [];

                if (games.isEmpty) {
                  return const Center(child: Text('No se encontraron juegos en esta cuenta.'));
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    final name = game['name'] ?? 'Juego desconocido';
                    final playtime = game['playtime_forever'] ?? 0;
                    final appId = game['appid'];
                    final imageUrl = 'https://cdn.cloudflare.steamstatic.com/steam/apps/$appId/header.jpg';

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 3,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            imageUrl,
                            width: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.videogame_asset),
                          ),
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Tiempo jugado: ${_formatPlaytime(playtime)}'),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
