import 'dart:math';
import 'package:abo_najib_2/controller/OverViewHomepageController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../const/Drawer.dart';
import '../controller/FinancialController.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FinancialController controller = Get.find<FinancialController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: CustomDrawer(context),
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu, color: Color(0xFF006000)),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),
        body: Obx(
          () {
            return controller.isLoading.value
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView(
                    children: [
                      Card_Homepage(context),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.05,
                      ),
                      _buildTabs(context),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.05,
                      ),
                      _buildActiveTabContent(),
                    ],
                  );
          },
        ));
  }

  Widget _buildActiveTabContent() {
    return Obx(() {
      switch (controller.activeTab.value) {
        case ActiveTab.expenses:
          return _buildExpensesView();
        case ActiveTab.incomes:
          return _buildIncomesView();
        case ActiveTab.analysis:
          return _buildFinancialAnalysisView();
        default:
          return const SizedBox.shrink();
      }
    });
  }

  Widget _buildExpensesView() {
    final expenseTransactions =
        controller.transactions.where((t) => t['type'] == 'expense').toList();

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Spending",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
                NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                    .format(controller.totalExpenses.value),
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              )),
          const Text(
            "This Month -12%",
            style: TextStyle(fontSize: 14, color: Colors.red),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: _buildChart(isIncome: false),
          ),
          const SizedBox(height: 24),
          const Text(
            "Recent Transactions",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                expenseTransactions.length > 5 ? 5 : expenseTransactions.length,
            itemBuilder: (context, index) {
              final transaction = expenseTransactions[index];
              return _buildTransactionTile(
                icon: transaction['icon'],
                name: transaction['name'],
                category: transaction['category'],
                amount: -transaction['amount'],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIncomesView() {
    final incomeTransactions =
        controller.transactions.where((t) => t['type'] == 'income').toList();

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Income",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
                NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                    .format(controller.totalIncome.value),
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              )),
          const Text(
            "This Month +8%",
            style: TextStyle(fontSize: 14, color: Colors.green),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: _buildChart(isIncome: true),
          ),
          const SizedBox(height: 24),
          const Text(
            "Recent Transactions",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                incomeTransactions.length > 5 ? 5 : incomeTransactions.length,
            itemBuilder: (context, index) {
              final transaction = incomeTransactions[index];
              return _buildTransactionTile(
                icon: transaction['icon'],
                name: transaction['name'],
                category: transaction['category'],
                amount: transaction['amount'],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialAnalysisView() {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Category Breakdown",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Obx(() => PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: controller.categoryAnalysis.map((data) {
                      final isIncome = (data['color'] == Colors.green);
                      return PieChartSectionData(
                        color: data['color'],
                        value: data['amount'],
                        title: '${data['percentage']}%',
                        radius: isIncome ? 60 : 50, // تمييز الدخل بحجم أكبر
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                )),
          ),
          const SizedBox(height: 24),
          const Text(
            "Summary",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // عرض ملخص الفئات
          Obx(() => Column(
                children: controller.categoryAnalysis.map((data) {
                  return ListTile(
                    leading: Icon(Icons.circle, color: data['color'], size: 16),
                    title: Text(data['category']),
                    trailing: Text(
                      NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                          .format(data['amount']),
                      style: TextStyle(
                        color: data['color'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ))
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.05,
        ),
        _buildTabItem('Expenses', ActiveTab.expenses),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.05,
        ),
        _buildTabItem('Incomes', ActiveTab.incomes),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.05,
        ),
        _buildTabItem('Analysis', ActiveTab.analysis),
      ],
    );
  }

  Widget _buildTabItem(String title, ActiveTab tab) {
    return Obx(() {
      final bool isActive = controller.activeTab.value == tab;
      return GestureDetector(
        onTap: () => controller.changeTab(tab),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? const Color(0xFF006000) : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 3,
              width: 60,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF006000) : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget Card_Homepage(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.05,
          right: MediaQuery.of(context).size.width * 0.05,
          top: MediaQuery.of(context).size.width * 0.05),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          gradient: LinearGradient(
            colors: [Color(0xFF006000), Color(0xFF06402B)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        height: MediaQuery.of(context).size.height * 0.29,
        child: Padding(
          padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.05,
            bottom: MediaQuery.of(context).size.width * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "1033 USD",
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
              Text(
                "Totale Balance",
                style: TextStyle(fontSize: 22, color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart({required bool isIncome}) {
    final List<Map<String, dynamic>> data = controller.monthlyTrends;
    if (data.isEmpty) {
      return Center(child: Text("No data for chart."));
    }

    final spots = data.asMap().entries.map((entry) {
      int index = entry.key;
      double value = isIncome ? entry.value['income'] : entry.value['expense'];
      return FlSpot(index.toDouble(), value);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < data.length) {
                      String month =
                          data[index]['month'].toString().split(' ')[0];
                      return Text(month,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12));
                    }
                    return const Text('');
                  },
                  interval: 1)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: isIncome ? Colors.green : Colors.red,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: isIncome
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile({
    required Icon icon,
    required String name,
    required String category,
    required double amount,
  }) {
    final format = NumberFormat.currency(symbol: '', decimalDigits: 2);
    final String formattedAmount =
        (amount > 0 ? '+' : '-') + '\$${format.format(amount.abs())}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: icon,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            formattedAmount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: amount > 0 ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
