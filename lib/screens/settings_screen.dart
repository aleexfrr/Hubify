import 'package:flutter/material.dart';
import 'package:hubify/utils/text_styles.dart';

class SettingsScreen extends StatelessWidget {
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
