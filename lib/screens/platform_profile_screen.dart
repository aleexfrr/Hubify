import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../web_service/xbox_ws.dart';

class XboxProfileScreen extends StatefulWidget {
  final String xuid;

  const XboxProfileScreen({Key? key, required this.xuid}) : super(key: key);

  @override
  State<XboxProfileScreen> createState() => _XboxProfileScreenState();
}

class _XboxProfileScreenState extends State<XboxProfileScreen> {
  late Future<Map<String, String>> _perfilFuture;
  late Future<List<Map<String, dynamic>>> _juegosFuture;

  @override
  void initState() {
    super.initState();
    _perfilFuture = XboxWebService.getDatosCuentaXbox(widget.xuid);
    _juegosFuture = XboxWebService.getJuegosCuentaXbox(widget.xuid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil Xbox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: 'Vincular cuenta',
            onPressed: () async {
              final xuid = widget.xuid;

              try {
                await UserService().addPlatform(
                  platformType: 'xbox',
                  accountId: xuid,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cuenta Xbox vinculada exitosamente: $xuid')),
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
      body: FutureBuilder<Map<String, String>>(
        future: _perfilFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final perfil = snapshot.data!;
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen de perfil
                    perfil.containsKey('GameDisplayPicRaw')
                        ? CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(perfil['GameDisplayPicRaw']!),
                    )
                        : const CircleAvatar(radius: 60, child: Icon(Icons.person)),

                    const SizedBox(height: 20),

                    Text(perfil['Gamertag'] ?? 'Gamertag desconocido',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    Text('Gamerscore: ${perfil['Gamerscore'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 18)),

                    const Divider(height: 32),

                    InfoRow(label: 'Nombre real', value: perfil['RealName']),
                    InfoRow(label: 'Tier', value: perfil['AccountTier']),
                    InfoRow(label: 'Reputación', value: perfil['XboxOneRep']),
                    InfoRow(label: 'Biografía', value: perfil['Bio']),
                    InfoRow(label: 'Ubicación', value: perfil['Location']),

                    const Divider(height: 32),
                    const Text('Juegos recientes',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    juegos.isEmpty
                        ? const Text('No se encontraron juegos.')
                        : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: juegos.map((juego) => SizedBox(
                        width: (MediaQuery.of(context).size.width / 2) - 24,
                        child: GameCard(juego: juego),
                      )).toList(),
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
          Flexible(
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  juego['name'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text('Gamerscore: ${juego['gamerscore']}'),
                Text('Progreso: ${juego['progress']}%'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
