import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;

import '../model/Reminder.dart';

class ReminderController extends GetxController {
  final RxList<ReminderModel> reminders = <ReminderModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final Dio _dio = Dio();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final String _baseUrl = "https://496f8c5ee7fb.ngrok-free.app/api/user";
  // final String _baseUrl = "http://10.0.2.2:8000/api/user";

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> scheduleNotification(ReminderModel reminder) async {
    print("DEBUG: Attempting to schedule notification");

    if (reminder.id == null) {
      print(" ERROR: Reminder ID is null. Cannot schedule.");
      return;
    }
    if (reminder.time.isBefore(DateTime.now())) {
      print("ERROR: Reminder time is in the past. Cannot schedule.");
      print("   - Reminder Time: ${reminder.time}");
      print("   - Current Time:  ${DateTime.now()}");
      return;
    }

    final tz.TZDateTime scheduledTime =
        tz.TZDateTime.from(reminder.time, tz.local);

    print("Reminder data is valid for scheduling.");
    print("   - ID: ${reminder.id}");
    print("   - Name: ${reminder.name}");
    print(
        "   - Raw Time: ${reminder.time} (Type: ${reminder.time.runtimeType})");
    print("   - Timezone: ${tz.local.name}");
    print("   - Scheduled TZDateTime: $scheduledTime");
    print("-------------------------------------------------");

    try {
      await _notificationsPlugin.zonedSchedule(
        reminder.id!,
        'Reminder: ${reminder.name}',
        "It's time for your reminder!",
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel',
            'Reminder Notifications',
            channelDescription: 'Channel for scheduled reminder notifications.',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            ticker: 'ticker',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      print(
          "✅✅✅ SUCCESS: zonedSchedule function was called successfully for '${reminder.name}'.");
    } catch (e) {
      print("= FATAL ERROR: An exception occurred inside zonedSchedule!");
      print(e.toString());
    }
  }
  // Future<void> scheduleNotification(ReminderModel reminder) async {  print("--- DEBUG: Attempting to schedule notification ---");
  //
  // if (reminder.time.isBefore(DateTime.now())) return;
  //
  //   if (reminder.id == null) {
  //     print("❌ ERROR: Reminder ID is null. Cannot schedule.");
  //     return;
  //   } if (reminder.time.isBefore(DateTime.now())) {
  //   print("❌ ERROR: Reminder time is in the past. Cannot schedule.");
  //   print("   - Reminder Time: ${reminder.time}");
  //   print("   - Current Time:  ${DateTime.now()}");
  //   return;
  // } print("✅ Reminder data is valid for scheduling.");
  // print("   - ID: ${reminder.id}");
  // print("   - Name: ${reminder.name}");
  // print("   - Raw Time: ${reminder.time} (Type: ${reminder.time.runtimeType})");
  // print("   - Timezone: ${tz.local.name}");
  // print("-------------------------------------------------");
  //   await _notificationsPlugin.zonedSchedule(
  //     reminder.id!,
  //     'Reminder: ${reminder.name}',
  //     "It's time for your reminder!",
  //     tz.TZDateTime.from(reminder.time, tz.local),
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'reminder_channel',
  //         'Reminder Notifications',
  //         channelDescription: 'Channel for scheduled reminder notifications.',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //         playSound: true,
  //       ),
  //     ),
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //   );
  //   print(" Notification scheduled for reminder: ${reminder.name}");
  //
  // }

  Future<void> cancelNotification(int reminderId) async {
    await _notificationsPlugin.cancel(reminderId);
    print(" Notification cancelled for reminder ID: $reminderId");
  }

  Future<String?> _getAuthToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> fetchReminders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getAuthToken();
      if (token == null) throw Exception('Authentication token not found.');

      final response = await _dio.get(
        '$_baseUrl/reminders',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        reminders.value =
            data.map((json) => ReminderModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reminders: ${response.statusMessage}');
      }
    } catch (e) {
      errorMessage.value = 'Error fetching reminders: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<ReminderModel?> addReminder(ReminderModel reminder) async {
    isLoading.value = true;
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Authentication token not found.');

      final response = await _dio.post(
        '$_baseUrl/reminders',
        data: reminder.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final newReminderFromServer = ReminderModel.fromJson(response.data);
        reminders.insert(0, newReminderFromServer);
        await scheduleNotification(newReminderFromServer);
        Get.offNamed('/Reminder');
        return newReminderFromServer;
      } else {
        throw Exception('Failed to add reminder: ${response.statusMessage}');
      }
    } catch (e) {
      errorMessage.value = 'Error adding reminder: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Future<bool> addReminder(ReminderModel reminder) async {
  //   isLoading.value = true;
  //   try {
  //     final token = await _getAuthToken();
  //     if (token == null) throw Exception('Authentication token not found.');
  //
  //     final response = await _dio.post(
  //       '$_baseUrl/reminders',
  //       data: reminder.toJson(),
  //       options: Options(headers: {'Authorization': 'Bearer $token'}),
  //     );
  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       await fetchReminders();
  //       Get.snackbar('Success', 'Incomes added successfully!');
  //       Get.snackbar('Success', 'Incomes added successfully!');
  //       final newReminderFromServer = reminders.firstWhere(
  //         (r) =>
  //             r.name == reminder.name &&
  //             r.price == reminder.price &&
  //             r.time.toUtc() == reminder.time.toUtc(),
  //         orElse: () =>
  //             null as ReminderModel,
  //       );
  //
  //       Future.delayed(Duration(milliseconds: 800), () {
  //         Get.offNamed('/Reminder');
  //       });
  //       return true;
  //     } else {
  //       throw Exception('Failed to add reminder: ${response.statusMessage}');
  //     }
  //   } catch (e) {
  //     errorMessage.value = 'Error adding reminder: ${e.toString()}';
  //     Get.snackbar('Error', errorMessage.value,
  //         snackPosition: SnackPosition.BOTTOM);
  //     return false;
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<bool> updateReminder(ReminderModel reminder) async {
    isLoading.value = true;
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Authentication token not found.');
      if (reminder.id == null) throw Exception('Reminder ID is missing');

      final response = await _dio.put(
        '$_baseUrl/reminders/${reminder.id}',
        data: reminder.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final index = reminders.indexWhere((r) => r.id == reminder.id);
        if (index != -1) reminders[index] = reminder;

        await cancelNotification(reminder.id!);
        await scheduleNotification(reminder);

        Get.snackbar(
          'Success',
          'Reminder updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        throw Exception('Failed to update reminder: ${response.statusMessage}');
      }
    } catch (e) {
      errorMessage.value = 'Error updating reminder: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteReminder(int reminderId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Authentication token not found.');

      final response = await _dio.delete(
        '$_baseUrl/reminders/$reminderId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        reminders.removeWhere((r) => r.id == reminderId);

        await cancelNotification(reminderId);

        Get.snackbar(
          'Success',
          'Reminder deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        throw Exception('Failed to delete reminder: ${response.statusMessage}');
      }
    } catch (e) {
      errorMessage.value = 'Error deleting reminder: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
}
