import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hubify/constants/platform_data.dart';
import '../services/user_stats_service.dart'; // Deberás crear este servicio
import '../widgets/platform_stat_card.dart'; // Widget para mostrar stats por plataforma

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = UserStatsService().getAllPlatformStats(); // Simulación de carga de datos
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final stats = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text(
                "Resumen de tus plataformas",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ...stats.entries.map((entry) => PlatformStatCard(
                platformName: entry.key,
                stats: entry.value,
                backgroundColor: PlatformData.platformColors[entry.key] ?? Colors.grey,
              )),
            ],
          ),
        );
      },
    );
  }
}
