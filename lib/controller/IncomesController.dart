import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/Incomes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IncomesController extends GetxController {
  var incomes = <Income>[].obs;
  var selectedCategory = 'Salary'.obs;
  final String baseUrl = "http://0.0.0.0:8000/api/";
  late String? authToken;

  final Map<String, IncomeInfo> incomeCategoriesData = {
    "Salary": IncomeInfo(
        color: Color(0xff167dfe),
        icon: Icon(
          Icons.work,
          color: Color(0xff167dfe),
        )),
    "Bonus": IncomeInfo(
        color: Color(0xffd615ff),
        icon: Icon(
          Icons.card_giftcard,
          color: Color(0xffd615ff),
        )),
    "Investment": IncomeInfo(
        color: Color(0xfffa5f48),
        icon: Icon(
          Icons.trending_up,
          color: Color(0xfffa5f48),
        )),
    "Freelance": IncomeInfo(
        color: Color(0xff6ed4a5),
        icon: Icon(
          Icons.computer,
          color: Color(0xff6ed4a5),
        )),
    "Other": IncomeInfo(
        color: Color(0xfff8b107),
        icon: Icon(
          Icons.category,
          color: Color(0xfff8b107),
        )),
  };

  List<String> get incomeCategories => incomeCategoriesData.keys.toList();

  @override
  void onInit() {
    super.onInit();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');
    await fetchIncomes();
  }

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    };
  }

  Future<void> fetchIncomes() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}Income'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'];

        incomes.value = data.map((e) => Income.fromJson(e)).toList();
        incomes.refresh();

        print('Successfully loaded ${incomes.length} incomes');
      } else {
        Get.snackbar('Error', 'Failed to load incomes');
      }
    } catch (e) {
      print('Fetch error: $e');
      Get.snackbar('Error', 'Failed to load incomes: $e');
    }
  }

  Future<void> addIncome(Income income) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}addIncome'),
        headers: _headers,
        body: json.encode({
          'nameinc': income.name,
          'price': income.price,
          'category': income.category,
          'time': income.time,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        final newIncome = Income.fromJson(responseData['data']);
        incomes.add(newIncome);
        incomes.refresh();

        Get.back();
        await fetchIncomes();

        Get.snackbar('Success', 'Income added successfully');
      } else {
        Get.snackbar(
            'Error', responseData['message'] ?? 'Failed to add income');
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e');
    }
  }

  Future<void> deleteIncome(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}deleteIncome/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        incomes.removeWhere((income) => income.id == id);
        update();
      } else {
        Get.snackbar('Error', 'Failed to delete income');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete income');
    }
  }
}

class IncomeInfo {
  final Color color;
  final Icon icon;

  IncomeInfo({required this.color, required this.icon});
}
