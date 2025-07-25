import 'package:abo_najib_2/controller/user_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/Incomes.dart';

class IncomesController extends GetxController {
  var incomes = <Income>[].obs;
  var incomeCategories = <String>[].obs;
  var isDataLoading = false.obs;

  final String baseUrl = "https://f1fc42afeee8.ngrok-free.app/api";
  // final String baseUrl = "http://10.0.2.2:8000/api";

  final _storage = const FlutterSecureStorage();
  String? authToken;

  final List<String> _defaultIncomeCategories = [
    'Salary',
    'Business Income',
    'Freelance/Side Hustles',
    'Investments',
    'Rental Income',
    'Dividends',
    'Interest Income',
    'Gifts',
    'Refunds/Reimbursements',
    'Bonuses',
  ];
  final Map<String, CategoryInfo> incomeCategoriesData = {
    'Salary': CategoryInfo(color: Colors.green, icon: Icon(Icons.attach_money)),
    'Business Income': CategoryInfo(
      color: Colors.blue,
      icon: Icon(Icons.business_center),
    ),
    'Freelance/Side Hustles': CategoryInfo(
      color: Colors.orange,
      icon: Icon(Icons.work_outline),
    ),
    'Investments': CategoryInfo(
      color: Colors.purple,
      icon: Icon(Icons.show_chart),
    ),
    'Rental Income': CategoryInfo(
      color: Colors.teal,
      icon: Icon(Icons.home_work),
    ),
    'Dividends': CategoryInfo(
      color: Colors.indigo,
      icon: Icon(Icons.pie_chart),
    ),
    'Interest Income': CategoryInfo(
      color: Colors.brown,
      icon: Icon(Icons.account_balance),
    ),
    'Gifts': CategoryInfo(color: Colors.pink, icon: Icon(Icons.card_giftcard)),
    'Refunds/Reimbursements': CategoryInfo(
      color: Colors.cyan,
      icon: Icon(Icons.reply),
    ),
    'Bonuses': CategoryInfo(color: Colors.red, icon: Icon(Icons.star)),
  };

  @override
  void onInit() {
    super.onInit();
    incomeCategories.assignAll(_defaultIncomeCategories);
  }

  Future<String?> _getAuthToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> reloadDataAfterLogin() async {
    print("[IncomesCtrl] Reloading data after successful login...");
    await _loadTokenAndFetchData();
  }

  Future<void> _loadTokenAndFetchData() async {
    authToken = await _storage.read(key: 'access_token');
    if (authToken == null) {
      print("[IncomesCtrl]  Auth token not found.");
      return;
    }
    print("[IncomesCtrl]  Auth token loaded.");
    await Future.wait([fetchIncomes(), fetchCategories()]);
  }

  Future<void> fetchCategories() async {
    if (authToken == null) return;
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      };
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final customCategories = List<String>.from(data['income_categories']);
        final combinedSet = {..._defaultIncomeCategories, ...customCategories};
        incomeCategories.assignAll(combinedSet.toList());
      } else {
        print(
          "Failed to load categories, using defaults. Status: ${response.statusCode}",
        );
        incomeCategories.assignAll(_defaultIncomeCategories);
      }
    } catch (e) {
      print("Error fetching categories: $e");
      incomeCategories.assignAll(_defaultIncomeCategories);
    }
  }

  Future<void> fetchIncomes() async {
    isDataLoading.value = true;
    final token = await _getAuthToken();
    if (token == null) {
      print("[IncomesCtrl] Auth token not found. Cannot fetch data.");
      isDataLoading.value = false;
      Get.snackbar('Authentication Error', 'Please login again.');
      await Get.find<UserController>().clearUserSession();
      Get.offAllNamed('/Login');
      return;
    }

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/user/transactions'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List dataList =
            responseData is List ? responseData : responseData['data'];
        final incomeData =
            dataList.where((e) => e['type_transaction'] == 'income').toList();
        incomes.value = incomeData.map((e) => Income.fromJson(e)).toList();
        print("Incomes fetched successfully.");
      } else if (response.statusCode == 401) {
        print("Token expired or unauthorized. Logging out user.");
        Get.snackbar('Session Expired', 'Please login again.');
        await Get.find<UserController>().clearUserSession();
        Get.offAllNamed('/Login');
      } else {
        Get.snackbar(
            'Error Fetching Incomes', 'Status: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred during fetchIncomes: $e');
    } finally {
      isDataLoading.value = false;
    }
  }

  Future<void> addIncome(Income income) async {
    final token = await _getAuthToken();
    if (token == null) {
      Get.snackbar("Authentication Error", "Please log in again.");
      return;
    }
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final response = await http.post(
        Uri.parse('$baseUrl/user/transactions'),
        headers: headers,
        body: json.encode(income.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar('Success', 'Incomes added successfully!');
        await fetchIncomes();
        Get.snackbar('Success', 'Incomes added successfully!');

        Future.delayed(Duration(milliseconds: 800), () {
          Get.offNamed('/IncomesScreens');
        });
      } else {
        Get.snackbar('Error Adding', 'Failed to add income. Please try again.');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
      print("$e");
    }
  }

  Future<void> deleteIncome(int id) async {
    final token = await _getAuthToken();
    if (token == null) return;
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final response = await http.delete(
        Uri.parse('$baseUrl/user/transactions/$id'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Income removed successfully!');
        incomes.removeWhere((inc) => inc.id == id);
      } else {
        Get.snackbar('Error Deleting', 'Failed to remove income.');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }
}

class CategoryInfo {
  final Color color;
  final Icon icon;
  CategoryInfo({required this.color, required this.icon});
}
