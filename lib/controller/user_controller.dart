// ملف: controller/user_controller.dart

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/User.dart';

// استيراد الكنترولرات الأخرى
import 'IncomesController.dart';
import 'ExpensesController.dart';
import 'ReminderController.dart';

class UserController extends GetxController {
  // --- 1. المتغيرات الأساسية (State) ---
  final RxBool isLoggedIn = false.obs;
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = true.obs;
  var selectedImage = Rx<File?>(null);

  // --- 2. الأدوات والأدوات المساعدة ---
  final String _apiUrl = "http://10.0.2.2:8000/api/";
  final _storage = const FlutterSecureStorage();
  final _dio = Dio();

  // --- 3. دورة حياة الكنترولر ---
  @override
  void onInit() {
    super.onInit();
    // onInit يجب أن يكون نظيفًا. سيتم استدعاء tryAutoLogin من SplashScreen.
  }

  // --- 4. منطق المصادقة الرئيسي (Authentication Logic) ---

  /// هذه هي الدالة الوحيدة المسؤولة عن تسجيل الدخول التلقائي عند بدء تشغيل التطبيق.
  Future<void> tryAutoLogin() async {
    isLoading.value = true;
    try {
      final token = await _storage.read(key: 'access_token');
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      if (token != null && userDataString != null) {
        print("✅ Session found. Logging in automatically.");
        user.value = UserModel.fromJson(json.decode(userDataString));
        isLoggedIn.value = true;

        print("🚀 Triggering initial data fetch for all controllers...");
        await Future.wait([
          if (Get.isRegistered<IncomesController>())
            Get.find<IncomesController>().fetchIncomes(),
          if (Get.isRegistered<ExpencesController>())
            Get.find<ExpencesController>().fetchExpenses(),
          if (Get.isRegistered<ReminderController>())
            Get.find<ReminderController>().fetchReminders(),
        ]);
        print("👍 Initial data fetch complete.");
      } else {
        print("❌ No valid session found. User must log in.");
        isLoggedIn.value = false;
      }
    } catch (e) {
      print("🔥 Error during auto-login: $e");
      await clearUserSession();
    } finally {
      isLoading.value = false;
    }
  }

  /// دالة لتنظيف كل بيانات الجلسة عند تسجيل الخروج أو حدوث خطأ.
  Future<void> clearUserSession() async {
    user.value = null;
    isLoggedIn.value = false;
    await _storage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    print("🧹 User session cleared.");
  }

  /// دالة مساعدة للحصول على التوكن الحالي من المكان الصحيح.
  Future<String?> getAuthToken() async {
    return await _storage.read(key: 'access_token');
  }

  // --- 5. وظائف إضافية (User Profile, etc.) ---

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = File(image.path);
      // يمكنك هنا إضافة منطق لرفع الصورة إلى الخادم وتحديثها.
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // استخدم الدالة المساعدة الجديدة للحصول على التوكن
      final token = await getAuthToken();
      if (token == null) {
        Get.snackbar('Error', 'Authentication required. Please login again.');
        await clearUserSession();
        Get.offAllNamed('/Login');
        return;
      }

      final response = await _dio.post(
        '${_apiUrl}user/changePassword', // تأكد من صحة مسار الـ API
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
        await clearUserSession(); // يجب تسجيل الخروج بعد تغيير كلمة المرور
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
