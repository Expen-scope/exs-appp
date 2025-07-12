import 'package:abo_najib_2/const/Constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/LoginController.dart';

class LoginPage extends GetView<LoginController> {
  final _formKey = GlobalKey<FormState>();
//#006000
//#F8FCF8
//#DBF0DB
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFF8FCF8),
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.005),
          child: Form(
            key: controller.formKey,
            child: ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                _buildLogo(context),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05),
                  child: Column(
                    children: [
                      _buildTextField("Gmail", controller.emailController,
                          "Enter a valid email address"),
                      SizedBox(height: hight(context) * 0.001),
                      _buildPasswordField(),
                      SizedBox(height: hight(context) * 0.04),
                      _buildLoginButton(context),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account?",
                              style: TextStyle(
                                color: Color(0xFF006000),
                              )),
                          TextButton(
                            onPressed: () => Get.toNamed("/Register"),
                            child: Text("Register",
                                style: TextStyle(
                                  color: Color(0xFF006000),
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: MediaQuery.of(context).size.height * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/Photo/1.png',
            height: MediaQuery.of(context).size.height * 0.28,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController textController,
      String validationMsg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white, fontSize: 16)),
        SizedBox(height: 5),
        TextFormField(
          cursorColor: Color(0xFF006000),
          controller: textController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white,
                )),
            hintText: label,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white,
                )),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white, width: 2),
            ),
            filled: true,
            fillColor: Color(0xFFDBF0DB),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return validationMsg;
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Password", style: TextStyle(color: Colors.white, fontSize: 16)),
        SizedBox(height: 5),
        Obx(() => TextFormField(
              cursorColor: Color(0xFF006000),
              controller: controller.passwordController,
              obscureText: !controller.isPasswordVisible.value,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white,
                    )),
                hintText: 'Password',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white,
                    )),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white, width: 2),
                ),
                filled: true,
                fillColor: Color(0xFFDBF0DB),
                suffixIcon: IconButton(
                  icon: Icon(controller.isPasswordVisible.value
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: controller.togglePasswordVisibility,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return "Enter the password";
                return null;
              },
            )),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Color(0xFF006000),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onPressed: controller.validateInputs,
            child: controller.isLoading.value
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                    "LOGIN",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
          ),
        ));
  }
}
