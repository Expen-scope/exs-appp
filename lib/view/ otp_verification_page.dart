import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpVerificationPage extends StatelessWidget {
  final String email;

  OtpVerificationPage({required this.email});

  final RxString otpCode = "".obs;
  final RxBool isLoading = false.obs;

  void verifyOtp() async {
    if (otpCode.value.length != 6) {
      Get.snackbar("Error", "Please enter a valid 6-digit OTP");
      return;
    }

    isLoading.value = true;

    try {
      var response = await HttpHel.verifyOtp(email, otpCode.value);
      if (response['success']) {
        Get.offAllNamed("/Login");
      } else {
        Get.snackbar("Error", response['message']);
      }

      await Future.delayed(Duration(seconds: 2)); // simulate API call
      Get.snackbar("Success", "OTP Verified. Account activated.");
      Get.offAllNamed("/Login");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Verify OTP"), backgroundColor: Color(0xFF006000)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text("Enter the 6-digit OTP sent to $email",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            PinCodeTextField(
              appContext: context,
              length: 6,
              onChanged: (val) => otpCode.value = val,
              keyboardType: TextInputType.number,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
                selectedFillColor: Colors.white,
                inactiveFillColor: Colors.white,
                activeColor: Color(0xFF006000),
                selectedColor: Color(0xFF006000),
                inactiveColor: Colors.grey,
              ),
            ),
            SizedBox(height: 20),
            Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF006000),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: isLoading.value ? null : verifyOtp,
                  child: isLoading.value
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Verify",
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                )),
          ],
        ),
      ),
    );
  }
}

class HttpHel {
  static final Dio dio = Dio(BaseOptions(baseUrl: 'http://0.0.0.0:8000/api'));

  static Future<dynamic> verifyOtp(String email, String otp) async {
    try {
      Response response = await dio.post('/verify-otp', data: {
        'email': email,
        'otp': otp,
      });

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'OTP verified'
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Verification failed'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
