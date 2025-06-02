import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hubify/screens/SteamProfileScreen%20.dart';
import 'package:hubify/screens/xbox_profile_screen.dart';
import 'package:intl/intl.dart';
import '../constants/status_data.dart';
import '../utilities/text_styles.dart';
import '../web_service/ps_ws.dart';
import '../web_service/steam_ws.dart';
import '../widgets/linked_account_card.dart';
import 'ps_profile_screen.dart';
import 'edit_profile_screen.dart';
import '../web_service/xbox_ws.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final bool isCurrentUser;

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.isCurrentUser = false,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<DocumentSnapshot> _userFuture;
  List<Map<String, String>> _linkedAccounts = [];
  bool _loadingAccounts = true;

  @override
  void initState() {
    super.initState();
    _userFuture = FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    _loadLinkedAccounts();
  }

  Future<void> _loadLinkedAccounts() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      final platforms = doc.data()?['platforms'] as List<dynamic>? ?? [];

      final List<Map<String, String>> data = [];

      for (final platform in platforms) {
        final accountId = platform['id'];
        final type = platform['type']?.toLowerCase();

        if (accountId == null || type == null) continue;

        if (type == 'xbox') {
          final profile = await XboxWebService.getDatosCuentaXbox(accountId);
          if (profile['Gamertag'] != null && profile['GameDisplayPicRaw'] != null) {
            data.add({
              'accountId': accountId,
              'nickname': profile['Gamertag'] ?? '',
              'profileImage': profile['GameDisplayPicRaw'] ?? '',
              'type': platform['type'] ?? '',
            });
          }
        } else if (type == 'playstation') {
          final profile = await PSWebService.obtenerPerfilPorAccountId(accountId);
          if (profile['onlineId'] != null && profile['avatarUrls'] != null) {
            final avatarUrl = profile['avatarUrls'].isNotEmpty
                ? profile['avatarUrls'][0]['avatarUrl']
                : '';
            data.add({
              'accountId': accountId,
              'nickname': profile['onlineId'] ?? '',
              'profileImage': avatarUrl ?? '',
              'type': platform['type'] ?? '',
            });
          }
        } else if (type == 'steam') {
          final profile = await SteamWebService.getDatosCuentaSteam(accountId);
          if (profile['steamid'] != null && profile['avatarfull'] != null) {
            data.add({
              'accountId': accountId,
              'nickname': profile['personaname'] ?? '',
              'profileImage': profile['avatarfull'] ?? '',
              'type': platform['type'] ?? '',
            });
          }
        }
      }

      setState(() {
        _linkedAccounts = data;
        _loadingAccounts = false;
      });
    } catch (e) {
      print('Error al cargar cuentas vinculadas: $e');
      setState(() => _loadingAccounts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isCurrentUser ? 'Mi Perfil' : 'Perfil del Amigo',
          style: TextStyles.headerLarge,
        ),
        centerTitle: true,
        actions: widget.isCurrentUser
            ? [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
            },
          )
        ]
            : null,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _loadingAccounts) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyles.body));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Usuario no encontrado'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/default_avatar.png'),
                  backgroundColor: Colors.grey[800],
                ),
                const SizedBox(height: 20),
                Text(
                  data['name'] ?? 'Nombre no disponible',
                  style: TextStyles.headerLarge.copyWith(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  '@${data['username'] ?? 'sin_apodo'}',
                  style: TextStyles.caption.copyWith(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 30),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  color: Colors.grey[900],
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email, color: Colors.white),
                        title: Text('Correo electrónico', style: TextStyles.sectionTitleStyle(context)),
                        subtitle: Text(data['email'] ?? 'No disponible', style: TextStyles.body),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.circle, color: StatusData.statusColors[data['status']], size: 16),
                        title: Text('Estado', style: TextStyles.sectionTitleStyle(context)),
                        subtitle: Text(
                          data['status'] ?? 'No disponible',
                          style: TextStyles.body.copyWith(
                            color: StatusData.statusColors[data['status']] ?? Colors.white,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.calendar_today, color: Colors.white),
                        title: Text('Miembro desde', style: TextStyles.sectionTitleStyle(context)),
                        subtitle: Text(_formatDate(data['createdAt']), style: TextStyles.body),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.group, color: Colors.white),
                        title: Text('Amigos', style: TextStyles.sectionTitleStyle(context)),
                        subtitle: Text('${(data['friends'] as List?)?.length ?? 0} amigos', style: TextStyles.body),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_linkedAccounts.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Cuentas vinculadas',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _linkedAccounts.length,
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {
                      final account = _linkedAccounts[index];
                      return LinkedAccountCard(
                        platform: account['type'] ?? 'N/A',
                        nickname: account['nickname'] ?? '',
                        profileImage: account['profileImage'] ?? '',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                if (account['type'] == 'xbox') {
                                  return XboxProfileScreen(
                                      xuid: account['accountId'] ?? '');
                                } else if (account['type'] == 'playstation') {
                                  return PlaystationProfileScreen(
                                  accountId: account['accountId'] ?? '',
                                  nickname: account['nickname'] ?? '',
                                  );
                                } else if (account['type'] == 'steam') {
                                  return SteamProfileScreen(steamData: account);
                                } else {
                                  return const Scaffold(
                                    body: Center(child: Text('Pantalla no implementada')),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Fecha no disponible';
    try {
      final date = (timestamp as Timestamp).toDate();
      return DateFormat('d MMMM yyyy', 'es_ES').format(date);
    } catch (_) {
      return 'Fecha inválida';
    }
  }
}
