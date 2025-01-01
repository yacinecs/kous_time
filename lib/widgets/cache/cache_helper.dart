import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  // Save schedules to SharedPreferences
  static Future<void> cacheSchedules(List<Map<String, dynamic>> schedules) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert schedules to JSON and store it in SharedPreferences
    String schedulesJson = jsonEncode(schedules);
    await prefs.setString('cached_schedules', schedulesJson);
  }

  // Retrieve cached schedules from SharedPreferences
  static Future<List<Map<String, dynamic>>> getCachedSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    String? schedulesJson = prefs.getString('cached_schedules');
    if (schedulesJson != null) {
      List<dynamic> decodedSchedules = jsonDecode(schedulesJson);
      return decodedSchedules.map((schedule) => Map<String, dynamic>.from(schedule)).toList();
    } else {
      return [];
    }
  }

  // Clear cached schedules
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_schedules');
  }
}
