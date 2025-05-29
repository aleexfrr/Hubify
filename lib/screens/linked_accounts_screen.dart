import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/platform_data.dart';
import '../utilities/text_styles.dart';
import '../services/linked_accounts_service.dart';

class LinkedAccountsScreen extends StatefulWidget {
  const LinkedAccountsScreen({super.key});

  @override
  State<LinkedAccountsScreen> createState() => _LinkedAccountsScreenState();
}

class _LinkedAccountsScreenState extends State<LinkedAccountsScreen> {
  final Map<String, List<Map<String, String>>> linkedAccounts = {
    'Steam': [],
    'PlayStation': [],
    'Xbox': [],
    'Ubisoft': [],
  };

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllLinkedAccounts();
  }

  Future<void> _loadAllLinkedAccounts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final results = <String, List<Map<String, String>>>{};

      for (final platform in linkedAccounts.keys) {
        final accounts = await LinkedAccountsService.getLinkedAccounts(
          userId: user.uid,
          platformName: platform,
        );
        results[platform] = accounts;
      }

      setState(() {
        linkedAccounts.clear();
        linkedAccounts.addAll(results);
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar cuentas vinculadas: $e');
      setState(() => _isLoading = false);
    }
  }

  void _unlinkAccount(String platform, String accountId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await LinkedAccountsService.unlinkAccount(
        userId: user.uid,
        platformName: platform,
        accountId: accountId,
      );

      setState(() {
        linkedAccounts[platform]!.removeWhere((acc) => acc['accountId'] == accountId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cuenta desvinculada de $platform')),
      );
    } catch (e) {
      print('Error al desvincular cuenta: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al desvincular la cuenta')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Cuentas vinculadas', style: TextStyles.headerLarge),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: linkedAccounts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final platform = linkedAccounts.keys.elementAt(index);
          final accounts = linkedAccounts[platform]!;
          final logoPath = PlatformData.platformLogos[platform];

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Aquí quitamos el botón y ponemos el recuento a la derecha del título
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: logoPath != null
                        ? Image.asset(logoPath, width: 36, height: 36)
                        : const Icon(Icons.account_circle, size: 36),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(platform),
                        Text(
                          '${accounts.length} cuenta(s) vinculada(s)',
                          style: TextStyle(
                            color: accounts.isNotEmpty ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w400, // ligero pero legible
                            fontSize: 12, // tamaño pequeño
                          ),
                        ),
                      ],
                    ),
                    subtitle: accounts.isEmpty
                        ? const Text('Ninguna cuenta vinculada', style: TextStyle(color: Colors.grey))
                        : null,
                  ),
                  if (accounts.isNotEmpty) const SizedBox(height: 10),
                  ...accounts.map((account) {
                    final nickname = account['nickname'] ?? 'Sin nombre';
                    final profileImage = account['profileImage'];

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      leading: profileImage != null && profileImage.isNotEmpty
                          ? CircleAvatar(backgroundImage: NetworkImage(profileImage))
                          : const Icon(Icons.account_circle),
                      title: Text(nickname),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _unlinkAccount(platform, account['accountId']!),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
