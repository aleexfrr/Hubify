import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hubify/screens/platform_profile_screen.dart';
import 'package:hubify/screens/search_profile_screen.dart';
import 'package:hubify/utilities/text_styles.dart';
import 'package:hubify/widgets/profile_card.dart';
import '../web_service/xbox_ws.dart';

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
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
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

        final profile = await XboxWebService.getDatosCuentaXbox(accountId);

        if (profile['Gamertag'] != null &&
            profile['GameDisplayPicRaw'] != null) {
          data.add({
            'accountId': accountId,
            'nickname': profile['Gamertag'] ?? '',
            'profileImage': profile['GameDisplayPicRaw'] ?? '',
          });
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo
        Positioned.fill(
          child: Image.asset(
            widget.platformBackground,
            fit: BoxFit.cover,
          ),
        ),

        // Contenido
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
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      if (index == _accountData.length) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SearchProfileScreen(plataforma: widget.platformName),
                              ),
                            );
                          },
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
                                  Icon(Icons.add,
                                      size: 40, color: Colors.white),
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => XboxProfileScreen(xuid: account['accountId'] ?? ''),
                            ),
                          );
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
