class UserStatsService {
  Future<Map<String, dynamic>> getAllPlatformStats() async {
    // Simulación de datos reales
    await Future.delayed(const Duration(seconds: 1));
    return {
      'Steam': {'games': 42, 'hours': 1200},
      'PlayStation': {'games': 30, 'hours': 900},
      'Xbox': {'games': 15, 'hours': 400},
      'Ubisoft': {'games': 5, 'hours': 100},
    };
  }
}
