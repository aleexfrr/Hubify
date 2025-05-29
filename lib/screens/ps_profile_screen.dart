import 'package:flutter/material.dart';
import 'package:hubify/web_service/ps_ws.dart';
import '../services/user_service.dart';
import '../utilities/text_styles.dart';

class PlaystationProfileScreen extends StatefulWidget {
  final String accountId;
  final String nickname;

  const PlaystationProfileScreen({
    Key? key,
    required this.accountId,
    required this.nickname,
  }) : super(key: key);

  @override
  State<PlaystationProfileScreen> createState() => _PlaystationProfileScreenState();
}

class _PlaystationProfileScreenState extends State<PlaystationProfileScreen> {
  late Future<Map<String, dynamic>> _perfilFuture;
  late Future<List<Map<String, dynamic>>> _juegosFuture;

  @override
  void initState() {
    super.initState();
    _perfilFuture = PSWebService.obtenerPerfilPorNombre(widget.nickname);
    _juegosFuture = PSWebService.obtenerJuegosPorAccountId(widget.accountId);

    print('Cargando perfil de PlayStation para: ${widget.nickname}');
    print('Account ID: ${widget.accountId}');
  }

  String obtenerAvatarUrlPlayStation(Map<String, dynamic> perfil) {
    if (perfil.containsKey('personalDetail')) {
      final personalDetail = perfil['personalDetail'];
      if (personalDetail != null && personalDetail.containsKey('profilePictureUrls')) {
        final pics = personalDetail['profilePictureUrls'] as List<dynamic>;
        if (pics.isNotEmpty) {
          final xlPic = pics.firstWhere(
                (pic) => pic['size'] == 'xl' && pic['profilePictureUrl'] != null,
            orElse: () => null,
          );
          if (xlPic != null) {
            return xlPic['profilePictureUrl'];
          }
        }
      }
    }
    if (perfil.containsKey('avatarUrls')) {
      final avatars = perfil['avatarUrls'] as List<dynamic>;
      if (avatars.isNotEmpty) {
        final largeAvatar = avatars.firstWhere(
              (avatar) => avatar['size'] == 'l' && avatar['avatarUrl'] != null,
          orElse: () => null,
        );
        if (largeAvatar != null) {
          return largeAvatar['avatarUrl'];
        }
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil PlayStation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: 'Vincular cuenta',
            onPressed: () async {
              try {
                await UserService().addPlatform(
                  platformType: 'playstation',
                  accountId: widget.accountId,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cuenta PlayStation vinculada exitosamente')),
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _perfilFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final perfil = snapshot.data!;
          final trophySummary = perfil['trophySummary'] ?? {};
          final earnedTrophies = trophySummary['earnedTrophies'] ?? {};
          final aboutMe = perfil['aboutMe'] ?? '';
          final avatarUrl = obtenerAvatarUrlPlayStation(perfil);

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _juegosFuture,
            builder: (context, juegosSnapshot) {
              if (juegosSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (juegosSnapshot.hasError) {
                return Center(child: Text('Error al cargar juegos: ${juegosSnapshot.error}'));
              }

              final juegos = juegosSnapshot.data!;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl.isEmpty ? const Icon(Icons.person, size: 60) : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        perfil['onlineId'] ?? 'ID desconocido',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'Nivel de trofeos: ${trophySummary['level'] ?? 'N/A'} (${trophySummary['progress']}%)',
                        style: TextStyles.caption.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (aboutMe.isNotEmpty)
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            aboutMe,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),

                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'Resumen de trofeos',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildTrophyColumn("Platino", earnedTrophies['platinum'] ?? 0, Colors.blueGrey),
                                _buildTrophyColumn("Oro", earnedTrophies['gold'] ?? 0, Colors.amber),
                                _buildTrophyColumn("Plata", earnedTrophies['silver'] ?? 0, Colors.grey),
                                _buildTrophyColumn("Bronce", earnedTrophies['bronze'] ?? 0, Colors.brown),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    if ((perfil['firstName']?.toString().trim().isNotEmpty ?? false) ||
                        (perfil['lastOnlineDate']?.toString().trim().isNotEmpty ?? false) ||
                        (perfil['location']?.toString().trim().isNotEmpty ?? false))
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (perfil['firstName']?.toString().trim().isNotEmpty ?? false)
                                InfoRow(label: 'Nombre real', value: perfil['firstName']),
                              if (perfil['lastOnlineDate']?.toString().trim().isNotEmpty ?? false)
                                InfoRow(label: 'Última vez online', value: perfil['lastOnlineDate']),
                              if (perfil['location']?.toString().trim().isNotEmpty ?? false)
                                InfoRow(label: 'Ubicación', value: perfil['location']),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),
                    Text(
                      'Juegos jugados (Total: ${juegos.length})',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    juegos.isEmpty
                        ? const Text('No se encontraron juegos.')
                        : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: juegos.map((juego) {
                        return SizedBox(
                          width: screenWidth < 600 ? (screenWidth / 2) - 24 : 200,
                          child: GameCard(juego: juego),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTrophyColumn(String label, int count, Color color) {
    return Flexible(
      child: Column(
        children: [
          Icon(Icons.emoji_events, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const InfoRow({Key? key, required this.label, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return value != null && value!.isNotEmpty
        ? Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value!,
              style: const TextStyle(fontSize: 16),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    )
        : const SizedBox.shrink();
  }
}

class GameCard extends StatelessWidget {
  final Map<String, dynamic> juego;

  const GameCard({super.key, required this.juego});

  String formatPlayDuration(String? duration) {
    if (duration == null || duration.isEmpty) return 'N/A';

    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(duration);

    if (match == null) return 'N/A';

    final hours = match.group(1) ?? '0';
    final minutes = match.group(2) ?? '0';

    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final playDurationFormatted = formatPlayDuration(juego['playDuration']);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (juego['image'] != null && juego['image'].isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                juego['image'],
                width: double.infinity,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  juego['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text('Trofeos ganados: ${juego['trophies'] ?? 'N/A'}'),
                Text('Horas jugadas: $playDurationFormatted'),
                Text('Consola: ${juego['category'] ?? 'Desconocida'}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
