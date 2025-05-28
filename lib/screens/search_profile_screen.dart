import 'package:flutter/material.dart';
import 'package:hubify/screens/platform_profile_screen.dart';
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
    final gamertag = _controller.text.trim();

    if (gamertag.isEmpty) {
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
        final resultado = await XboxWebService.getPerfilPorGamertag(gamertag);

        setState(() {
          perfiles = (resultado['people'] as List)
              .map((p) => p as Map<String, dynamic>)
              .toList();
          if (perfiles.isEmpty) {
            _errorText = 'No se encontraron perfiles.';
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorText = 'Error al buscar perfil.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // fondo oscuro
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
                labelText: 'Buscar nickname',
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
                  return Card(
                    color: const Color(0xFF1E1E1E),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          perfil['displayPicRaw'] ?? '',
                        ),
                        backgroundColor: Colors.grey[700],
                      ),
                      title: Text(
                        perfil['gamertag'] ?? 'Sin gamertag',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'GamerScore: ${perfil['gamerScore'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                XboxProfileScreen(xuid: perfil['xuid']),
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
