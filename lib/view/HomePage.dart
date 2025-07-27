import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import '../const/Drawer.dart';
import '../controller/FinancialController.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FinancialController controller = Get.find<FinancialController>();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(context),
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF006000)),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Obx(
              () => DropdownButton<String>(
                value: controller.selectedPeriod.value,
                underline: const SizedBox.shrink(),
                icon: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF006000),
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) controller.setPeriod(newValue);
                },
                items: <String>['week', 'month', 'year']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value.capitalizeFirst!,
                      style: const TextStyle(
                        color: Color(0xFF006000),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        return controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF006000)),
              )
            : RefreshIndicator(
                onRefresh: controller.fetchAllData,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Card_Homepage(context),
                    const SizedBox(height: 24),
                    _buildTabs(context),
                    const SizedBox(height: 24),
                    _buildActiveTabContent(context),
                  ],
                ),
              );
      }),
    );
  }

  Widget _buildActiveTabContent(BuildContext context) {
    return Obx(() {
      switch (controller.activeTab.value) {
        case ActiveTab.expenses:
          return _buildExpensesView();
        case ActiveTab.incomes:
          return _buildIncomesView();
        case ActiveTab.analysis:
          return _buildFinancialAnalysisView(context);
        default:
          return const SizedBox.shrink();
      }
    });
  }

  Widget _buildExpensesView() {
    final expenseTransactions =
        controller.transactions.where((t) => t['type'] == 'expense').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Spending",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Text(
            NumberFormat.currency(
              symbol: '\$',
              decimalDigits: 2,
            ).format(controller.totalExpenses.value),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Obx(() {
          final change = controller.expensePercentageChange.value;
          final color = change >= 0 ? Colors.red : Colors.green;
          final sign = change >= 0 ? '+' : '';
          if (change == 0.0) return const SizedBox.shrink();
          return Text(
            "vs Last Month ${sign}${change.toStringAsFixed(1)}%",
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          );
        }),
        const SizedBox(height: 20),
        SizedBox(height: 150, child: _buildChart(isIncome: false)),
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
              date: transaction['rawDate'],
            );
          },
        ),
      ],
    );
  }

  Widget _buildIncomesView() {
    final incomeTransactions =
        controller.transactions.where((t) => t['type'] == 'income').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Income",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Text(
            NumberFormat.currency(
              symbol: '\$',
              decimalDigits: 2,
            ).format(controller.totalIncome.value),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Obx(() {
          final change = controller.incomePercentageChange.value;
          final color = change >= 0 ? Colors.green : Colors.red;
          final sign = change >= 0 ? '+' : '';
          if (change == 0.0) return const SizedBox.shrink();
          return Text(
            "vs Last Month ${sign}${change.toStringAsFixed(1)}%",
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          );
        }),
        const SizedBox(height: 20),
        SizedBox(height: 150, child: _buildChart(isIncome: true)),
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
              date: transaction['rawDate'],
            );
          },
        ),
      ],
    );
  }

  Widget _buildChart({required bool isIncome}) {
    final List<Map<String, dynamic>> data = controller.monthlyTrends;

    final List<Map<String, dynamic>> validData = data.where((d) {
      final value = d[isIncome ? 'income' : 'expense'];
      return value is num && value >= 0 && !value.isNaN && !value.isInfinite;
    }).toList();

    if (validData.isEmpty) {
      return const Center(
        child:
            Text("No data to display.", style: TextStyle(color: Colors.grey)),
      );
    }

    double maxY = 0;
    for (var d in validData) {
      double value = d[isIncome ? 'income' : 'expense'];
      if (value > maxY) maxY = value;
    }
    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100;

    return BarChart(
      BarChartData(
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final itemData = validData[group.x.toInt()];
              final period = itemData['month'];
              final amount = rod.toY;
              return BarTooltipItem(
                '$period\n',
                const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  TextSpan(
                    text: NumberFormat.currency(symbol: '\$').format(amount),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
          touchCallback: (FlTouchEvent event, barTouchResponse) {},
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index >= 0 && index < validData.length) {
                  final period = validData[index]['month'].toString();
                  String title = period.split(' ').first;
                  return SideTitleWidget(
                    space: 8.0,
                    meta: meta,
                    child: Text(
                      title.length > 4 ? title.substring(0, 3) : title,
                      style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 38,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text('');
                return Text(NumberFormat.compact().format(value),
                    style: const TextStyle(color: Colors.grey, fontSize: 10));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        barGroups: validData.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final double value = item[isIncome ? 'income' : 'expense'];

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                color: isIncome ? Colors.green : Colors.red,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFinancialAnalysisView(BuildContext context) {
    final Map<String, Widget> analysisWidgets = {
      'income_vs_expense': _buildAnalysisCard(
        key: const ValueKey('income_vs_expense'),
        title: "Income vs. Expense",
        height: 320,
        child: _buildBarChart(),
      ),
      'PFC': _buildAnalysisCard(
        key: const ValueKey('PFC'),
        title: "PFC",
        height: 320,
        child: _buildProjectionCard(),
      ),
      'category_breakdown': _buildAnalysisCard(
        key: const ValueKey('category_breakdown'),
        title: "Category Breakdown",
        height: 320,
        child: Obx(
          () => PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: controller.categoryAnalysis.map((data) {
                final isIncome = data['type'] == 'income';
                return PieChartSectionData(
                  color: data['color'],
                  value: data['amount'],
                  title: '${data['percentage']}%',
                  radius: isIncome ? 60 : 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      'summary_table': _buildAnalysisCard(
        key: const ValueKey('summary_table'),
        title: "Summary Table",
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Obx(
            () => DataTable(
              columnSpacing: 20,
              horizontalMargin: 10,
              headingRowHeight: 40,
              columns: const [
                DataColumn(
                  label: Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Amount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  numeric: true,
                ),
              ],
              rows: controller.categoryAnalysis.map((data) {
                final isIncome = data['type'] == 'income';
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          Icon(Icons.circle, color: data['color'], size: 12),
                          const SizedBox(width: 8),
                          Text(data['category']),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(
                        isIncome ? 'Income' : 'Expense',
                        style: TextStyle(
                          color: isIncome ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        NumberFormat.currency(
                          symbol: '\$',
                          decimalDigits: 2,
                        ).format(data['amount']),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    };

    return Obx(
      () => ReorderableListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: controller.analysisWidgetOrder
            .map((widgetKey) => analysisWidgets[widgetKey]!)
            .toList(),
        onReorder: (oldIndex, newIndex) {
          if (newIndex > oldIndex) newIndex -= 1;
          final item = controller.analysisWidgetOrder.removeAt(oldIndex);
          controller.analysisWidgetOrder.insert(newIndex, item);
        },
      ),
    );
  }

  Widget _buildAnalysisCard({
    required Key key,
    required String title,
    required Widget child,
    double? height,
  }) {
    return Card(
      color: Colors.white,
      key: key,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.drag_handle, color: Colors.grey.shade400),
                ],
              ),
              const SizedBox(height: 16),
              height != null ? Expanded(child: child) : child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildTabItem('Expenses', ActiveTab.expenses),
        SizedBox(width: MediaQuery.of(context).size.height * .02),
        _buildTabItem('Incomes', ActiveTab.incomes),
        SizedBox(width: MediaQuery.of(context).size.height * .02),
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
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.22,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        gradient: LinearGradient(
          colors: [Color(0xFF006000), Color(0xFF06402B)],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Balance",
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              NumberFormat.currency(
                symbol: '\$',
                decimalDigits: 2,
              ).format(controller.balance.value),
              style: const TextStyle(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
    required String date,
  }) {
    final format = NumberFormat.currency(symbol: '', decimalDigits: 2);
    final String formattedAmount =
        (amount > 0 ? '+' : '-') + '\$${format.format(amount.abs())}';
    String formattedDate = '';
    try {
      final parsedDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(date);
      formattedDate = DateFormat('MMM dd, yyyy').format(parsedDate);
    } catch (e) {
      formattedDate = date.split(' ').first;
    }
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
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formattedAmount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: amount > 0 ? Colors.green : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final data = controller.incomeExpenseComparisonData;
    if (data.isEmpty) return const Center(child: Text("No data to compare."));
    final double maxYValue = data
        .map(
          (d) => (d['income'] as double) > (d['expense'] as double)
              ? (d['income'] as double)
              : (d['expense'] as double),
        )
        .reduce((a, b) => a > b ? a : b);
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxYValue * 1.2,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < data.length) {
                  return SideTitleWidget(
                    space: 4,
                    meta: meta,
                    child: Text(
                      data[index]['month'].toString().split(' ').first,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item['income'],
                color: Colors.green,
                width: 12,
                borderRadius: BorderRadius.circular(4),
              ),
              BarChartRodData(
                toY: item['expense'],
                color: Colors.red,
                width: 12,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String label = rodIndex == 0 ? 'Income' : 'Expense';
              return BarTooltipItem(
                '$label\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: NumberFormat.currency(symbol: '\$').format(rod.toY),
                    style: TextStyle(
                      color: rod.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProjectionCard() {
    final format = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Obx(() {
      final pIncome = controller.projectedIncome.value;
      final pExpense = controller.projectedExpense.value;
      final pBalance = controller.projectedBalance.value;

      final totalProjection = pIncome + pExpense;
      final double incomeRatio =
          (totalProjection > 0) ? pIncome / totalProjection : 0.0;
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Projected Income",
                      style: TextStyle(fontSize: 14)),
                  Text(format.format(pIncome),
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: incomeRatio,
                minHeight: 12,
                borderRadius: BorderRadius.circular(6),
                backgroundColor: Colors.red.shade100,
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.green.shade400),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Projected Expense",
                      style: TextStyle(fontSize: 14)),
                  Text(format.format(pExpense),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red)),
                ],
              ),
            ],
          ),
          const Divider(height: 40, thickness: 1),
          Column(
            children: [
              const Text(
                "Projected End-of-Month Balance",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                format.format(pBalance),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: pBalance >= 0 ? const Color(0xFF006000) : Colors.red,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
