import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/ExpensesController.dart';
import '../controller/FinancialController.dart';
import '../controller/GoalController.dart';
import '../controller/IncomesController.dart';
import '../controller/LoginController.dart';
import '../controller/RegisterController.dart';
import '../controller/ReminderController.dart';
import '../controller/user_controller.dart';

class MyCustomSplashScreen extends StatefulWidget {
  @override
  _MyCustomSplashScreenState createState() => _MyCustomSplashScreenState();
}

class _MyCustomSplashScreenState extends State<MyCustomSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fontSizeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fontSizeAnimation = Tween<double>(
      begin: 20.0,
      end: 40.0,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn))
      ..addListener(() {
        setState(() {});
      });

    _animationController.forward();

    _initializeAppAndNavigate();
  }

  Future<void> _initializeAppAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));

    print("Initializing All Controllers");
    Get.put(UserController(), permanent: true);
    Get.put(IncomesController(), permanent: true);
    Get.put(ExpencesController(), permanent: true);
    Get.put(ReminderController(), permanent: true);
    Get.put(FinancialController(), permanent: true);
    Get.put(GoalController(), permanent: true);
    Get.lazyPut(() => LoginController());
    Get.lazyPut(() => RegisterController());
    print("All Controllers Initialized");

    await Get.find<UserController>().tryAutoLogin();

    if (Get.find<UserController>().isLoggedIn.value) {
      print("User is logged in. Navigating to HomePage.");
      Get.offAllNamed('/HomePage');
    } else {
      print("User is not logged in. Navigating to WelcomeScreen.");
      Get.offAllNamed('/WelcomeScreen');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Photo/logo.png',
              height: 180,
            ),
            const SizedBox(height: 30),
            Text(
              'Exs',
              style: TextStyle(
                color: Color(0xFF006000),
                fontWeight: FontWeight.bold,
                fontSize: _fontSizeAnimation.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
