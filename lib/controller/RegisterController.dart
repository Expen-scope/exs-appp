import 'package:get/get.dart';
import 'package:dio/dio.dart' as Dio;

import '../const/Constants.dart';
import '../utils/dialog_helper.dart';

class RegisterController extends GetxController {
  var name = ''.obs;
  var email = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;
  var nameError = RxnString();
  var emailError = RxnString();
  var passwordError = RxnString();
  var confirmPasswordError = RxnString();
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;

  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  final Dio.Dio dio = Dio.Dio(
    Dio.BaseOptions(
      baseUrl: baseUrl,
      // baseUrl: "http://10.0.2.2:8000/api",

      contentType: Dio.Headers.jsonContentType,
      validateStatus: (status) => status! < 500,
    ),
  );

  void validateInputs() {
    nameError.value = name.value.isEmpty ? "You must enter the name" : null;

    if (email.value.isEmpty) {
      emailError.value = "You must enter an email";
    } else if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email.value)) {
      emailError.value = "Invalid email format";
    } else {
      emailError.value = null;
    }

    if (password.value.isEmpty) {
      passwordError.value = "You must enter the password";
    } else if (password.value.length < 8) {
      passwordError.value = "Password must be at least 8 characters long.";
    } else if (!RegExp(r'[A-Z]').hasMatch(password.value)) {
      passwordError.value =
          "Password must contain at least one uppercase letter.";
    } else if (!RegExp(r'[0-9]').hasMatch(password.value)) {
      passwordError.value = "Password must contain at least one number.";
    } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password.value)) {
      passwordError.value =
          "Password must contain at least one special character.";
    } else {
      passwordError.value = null;
    }

    if (confirmPassword.value.isEmpty) {
      confirmPasswordError.value = "You must enter a password confirmation.";
    } else if (password.value != confirmPassword.value) {
      confirmPasswordError.value = "Passwords do not match";
    } else {
      confirmPasswordError.value = null;
    }
  }

  Future<void> registerUser() async {
    validateInputs();

    if (nameError.value == null &&
        emailError.value == null &&
        passwordError.value == null &&
        confirmPasswordError.value == null) {
      isLoading.value = true;

      try {
        final response = await dio.post(
          '/user/register',
          data: {
            'name': name.value,
            'email': email.value,
            'password': password.value,
            'password_confirmation': confirmPassword.value,
          },
        );

        print(' Full Response: ${response.data}');

        if ([200, 201].contains(response.statusCode)) {
          showSuccessDialog();
        } else {
          handleServerErrors(response.data);
        }
      } on Dio.DioException catch (e) {
        print(' Dio Error: ${e.message}');
        showErrorDialog(
          "Connection error: ${e.message ?? 'An unknown error has occurred'}",
        );
      } on FormatException catch (e) {
        print(' Format Error: $e');
        showErrorDialog("Data format error: ${e.message}");
      } catch (e) {
        print(' Critical Error: $e');
        showErrorDialog("An unexpected error occurred: ${e.toString()}");
      } finally {
        isLoading.value = false;
      }
    }
  }

  void handleServerErrors(Map<String, dynamic>? data) {
    if (data?['errors'] != null) {
      final errors = data!['errors'];

      if (errors.containsKey('email')) {
        emailError.value = errors['email'][0];
      }
      if (errors.containsKey('password')) {
        passwordError.value = errors['password'][0];
      }
      if (errors.containsKey('name')) {
        nameError.value = errors['name'][0];
      }
    } else {
      showErrorDialog(data?['message'] ?? "An unexpected error occurred");
    }
  }

  void showSuccessDialog() {
    DialogHelper.showSuccessDialog(
      title: "success",
      message: "Now, please verify your account to complete the setup.",
      onOkPressed: () {
        Get.toNamed("/OtpVerificationPage");
      },
    );
  }

  void showErrorDialog(String message) {
    DialogHelper.showErrorDialog(title: "Error", message: message);
  }
}
