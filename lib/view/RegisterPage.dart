import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/RegisterController.dart';
import '../utils/dialog_helper.dart';

class RegisterPage extends StatelessWidget {
  final RegisterController controller = Get.put(RegisterController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
//#006000
//#F8FCF8
//#DBF0DB
    return Scaffold(
      body: Container(
        color: Color(0xFFF8FCF8),
        width: double.infinity,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildLogo(context),
              _buildRegisterForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: MediaQuery.of(context).size.height * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.30,
            child: Image.asset(
              'assets/Photo/1.png',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05),
      child: Column(
        children: [
          _buildTextField("Enter your name",
              (val) => controller.name.value = val, controller.nameError),
          SizedBox(height: MediaQuery.of(context).size.width * 0.01),
          _buildTextField("Enter Email", (val) => controller.email.value = val,
              controller.emailError),
          SizedBox(height: MediaQuery.of(context).size.width * 0.01),
          _buildTextField(
              "Enter Password",
              (val) => controller.password.value = val,
              controller.passwordError,
              obscureText: true),
          SizedBox(height: MediaQuery.of(context).size.width * 0.01),
          _buildTextField(
              "Confirm Password",
              (val) => controller.confirmPassword.value = val,
              controller.confirmPasswordError,
              obscureText: true),
          SizedBox(height: 20),
          _buildRegisterButton(),
          _buildLoginText(),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, Function(String) onChanged, RxnString errorText,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white, fontSize: 16)),
        Obx(() => TextFormField(
              cursorColor: Color(0xFF006000),
              obscureText: obscureText
                  ? (label == "Enter Password"
                      ? !controller.isPasswordVisible.value
                      : !controller.isConfirmPasswordVisible.value)
                  : false,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white,
                    )),
                hintText: label,
                errorText: errorText.value,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white, width: 2),
                ),
                filled: true,
                fillColor: Color(0xFFDBF0DB),
                suffixIcon: label.contains("Password")
                    ? IconButton(
                        icon: Icon(
                          (label == "Enter Password"
                                  ? controller.isPasswordVisible.value
                                  : controller.isConfirmPasswordVisible.value)
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: label == "Enter Password"
                            ? controller.togglePasswordVisibility
                            : controller.toggleConfirmPasswordVisibility,
                      )
                    : null,
              ),
              onChanged: onChanged,
            )),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Color(0xFF006000),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
            ),
            onPressed:
                controller.isLoading.value ? null : controller.registerUser,
            child: controller.isLoading.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text("Register",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ));
  }

  Widget _buildLoginText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Already have an account?",
            style: TextStyle(color: Color(0xFF006000))),
        TextButton(
          onPressed: () => Get.offAllNamed("/Login"),
          child: Text("Login", style: TextStyle(color: Color(0xFF006000))),
        ),
      ],
    );
  }
}
