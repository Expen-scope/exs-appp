import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/Expenses.dart';
import '../view/AddExpense.dart'; // تأكد من المسار الصحيح

class ExpencesController extends GetxController {
  // --- State Variables ---
  var listExpenses = <Expense>[].obs;
  var expenseCategories = <String>[].obs;
  var isDataLoading = false.obs;

  // --- Configuration ---
  final String baseUrl = "http://10.0.2.2:8000/api";
  final _storage = const FlutterSecureStorage();
  String? authToken;

  final List<String> _defaultExpenseCategories = [
    'Housing',
    'Utilities',
    'Transportation',
    'Groceries',
    'Dining Out',
    'Healthcare',
    'Insurance',
    'Debt Payments',
    'Entertainment',
    'Personal Care'
  ];

  // --- Lifecycle ---
  @override
  void onInit() {
    super.onInit();
    // قم بتهيئة القائمة الافتراضية فوراً
    expenseCategories.assignAll(_defaultExpenseCategories);
    _loadTokenAndFetchData();
  }

  // --- Data Loading ---
  Future<void> reloadDataAfterLogin() async {
    print("[ExpensesCtrl] 🔄 Reloading data after successful login...");
    await _loadTokenAndFetchData();
  }

  Future<void> _loadTokenAndFetchData() async {
    authToken = await _storage.read(key: 'access_token');
    if (authToken == null) {
      print("[ExpensesCtrl] ❌ Auth token not found.");
      return;
    }
    print("[ExpensesCtrl] ✅ Auth token loaded.");
    await Future.wait([
      fetchExpenses(),
      fetchCategories(),
    ]);
  }

  // --- API Calls ---

  Future<void> fetchCategories() async {
    if (authToken == null) return;
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      };
      final response =
          await http.get(Uri.parse('$baseUrl/categories'), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final customCategories = List<String>.from(data['expense_categories']);
        final combinedSet = {..._defaultExpenseCategories, ...customCategories};
        expenseCategories.assignAll(combinedSet.toList());
      } else {
        print(
            "Failed to load categories, using defaults. Status: ${response.statusCode}");
        expenseCategories.assignAll(_defaultExpenseCategories);
      }
    } catch (e) {
      print("Error fetching categories: $e");
      expenseCategories.assignAll(_defaultExpenseCategories);
    }
  }

  Future<void> fetchExpenses() async {
    if (authToken == null) return;
    isDataLoading.value = true;
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      };
      final response = await http.get(Uri.parse('$baseUrl/user/transactions'),
          headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // تأكد من أن الـ response يحتوي على مفتاح 'data' وهو عبارة عن List
        if (responseData is List) {
          final expenseData = responseData
              .where((e) => e['type_transaction'] == 'expense')
              .toList();
          listExpenses.value =
              expenseData.map((e) => Expense.fromJson(e)).toList();
        } else if (responseData['data'] is List) {
          final data = responseData['data'] as List;
          final expenseData =
              data.where((e) => e['type_transaction'] == 'expense').toList();
          listExpenses.value =
              expenseData.map((e) => Expense.fromJson(e)).toList();
        }
      } else {
        Get.snackbar('Error Fetching',
            'Failed to load expenses. Status: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred during fetchExpenses: $e');
    } finally {
      isDataLoading.value = false;
    }
  }

  Future<void> addExpense(Expense expense) async {
    if (authToken == null) {
      Get.snackbar("Authentication Error", "Please log in again.");
      return;
    }
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      };
      final response = await http.post(
        Uri.parse('$baseUrl/user/transactions'),
        headers: headers,
        body: json.encode(expense.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar('Success', 'Expense added successfully!');
        await fetchExpenses();
        Get.back();       } else {
        print(
            'Failed to add expense. Status: ${response.statusCode}, Body: ${response.body}');
        Get.snackbar(
            'Error Adding', 'Failed to add expense. Please try again.');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  Future<void> removeExpense(int id) async {
    if (authToken == null) return;
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      };
      final response = await http.delete(
          Uri.parse('$baseUrl/user/transactions/$id'),
          headers: headers);

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Expense removed successfully!');
        listExpenses.removeWhere((exp) => exp.id == id);
      } else {
        Get.snackbar('Error Deleting',
            'Failed to remove expense. Status: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }
}
