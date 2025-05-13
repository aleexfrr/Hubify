import 'dart:ui';
import 'package:flutter/material.dart';

class StatusData {
  static const List<String> statusAvailables = [
    'Online',
    'Offline',
    'Busy',
    'Invisible',
  ];

  static const Map<String, Color> statusColors = {
    'Online': Colors.green,
    'Offline': Colors.grey,
    'Busy': Colors.red,
    'Invisible': Colors.orange,
  };
}