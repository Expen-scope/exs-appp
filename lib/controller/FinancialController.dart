import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/ExpensesController.dart';
import '../controller/IncomesController.dart';
import '../model/Expenses.dart';
import '../model/Incomes.dart';

enum ActiveTab { expenses, incomes, analysis }

class FinancialController extends GetxController {
  final IncomesController incomesController = Get.find();
  final ExpencesController expensesController = Get.find();

  final activeTab = ActiveTab.expenses.obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpenses = 0.0.obs;
  final RxDouble balance = 0.0.obs;
  final RxDouble savingsRate = 0.0.obs;
  final RxDouble incomePercentageChange = 0.0.obs;
  final RxDouble expensePercentageChange = 0.0.obs;
  final RxList<Map<String, dynamic>> transactions =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> categoryAnalysis =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> monthlyTrends =
      <Map<String, dynamic>>[].obs;
  final RxString selectedPeriod = 'month'.obs;
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxList<Map<String, dynamic>> incomeExpenseComparisonData =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> savingsTrendData =
      <Map<String, dynamic>>[].obs;
  final DateFormat apiDateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  void onInit() {
    super.onInit();
    _setDefaultPeriod();
    fetchAllData();
    _setupDataListeners();
  }

  var analysisWidgetOrder = <String>[
    'income_vs_expense',
    'savings_rate',
    'category_breakdown',
    'summary_table',
  ].obs;
  void _processIncomeExpenseComparison() {
    incomeExpenseComparisonData.assignAll(monthlyTrends);
  }

  Future<void> fetchAllData() async {
    isLoading.value = true;
    try {
      await incomesController.fetchIncomes();
      await expensesController.fetchExpenses();
      loadData();
    } catch (e) {
      errorMessage.value = 'Failed to fetch data: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  void _setDefaultPeriod() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    startDate.value = start;
    endDate.value = end;
  }

  void _processSavingsTrend() {
    double cumulativeBalance = 0.0;
    final trendData = monthlyTrends.map((trend) {
      cumulativeBalance += (trend['balance'] as double);
      return {
        'period': trend['month'],
        'balance': trend['balance'],
        'cumulativeBalance': cumulativeBalance,
      };
    }).toList();

    savingsTrendData.assignAll(trendData);
  }

  void _setupDataListeners() {
    ever(incomesController.incomes, (_) {
      print(
        "FinancialController: Detected change in INCOMES. Reloading data...",
      );
      loadData();
    });
    ever(expensesController.listExpenses, (_) {
      print(
        "FinancialController: Detected change in EXPENSES. Reloading data...",
      );
      loadData();
    });
  }

  void changeTab(ActiveTab tab) {
    activeTab.value = tab;
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await Future.delayed(Duration.zero);
      _processData();
    } catch (e) {
      print('ERROR in FinancialController -> loadData: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _processData() {
    print("--- Starting _processData ---");
    print("Incomes count: ${incomesController.incomes.length}");
    print("Expenses count: ${expensesController.listExpenses.length}");

    if (incomesController.incomes.isEmpty &&
        expensesController.listExpenses.isEmpty) {
      print("Both lists are empty. Clearing all values.");
      totalIncome.value = 0.0;
      totalExpenses.value = 0.0;
      balance.value = 0.0;
      transactions.clear();
      categoryAnalysis.clear();
      monthlyTrends.clear();
      _calculateTotals();
      _calculateBalance();

      if (totalIncome.value > 0) {
        savingsRate.value = (balance.value / totalIncome.value) * 100;
      } else {
        savingsRate.value = 0.0;
      }

      _processTransactions();
      _processCategoryAnalysis();
      _processMonthlyTrends();
      _calculatePercentageChanges();
      _processIncomeExpenseComparison();
      incomeExpenseComparisonData.clear();
      savingsTrendData.clear();

      print("--- Finished _processData (early exit) ---");
      return;
    }

    _calculateTotals();
    _calculateBalance();
    _processTransactions();
    _processCategoryAnalysis();
    _processMonthlyTrends();
    _calculatePercentageChanges();

    _processIncomeExpenseComparison();
    _processSavingsTrend();

    print("--- Finished _processData (full run) ---");
  }

  void _calculateTotals() {
    final filteredIncomes = _filterByDateRange(incomesController.incomes);
    final filteredExpenses = _filterByDateRange(
      expensesController.listExpenses,
    );

    totalIncome.value = filteredIncomes.fold(
      0.0,
      (sum, income) => sum + income.price,
    );
    totalExpenses.value = filteredExpenses.fold(
      0.0,
      (sum, expense) => sum + expense.price,
    );
  }

  void _calculateBalance() {
    balance.value = totalIncome.value - totalExpenses.value;
  }

  void _processTransactions() {
    final filteredIncomes = _filterByDateRange(incomesController.incomes);
    final filteredExpenses = _filterByDateRange(
      expensesController.listExpenses,
    );

    final combined = [
      ...filteredIncomes.map((income) => _incomeToTransaction(income)),
      ...filteredExpenses.map((expense) => _expenseToTransaction(expense)),
    ];

    combined.sort((a, b) {
      try {
        DateTime dateA = apiDateFormat.parse(a['rawDate']);
        DateTime dateB = apiDateFormat.parse(b['rawDate']);
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    transactions.assignAll(combined);
  }

  void _processCategoryAnalysis() {
    final categoryMap = <String, double>{};
    final filteredIncomes = _filterByDateRange(incomesController.incomes);
    final filteredExpenses = _filterByDateRange(
      expensesController.listExpenses,
    );
    final incomeCategoryMap = <String, double>{};
    final expenseCategoryMap = <String, double>{};

    for (final income in filteredIncomes) {
      incomeCategoryMap.update(
        income.category,
        (value) => value + income.price,
        ifAbsent: () => income.price,
      );
    }
    for (final expense in filteredExpenses) {
      expenseCategoryMap.update(
        expense.category,
        (value) => value + expense.price,
        ifAbsent: () => expense.price,
      );
    }

    final combinedCategories = <Map<String, dynamic>>[];
    final totalAbsoluteValue =
        incomeCategoryMap.values.fold(0.0, (sum, val) => sum + val) +
            expenseCategoryMap.values.fold(0.0, (sum, val) => sum + val);

    incomeCategoryMap.forEach((category, amount) {
      final categoryInfo = incomesController.incomeCategoriesData[category] ??
          CategoryInfo(color: Colors.grey, icon: Icon(Icons.help));
      final percentage = totalAbsoluteValue == 0
          ? '0.0'
          : ((amount / totalAbsoluteValue) * 100).toStringAsFixed(1);
      combinedCategories.add({
        'category': category,
        'amount': amount,
        'color': categoryInfo.color,
        'icon': categoryInfo.icon,
        'percentage': percentage,
        'type': 'income',
      });
    });

    expenseCategoryMap.forEach((category, amount) {
      final categoryInfo = expensesController.expenseCategoriesData[category] ??
          CategoryInfo(color: Colors.grey, icon: Icon(Icons.help));
      final percentage = totalAbsoluteValue == 0
          ? '0.0'
          : ((amount / totalAbsoluteValue) * 100).toStringAsFixed(1);
      combinedCategories.add({
        'category': category,
        'amount': amount,
        'color': categoryInfo.color,
        'icon': categoryInfo.icon,
        'percentage': percentage,
        'type': 'expense',
      });
    });

    categoryAnalysis.assignAll(combinedCategories);
  }

  void _calculatePercentageChanges() {
    if (selectedPeriod.value != 'month') {
      incomePercentageChange.value = 0.0;
      expensePercentageChange.value = 0.0;
      return;
    }

    final now = DateTime.now();
    final prevMonthStart = DateTime(now.year, now.month - 1, 1);
    final prevMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);

    double parseAndSum<T>(
      List<T> list,
      bool Function(DateTime) filterCondition,
    ) {
      return list.fold(0.0, (sum, item) {
        try {
          String dateString =
              (item is Income) ? item.date : (item as Expense).date;
          double price =
              (item is Income) ? item.price : (item as Expense).price;
          final date = apiDateFormat.parse(dateString);
          if (filterCondition(date)) {
            return sum + price;
          }
        } catch (e) {
          print("$e");
        }
        return sum;
      });
    }

    final prevMonthIncomes = parseAndSum(
      incomesController.incomes,
      (date) => !date.isBefore(prevMonthStart) && !date.isAfter(prevMonthEnd),
    );
    final prevMonthExpenses = parseAndSum(
      expensesController.listExpenses,
      (date) => !date.isBefore(prevMonthStart) && !date.isAfter(prevMonthEnd),
    );

    incomePercentageChange.value = (prevMonthIncomes > 0)
        ? ((totalIncome.value - prevMonthIncomes) / prevMonthIncomes) * 100
        : (totalIncome.value > 0 ? 100.0 : 0.0);

    expensePercentageChange.value = (prevMonthExpenses > 0)
        ? ((totalExpenses.value - prevMonthExpenses) / prevMonthExpenses) * 100
        : (totalExpenses.value > 0 ? 100.0 : 0.0);
  }

  void _processMonthlyTrends() {
    final periodMap = <String, Map<String, double>>{};

    final filteredIncomes = _filterByDateRange(incomesController.incomes);
    final filteredExpenses = _filterByDateRange(
      expensesController.listExpenses,
    );

    String groupByKey(DateTime date) {
      const locale = 'en_US';
      if (selectedPeriod.value == 'week') {
        final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
        return 'Week ${DateFormat('dd/MM', locale).format(startOfWeek)}';
      } else if (selectedPeriod.value == 'month') {
        return DateFormat('MMM yyyy', locale).format(date);
      } else {
        return DateFormat('yyyy', locale).format(date);
      }
    }

    final List<dynamic> combinedList = [
      ...filteredIncomes,
      ...filteredExpenses,
    ];

    for (final item in combinedList) {
      String dateString;
      double price;

      if (item is Income) {
        dateString = item.date;
        price = item.price;
      } else if (item is Expense) {
        dateString = item.date;
        price = item.price;
      } else {
        continue;
      }

      if (dateString.isEmpty) {
        print('Skipping entry with empty date string.');
        continue;
      }

      final DateTime? date = apiDateFormat.tryParse(dateString);

      if (date == null) {
        print('Skipping entry due to invalid date format: "$dateString"');
        continue;
      }

      final key = groupByKey(date);
      periodMap.putIfAbsent(key, () => {'income': 0.0, 'expense': 0.0});

      if (item is Income) {
        periodMap[key]!['income'] = (periodMap[key]!['income'] ?? 0.0) + price;
      } else if (item is Expense) {
        periodMap[key]!['expense'] =
            (periodMap[key]!['expense'] ?? 0.0) + price;
      }
    }

    List<Map<String, dynamic>> sortedEntries = periodMap.entries.map((entry) {
      DateTime sortDate;
      const locale = 'en_US';
      try {
        if (selectedPeriod.value == 'week') {
          final dateString = entry.key.split(' ').last;
          sortDate = DateFormat(
            'dd/MM/yyyy',
            locale,
          ).parse('$dateString/${DateTime.now().year}');
        } else if (selectedPeriod.value == 'month') {
          sortDate = DateFormat('MMM yyyy', locale).parse(entry.key);
        } else {
          // 'year'
          sortDate = DateFormat('yyyy', locale).parse(entry.key);
        }
      } catch (e) {
        print('Error parsing sort key "${entry.key}": $e');
        sortDate = DateTime(1970);
      }
      return {
        'month': entry.key,
        'income': entry.value['income']!,
        'expense': entry.value['expense']!,
        'sortDate': sortDate,
      };
    }).toList();

    sortedEntries.sort((a, b) => a['sortDate'].compareTo(b['sortDate']));

    monthlyTrends.assignAll(sortedEntries);
  }

  Map<String, dynamic> _incomeToTransaction(Income income) {
    final categoryInfo =
        incomesController.incomeCategoriesData[income.category] ??
            CategoryInfo(color: Colors.grey, icon: Icon(Icons.money));
    return {
      'type': 'income',
      'name': income.source,
      'category': income.category,
      'amount': income.price,
      'icon': categoryInfo.icon,
      'rawDate': income.date,
    };
  }

  Map<String, dynamic> _expenseToTransaction(Expense expense) {
    final categoryInfo =
        expensesController.expenseCategoriesData[expense.category] ??
            CategoryInfo(color: Colors.grey, icon: Icon(Icons.money_off));
    return {
      'type': 'expense',
      'name': expense.source,
      'category': expense.category,
      'amount': expense.price,
      'icon': categoryInfo.icon,
      'rawDate': expense.date,
    };
  }

  List<T> _filterByDateRange<T>(List<T> items) {
    if (startDate.value == null || endDate.value == null) return items;

    return items.where((item) {
      String dateString;
      if (item is Income)
        dateString = item.date;
      else if (item is Expense)
        dateString = item.date;
      else
        return false;
      try {
        final itemDate = apiDateFormat.parse(dateString);
        return !itemDate.isBefore(startDate.value!) &&
            !itemDate.isAfter(endDate.value!);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  void setPeriod(String period) {
    final now = DateTime.now();
    DateTime start;
    DateTime end;
    switch (period) {
      case 'week':
        start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        end = start.add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        break;
      case 'month':
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case 'year':
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
      default:
        return;
    }
    selectedPeriod.value = period;
    setDateRange(start, end);
  }

  void setDateRange(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value = end;
    loadData();
  }
}
