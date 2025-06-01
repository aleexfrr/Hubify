import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hubify/screens/SteamProfileScreen%20.dart';
import 'package:hubify/screens/xbox_profile_screen.dart';
import 'package:hubify/screens/search_profile_screen.dart';
import 'package:hubify/utilities/text_styles.dart';
import 'package:hubify/widgets/profile_card.dart';
import 'package:hubify/web_service/steam_login_webview.dart';
import '../web_service/ps_ws.dart';
import '../web_service/steam_ws.dart';
import '../web_service/xbox_ws.dart';
import 'ps_profile_screen.dart';

class PlatformScreen extends StatefulWidget {
  final String platformName;
  final String platformImage;
  final String platformBackground;

  const PlatformScreen({
    super.key,
    required this.platformName,
    required this.platformImage,
    required this.platformBackground,
  });

  @override
  State<PlatformScreen> createState() => _PlatformScreenState();
}

class _PlatformScreenState extends State<PlatformScreen> {
  List<Map<String, String>> _accountData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLinkedAccounts();
  }

  Future<void> _loadLinkedAccounts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final platforms = userDoc.data()?['platforms'] as List<dynamic>? ?? [];
      final filteredAccounts = platforms
          .where((platform) =>
      platform['type']?.toString().toLowerCase() ==
          widget.platformName.toLowerCase())
          .toList();

      final List<Map<String, String>> data = [];

      for (final platform in filteredAccounts) {
        final accountId = platform['id'];
        if (accountId == null) continue;

        Map<String, dynamic> profile = {};

        final platformName = widget.platformName.toLowerCase();

        if (platformName == 'xbox') {
          profile = await XboxWebService.getDatosCuentaXbox(accountId);
          if (profile['Gamertag'] != null && profile['GameDisplayPicRaw'] != null) {
            data.add({
              'accountId': accountId,
              'nickname': profile['Gamertag'],
              'profileImage': profile['GameDisplayPicRaw'],
            });
          }
        } else if (platformName == 'playstation') {
          profile = await PSWebService.obtenerPerfilPorAccountId(accountId);
          if (profile['onlineId'] != null && profile['avatarUrls'] != null) {
            final avatar = (profile['avatarUrls'] as List).isNotEmpty
                ? profile['avatarUrls'].last['avatarUrl']
                : null;
            if (avatar != null) {
              data.add({
                'accountId': accountId,
                'nickname': profile['onlineId'],
                'profileImage': avatar,
              });
            }
          }
        } else if (platformName == 'steam') {
          profile = await SteamWebService.getDatosCuentaSteam(accountId);
          if (profile['steamid'] != null && profile['avatarfull'] != null) {
            data.add({
              'accountId': accountId,
              'nickname': profile['personaname'],
              'profileImage': profile['avatarfull'],
            });
          }
        }
      }

      setState(() {
        _accountData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar cuentas vinculadas: $e');
      setState(() => _isLoading = false);
    }
  }

  void _handleAddAccount() {
    final platform = widget.platformName.toLowerCase();
    if (platform == 'steam') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SteamLoginWebView(
            onLoginSuccess: (steamData) {
              Navigator.pop(context); // Cierra el WebView
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SteamProfileScreen(steamData: steamData),
                ),
              );
            },
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchProfileScreen(
            plataforma: widget.platformName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            widget.platformBackground,
            fit: BoxFit.cover,
          ),
        ),
        Column(
          children: [
            const SizedBox(height: 60),
            if (widget.platformImage.isNotEmpty)
              Image.asset(widget.platformImage, width: 48, height: 48),
            const SizedBox(height: 12),
            Text('Cuentas de ${widget.platformName}', style: TextStyles.headerLarge),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: 450,
                  child: GridView.builder(
                    itemCount: _accountData.length + 1,
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      if (index == _accountData.length) {
                        return GestureDetector(
                          onTap: _handleAddAccount,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white.withOpacity(0.2),
                              border: Border.all(color: Colors.white30),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add, size: 40, color: Colors.white),
                                  SizedBox(height: 8),
                                  Text(
                                    'Agregar cuenta',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      final account = _accountData[index];
                      return ProfileCard(
                        profileImage: account['profileImage'] ?? '',
                        nickname: account['nickname'] ?? '',
                        email: '',
                        onTap: () async {
                          final platform = widget.platformName.toLowerCase();
                          if (platform == 'xbox') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => XboxProfileScreen(
                                  xuid: account['accountId'] ?? '',
                                ),
                              ),
                            );
                          } else if (platform == 'playstation') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlaystationProfileScreen(
                                  accountId: account['accountId'] ?? '',
                                  nickname: account['nickname'] ?? '',
                                ),
                              ),
                            );
                          } else if (platform == 'steam') {
                            var profile = await SteamWebService.getDatosCuentaSteam(account['accountId'] ?? '');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SteamProfileScreen(steamData: profile),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Plataforma no implementada')),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
