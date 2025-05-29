import 'package:flutter/material.dart';
import 'package:hubify/screens/ps_profile_screen.dart';
import 'package:hubify/screens/xbox_profile_screen.dart';
import 'package:hubify/web_service/ps_ws.dart';
import '../web_service/xbox_ws.dart';

class SearchProfileScreen extends StatefulWidget {
  final String plataforma;

  const SearchProfileScreen({Key? key, required this.plataforma}) : super(key: key);

  @override
  State<SearchProfileScreen> createState() => _SearchProfileScreenState();
}

class _SearchProfileScreenState extends State<SearchProfileScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> perfiles = [];
  bool _isLoading = false;
  String? _errorText;

  Future<void> buscarPerfil() async {
    final nombre = _controller.text.trim();

    if (nombre.isEmpty) {
      setState(() {
        perfiles = [];
        _errorText = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      if (widget.plataforma.toLowerCase() == 'xbox') {
        final resultado = await XboxWebService.getPerfilPorGamertag(nombre);
        perfiles = (resultado['people'] as List).cast<Map<String, dynamic>>();
        if (perfiles.isEmpty) {
          _errorText = 'No se encontraron perfiles.';
        }
      } else if (widget.plataforma.toLowerCase() == 'playstation') {
        final resultado = await PSWebService.obtenerPerfilPorNombre(nombre);
        perfiles = [resultado];
      }
    } catch (e) {
      _errorText = 'Error al buscar perfil.';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
    final plataforma = widget.plataforma.toLowerCase();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('Buscar perfil ${widget.plataforma}'),
        backgroundColor: const Color(0xFF1F1F1F),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Buscar Gamertag/Online ID',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white70),
                  onPressed: buscarPerfil,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white54),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                ),
                errorText: _errorText,
                errorStyle: const TextStyle(color: Colors.redAccent),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                ),
              ),
              onSubmitted: (_) => buscarPerfil(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : perfiles.isEmpty
                  ? Center(
                child: Text(
                  _errorText ?? 'No hay resultados',
                  style: const TextStyle(color: Colors.white70),
                ),
              )
                  : ListView.builder(
                itemCount: perfiles.length,
                itemBuilder: (context, index) {
                  final perfil = perfiles[index];

                  final imagenUrl = plataforma == 'xbox'
                      ? perfil['displayPicRaw']
                      : obtenerAvatarUrlPlayStation(perfil);

                  final nombre = plataforma == 'xbox'
                      ? perfil['gamertag'] ?? 'Sin gamertag'
                      : perfil['onlineId'] ?? 'Sin ID';

                  final trophySummary = perfil['trophySummary'] ?? {};
                  final level = trophySummary['level'] ?? 'N/A';

                  final detalle = plataforma == 'xbox'
                      ? 'GamerScore: ${perfil['gamerScore'] ?? 'N/A'}'
                      : 'Nivel Trofeos: $level';

                  return Card(
                    color: const Color(0xFF1E1E1E),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: imagenUrl.isNotEmpty
                            ? NetworkImage(imagenUrl)
                            : null,
                        backgroundColor: Colors.grey[700],
                        child: imagenUrl.isEmpty
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      title: Text(
                        nombre,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        detalle,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () {
                        if (plataforma == 'xbox') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => XboxProfileScreen(xuid: perfil['xuid']),
                            ),
                          );
                        } else if (plataforma == 'playstation') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlaystationProfileScreen(
                                accountId: perfil['accountId'],
                                nickname: perfil['onlineId'],
                              ),
                            ),
                          );
                        }
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
