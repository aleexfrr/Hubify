import 'package:flutter/material.dart';

class StatusData {
  static String get ipAddress => '192.168.1.105';

  static const List<String> statusAvailables = [
    'Online',
    'Absent',
    'Busy',
    'Invisible',
  ];

  static const Map<String, Color> statusColors = {
    'Online': Colors.green,
    'Absent': Colors.orange,
    'Busy': Colors.red,
    'Invisible': Colors.grey,
  };
}