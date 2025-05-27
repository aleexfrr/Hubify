import 'package:flutter/material.dart';
import 'package:hubify/screens/platform_profile_screen.dart';
import '../web_service/xbox_ws.dart';


class BuscarPerfilScreen extends StatefulWidget {
  final String plataforma;

  const BuscarPerfilScreen({Key? key, required this.plataforma}) : super(key: key);

  @override
  State<BuscarPerfilScreen> createState() => _BuscarPerfilScreenState();
}

class _BuscarPerfilScreenState extends State<BuscarPerfilScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> perfiles = [];

  Future<void> buscarPerfil() async {
    final gamertag = _controller.text.trim();

    if (gamertag.isEmpty) return;

    try {
      if (widget.plataforma == 'Xbox') {
        final resultado = await XboxWebService.getPerfilPorGamertag(gamertag);

        setState(() {
          perfiles = (resultado['people'] as List)
              .map((p) => p as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al buscar perfil")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buscar perfil ${widget.plataforma}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Buscar Gamertag',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: buscarPerfil,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: perfiles.isEmpty
                  ? Center(child: Text('No hay resultados'))
                  : ListView.builder(
                itemCount: perfiles.length,
                itemBuilder: (context, index) {
                  final perfil = perfiles[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(perfil['displayPicRaw'] ?? ''),
                      ),
                      title: Text(perfil['gamertag'] ?? 'Sin gamertag'),
                      subtitle: Text('GamerScore: ${perfil['gamerScore'] ?? 'N/A'}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => XboxProfileScreen(xuid: perfil['xuid']),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
