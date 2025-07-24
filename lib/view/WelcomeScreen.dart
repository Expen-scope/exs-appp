import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

//#006000
//#F8FCF8
//#DBF0DB
const Color primaryDarkColor = Color(0xFFF8FCF8);
const Color primaryLightColor = Color(0xFFF8FCF8);
const Color whiteColor = Colors.white;

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryDarkColor, primaryLightColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: [
                  Image.asset(
                    'assets/Photo/photo_2025-07-11_16-23-44.jpg',
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.35,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width * 0.02),
                  Text(
                    'Welcome to Exs',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF006000),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width * 0.02),
                  Text(
                    'Track your expenses, analyze your spending, and achieve your financail goals with ease.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF006000), fontSize: 16),
                  ),
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.05,
                      right: MediaQuery.of(context).size.width * 0.05,
                      bottom: MediaQuery.of(context).size.width * 0.05,
                    ),
                    child: _buildAuthButton(
                      context: context,
                      label: 'Login',
                      onPressed: () {
                        Get.offAllNamed("/Login");
                      },
                      backgroundColor: whiteColor,
                      textColor: primaryDarkColor,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.05,
                      right: MediaQuery.of(context).size.width * 0.05,
                      bottom: MediaQuery.of(context).size.width * 0.1,
                    ),
                    child: _buildAuthButton(
                      context: context,
                      label: 'Register',
                      onPressed: () {
                        Get.offNamed("/Register");
                      },
                      backgroundColor: Colors.transparent,
                      textColor: whiteColor,
                      borderColor: whiteColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF006000),
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
            side: borderColor != null
                ? BorderSide(color: borderColor, width: 1.5)
                : BorderSide.none,
          ),
          elevation: backgroundColor == Colors.transparent ? 0 : 5,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
