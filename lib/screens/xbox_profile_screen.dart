import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../web_service/xbox_ws.dart';
import '../utilities/text_styles.dart';
import '../widgets/game_card.dart';

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
        title: Text('Perfil Xbox', style: TextStyles.headerLarge),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: 'Vincular cuenta',
            onPressed: () async {
              try {
                await UserService().addPlatform(
                  platformType: 'xbox',
                  accountId: widget.xuid,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cuenta Xbox vinculada exitosamente: ${widget.xuid}')),
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
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyles.body));
          }

          final perfil = snapshot.data!;
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _juegosFuture,
            builder: (context, juegosSnapshot) {
              if (juegosSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (juegosSnapshot.hasError) {
                return Center(child: Text('Error al cargar juegos: ${juegosSnapshot.error}', style: TextStyles.body));
              }

              final juegos = juegosSnapshot.data!;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: perfil.containsKey('GameDisplayPicRaw')
                          ? NetworkImage(perfil['GameDisplayPicRaw']!)
                          : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                      backgroundColor: Colors.grey[800],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      perfil['Gamertag'] ?? 'Gamertag desconocido',
                      style: TextStyles.headerLarge.copyWith(fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Gamerscore: ${perfil['Gamerscore'] ?? 'N/A'}',
                      style: TextStyles.caption.copyWith(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 30),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                      color: Colors.grey[900],
                      child: Column(
                        children: _buildProfileDetails(perfil),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Juegos jugados',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    juegos.isEmpty
                        ? const Text('No se encontraron juegos.')
                        : GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                      children: juegos.map((juego) => GameCard(juego: juego)).toList(),
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

  List<Widget> _buildProfileDetails(Map<String, String> perfil) {
    final tiles = <Map<String, dynamic>>[];

    if (perfil['RealName'] != null && perfil['RealName']!.isNotEmpty) {
      tiles.add({'icon': Icons.person, 'title': 'Nombre real', 'value': perfil['RealName']!});
    }
    if (perfil['AccountTier'] != null && perfil['AccountTier']!.isNotEmpty) {
      tiles.add({'icon': Icons.star, 'title': 'Tier', 'value': perfil['AccountTier']!});
    }
    if (perfil['XboxOneRep'] != null && perfil['XboxOneRep']!.isNotEmpty) {
      tiles.add({'icon': Icons.thumb_up, 'title': 'Reputación', 'value': perfil['XboxOneRep']!});
    }
    if (perfil['Bio'] != null && perfil['Bio']!.isNotEmpty) {
      tiles.add({'icon': Icons.description, 'title': 'Biografía', 'value': perfil['Bio']!});
    }
    if (perfil['Location'] != null && perfil['Location']!.isNotEmpty) {
      tiles.add({'icon': Icons.location_on, 'title': 'Ubicación', 'value': perfil['Location']!});
    }

    return List.generate(tiles.length, (index) {
      final tile = tiles[index];
      final isLast = index == tiles.length - 1;
      return Column(
        children: [
          ListTile(
            leading: Icon(tile['icon'], color: Colors.white),
            title: Text(tile['title'], style: TextStyles.sectionTitleStyle(context)),
            subtitle: Text(tile['value'], style: TextStyles.body),
          ),
          if (!isLast) const Divider(height: 1),
        ],
      );
    });
  }
}
