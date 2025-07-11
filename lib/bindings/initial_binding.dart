import 'package:abo_najib_2/controller/ExpensesController.dart';
import 'package:abo_najib_2/controller/FinancialController.dart';
import 'package:abo_najib_2/controller/IncomesController.dart';
import 'package:abo_najib_2/controller/LoginController.dart';
import 'package:abo_najib_2/controller/RegisterController.dart';
import 'package:abo_najib_2/controller/user_controller.dart';
import 'package:get/get.dart';

import '../controller/GoalController.dart';
import '../controller/ReminderController.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(UserController(), permanent: true);
    Get.put(FinancialController(), permanent: true);

    Get.lazyPut(() => LoginController());
    Get.lazyPut(() => RegisterController());
    Get.lazyPut(() => ExpencesController());
    Get.lazyPut(() => IncomesController());
    Get.lazyPut(() => GoalController());
    Get.lazyPut(() => ReminderController());
  }
}