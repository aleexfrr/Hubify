import 'package:flutter/material.dart';
import '../constants/platform_data.dart';
import '../utilities/text_styles.dart';

class LinkedAccountsScreen extends StatelessWidget {
  final Map<String, List<String>> linkedAccounts = {
    'Steam': [],
    'PlayStation': [],
    'Xbox': [],
    'Epic Games': [],
    'Ubisoft': [],
  };

  LinkedAccountsScreen({super.key});

  void _linkAccount(BuildContext context, String platform) {
    linkedAccounts[platform]!.add('cuenta_${linkedAccounts[platform]!.length + 1}@ejemplo.com');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Añadiendo cuenta a $platform...')),
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
          final isLinked = accounts.isNotEmpty;
          final logoPath = PlatformData.platformLogos[platform];

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: ListTile(
              leading: logoPath != null
                  ? Image.asset(
                logoPath,
                width: 36,
                height: 36,
              )
                  : const Icon(Icons.account_circle, size: 36),
              title: Text(platform),
              subtitle: Text(
                isLinked
                    ? '${accounts.length} cuenta(s) vinculada(s)'
                    : 'Ninguna cuenta vinculada',
                style: TextStyle(
                  color: isLinked ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: ElevatedButton(
                onPressed: () => _linkAccount(context, platform),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(isLinked ? 'Agregar cuenta' : 'Vincular'),
              ),
              onTap: () {
                if (isLinked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gestionar cuentas de $platform')),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
