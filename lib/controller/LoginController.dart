import 'package:abo_najib_2/controller/IncomesController.dart';
import 'package:abo_najib_2/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/User.dart';
import '../utils/dialog_helper.dart';
import 'ExpensesController.dart';
import 'FinancialController.dart';
import 'ReminderController.dart';

class LoginController extends GetxController {
  final Dio.Dio dio = Dio.Dio(
    Dio.BaseOptions(
      baseUrl: 'https://f1fc42afeee8.ngrok-free.app/api',
      // baseUrl: "http://10.0.2.2:8000/api",

      contentType: Dio.Headers.jsonContentType,
      validateStatus: (status) => status! < 500,
    ),
  );

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  final _storage = const FlutterSecureStorage();

  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void validateInputs() {
    if (formKey.currentState!.validate()) loginUser();
  }

  Future<void> loginUser() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final response = await dio.post(
        '/user/login',
        data: {
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        },
      );

      if (response.statusCode == 200 && response.data['access_token'] != null) {
        final user = UserModel.fromJson(response.data['user']);
        final accessToken = response.data['access_token'];
        final n8nToken = response.data['n8n_session_token'];
        print("$accessToken");
        print("$n8nToken");

        await _saveAuthData(user, accessToken, n8nToken);

        _showSuccessDialog();
      } else {
        String errorMessage =
            response.data['message'] ?? 'Invalid email or password';
        DialogHelper.showErrorDialog(
          title: 'Login Error',
          message: errorMessage,
        );
      }
    } on Dio.DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      _handleGenericError(e);
    } finally {
      isLoading.value = false;
      emailController.clear();
      passwordController.clear();
    }
  }

  Future<void> _saveAuthData(
    UserModel user,
    String accessToken,
    String n8nToken,
  ) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'n8n_session_token', value: n8nToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', user.toJsonString());

    Get.find<UserController>()
      ..user.value = user
      ..isLoggedIn.value = true;

    print("Reloading data for all controllers after login...");

    if (Get.isRegistered<ExpencesController>()) {
      await Get.find<ExpencesController>().fetchExpenses();
    }

    if (Get.isRegistered<IncomesController>()) {
      await Get.find<IncomesController>().fetchIncomes();
    }

    if (Get.isRegistered<ReminderController>()) {
      await Get.find<ReminderController>().fetchReminders();
    }

    print('Access Token saved and all data reloaded successfully.');
    await Get.find<FinancialController>().refreshAllCalculations();
  }

  Future<void> logout() async {
    DialogHelper.showConfirmDialog(
      title: 'Confirm Logout',
      message: 'Are you sure you want to logout?',
      onConfirm: () async {
        await _storage.delete(key: 'access_token');
        await _storage.delete(key: 'n8n_session_token');

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_data');

        Get.find<UserController>().clearUserSession();

        Get.offAllNamed('/login');
      },
    );
  }

  void _handleDioError(Dio.DioException e) {
    String errorMessage = 'An unexpected error occurred.';
    if (e.type == Dio.DioExceptionType.connectionTimeout ||
        e.type == Dio.DioExceptionType.connectionError) {
      errorMessage =
          'Unable to connect to the server. Please check your internet connection.';
    } else if (e.response != null) {
      errorMessage =
          e.response?.data['message'] ?? 'Login failed. Please try again.';
    }
    DialogHelper.showErrorDialog(title: 'Network Error', message: errorMessage);
  }

  void _handleGenericError(dynamic e) {
    DialogHelper.showErrorDialog(
      title: 'Error',
      message: 'An unknown error occurred: ${e.toString()}',
    );
  }

  void _showSuccessDialog() {
    DialogHelper.showSuccessDialog(
      title: "Success",
      message: "You have been logged in successfully.",
      onOkPressed: () => Get.offAllNamed('/HomePage'),
    );
  }
}
