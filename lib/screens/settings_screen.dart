import 'package:flutter/material.dart';
import 'package:hubify/utilities/text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
        Text(
            'Ajustes',
            style: TextStyles.headerLarge
        ),
    );
  }
}
