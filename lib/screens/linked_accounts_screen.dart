import 'package:flutter/material.dart';
import '../constants/platform_data.dart';
import '../utilities/text_styles.dart';

class LinkedAccountsScreen extends StatefulWidget {
  const LinkedAccountsScreen({super.key});

  @override
  State<LinkedAccountsScreen> createState() => _LinkedAccountsScreenState();
}

class _LinkedAccountsScreenState extends State<LinkedAccountsScreen> {
  final Map<String, List<String>> linkedAccounts = {
    'Steam': [],
    'PlayStation': [],
    'Xbox': [],
    'Ubisoft': [],
  };

  void _linkAccount(String platform) {
    setState(() {
      linkedAccounts[platform]!.add(
        'cuenta_${linkedAccounts[platform]!.length + 1}@ejemplo.com',
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cuenta vinculada a $platform')),
    );
  }

  void _unlinkAccount(String platform, String account) {
    setState(() {
      linkedAccounts[platform]!.remove(account);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cuenta desvinculada de $platform')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: logoPath != null
                        ? Image.asset(logoPath, width: 36, height: 36)
                        : const Icon(Icons.account_circle, size: 36),
                    title: Text(platform),
                    subtitle: Text(
                      accounts.isNotEmpty
                          ? '${accounts.length} cuenta(s) vinculada(s)'
                          : 'Ninguna cuenta vinculada',
                      style: TextStyle(
                        color: accounts.isNotEmpty ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _linkAccount(platform),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(accounts.isNotEmpty ? 'Agregar cuenta' : 'Vincular'),
                    ),
                  ),
                  if (accounts.isNotEmpty) const SizedBox(height: 10),
                  ...accounts.map((account) => ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 4),
                    title: Text(account),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _unlinkAccount(platform, account),
                    ),
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
