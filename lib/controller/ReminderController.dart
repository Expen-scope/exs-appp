import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../model/Reminder.dart';

class ReminderController extends GetxController {
  final RxList<ReminderModel> reminders = <ReminderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Timer? _checkTimer;
  final Dio _dio = Dio();
  final String _baseUrl = "http://10.0.2.2:8000/api/user";

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
    _startPeriodicChecking();
    fetchReminders();
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    _notificationsPlugin.initialize(initializationSettings);
  }

  void _startPeriodicChecking() {
    _checkTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      _checkRemindersCompletion();
    });
  }

  void _checkRemindersCompletion() {
    for (var reminder in reminders) {
      if (!reminder.time.isBefore(DateTime.now()) &&
          DateTime.now().isAfter(reminder.time)) {
        _showNotification(
            "You must remember ", "It's time to ${reminder.name} !");
      }
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'goal_channel_id',
      'Goal Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(0, title, body, platformDetails);
  }

  Future<bool> addReminder(ReminderModel reminder) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'User not authenticated.';
        return false;
      }

      final url = '$_baseUrl/reminders';
      final data = reminder.toJson();

      print("🚀 Sending request to: $url");
      print("🔑 With token: Bearer $token");
      print("📦 Sending data: $data");

      final response = await _dio.post(
        url,
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'application/json',
        ),
      );

      print("✅ Response status: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final newReminder = ReminderModel.fromJson(response.data);
        reminders.add(newReminder);
        return true;
      } else {
        errorMessage.value =
            'Failed to add reminder: ${response.statusMessage}';
        return false;
      }
    } catch (e) {
      print("❌❌❌ AN ERROR OCCURRED ❌❌❌");
      if (e is DioException) {
        print("Dio Error Type: ${e.type}");
        print("Dio Error Message: ${e.message}");
        if (e.response != null) {
          print("Server Response Status: ${e.response!.statusCode}");
          print("Server Response Data: ${e.response!.data}");
          errorMessage.value =
              "Server error: ${e.response!.data['message'] ?? e.response!.data.toString()}";
        } else {
          errorMessage.value = "Network error: Please check your connection.";
        }
      } else {
        print("Unknown Error: $e");
        errorMessage.value = 'An unexpected error occurred: $e';
      }
      print("❌❌❌ END OF ERROR ❌❌❌");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteReminder(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'User not authenticated.';
        return false;
      }

      final response = await _dio.delete(
        '$_baseUrl/reminders/$id',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 204) {
        reminders.removeWhere((reminder) => reminder.id == id);
        return true;
      } else {
        errorMessage.value =
            'Failed to delete reminder: ${response.statusMessage}';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error deleting reminder: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateReminder(ReminderModel reminder) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'User not authenticated.';
        return false;
      }

      final response = await _dio.put(
        '$_baseUrl/reminders/${reminder.id}',
        data: reminder.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final index = reminders.indexWhere((r) => r.id == reminder.id);
        if (index != -1) {
          reminders[index] = ReminderModel.fromJson(response.data);
        }
        return true;
      } else {
        errorMessage.value =
            'Failed to update reminder: ${response.statusMessage}';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error updating reminder: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchReminders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'User not authenticated.';
        return;
      }

      final response = await _dio.get(
        '$_baseUrl/reminders',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        reminders.value =
            data.map((json) => ReminderModel.fromJson(json)).toList();
      } else {
        errorMessage.value =
            'Failed to load reminders: ${response.statusMessage}';
      }
    } catch (e) {
      errorMessage.value = 'Error fetching reminders: $e';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _checkTimer?.cancel();
    super.onClose();
  }
}
