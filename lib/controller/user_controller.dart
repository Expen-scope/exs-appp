import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/User.dart';
import 'FinancialController.dart';
import 'IncomesController.dart';
import 'ExpensesController.dart';
import 'ReminderController.dart';

class UserController extends GetxController {
  final RxBool isLoggedIn = false.obs;
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = true.obs;
  var selectedImage = Rx<File?>(null);

  final String _apiUrl = "https://f1fc42afeee8.ngrok-free.app/api/";
  final _storage = const FlutterSecureStorage();
  final _dio = Dio();

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> tryAutoLogin() async {
    isLoading.value = true;
    try {
      final token = await _storage.read(key: 'access_token');
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      if (token != null && token.isNotEmpty && userDataString != null) {
        print("Session found. Logging in automatically.");
        user.value = UserModel.fromJson(json.decode(userDataString));
        isLoggedIn.value = true;

        print("Triggering initial data fetch for all controllers...");
        await Future.wait([
          if (Get.isRegistered<IncomesController>())
            Get.find<IncomesController>().fetchIncomes(),
          if (Get.isRegistered<ExpencesController>())
            Get.find<ExpencesController>().fetchExpenses(),
          if (Get.isRegistered<ReminderController>())
            Get.find<ReminderController>().fetchReminders(),
        ]);
        print("Initial data fetch complete.");

        print("Triggering initial financial calculations...");
        if (Get.isRegistered<FinancialController>()) {
          await Get.find<FinancialController>().refreshAllCalculations();
        }
      } else {
        print("No valid session found. User must log in.");
        isLoggedIn.value = false;
      }
    } catch (e) {
      print("Error during auto-login: $e");
      await clearUserSession();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearUserSession() async {
    user.value = null;
    isLoggedIn.value = false;
    await _storage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    print(" User session cleared.");
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        Get.snackbar('Error', 'Authentication required. Please login again.');
        await clearUserSession();
        Get.offAllNamed('/Login');
        return;
      }

      final response = await _dio.post(
        '${_apiUrl}user/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar(
          'Success',
          'Password changed successfully! Please log in again.',
          snackPosition: SnackPosition.BOTTOM,
        );
        await clearUserSession();
        Get.offAllNamed('/Login');
      } else {
        throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            message: response.data['message'] ?? 'Password change failed');
      }
    } on DioException catch (e) {
      String errorMessage = e.response?.data['message'] ?? 'An error occurred.';
      Get.snackbar('Error', errorMessage, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
