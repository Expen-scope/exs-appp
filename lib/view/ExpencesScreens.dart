import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../const/AppBarC.dart';
import '../const/ContentLE.dart';
import '../controller/ExpensesController.dart';
import '../controller/IncomesController.dart';
import 'AddExpense.dart';

class ExpencesScreens extends StatelessWidget {
  const ExpencesScreens({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpencesController>();

    return Scaffold(
      appBar: Appbarofpage(TextPage: "Expences"),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchExpenses(),
        child: Obx(
          () => Column(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PieChart(
                    PieChartData(
                      sections: controller.listExpenses.isEmpty
                          ? [
                              PieChartSectionData(
                                value: 100,
                                color: Colors.grey,
                                title: "No Data",
                                radius: 50,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ]
                          : controller.listExpenses.map((expense) {
                              final type = expense.category;
                              final categoryInfo =
                                  controller.expenseCategoriesData[
                                          expense.category] ??
                                      CategoryInfo(
                                          color: Colors.grey,
                                          icon: Icon(Icons.category));

                              return PieChartSectionData(
                                value: expense.price,
                                color: categoryInfo.color,
                                title: "\$${expense.price.toStringAsFixed(0)}",
                                radius: 50,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            }).toList(),
                      centerSpaceRadius: 40,
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 4,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: ListView.builder(
                  itemCount: controller.listExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = controller.listExpenses[index];
                    final categoryInfo =
                        controller.expenseCategoriesData[expense.category] ??
                            CategoryInfo(
                                color: Colors.grey, icon: Icon(Icons.category));

                    return Card(
                      elevation: 5,
                      color: Colors.grey[200],
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: CircleAvatar(
                          backgroundColor: categoryInfo.color.withOpacity(0.2),
                          child: Icon(
                            categoryInfo.icon.icon,
                            color: const Color(0xFF264653),
                          ),
                        ),
                        title: Text(expense.source),
                        subtitle: Text("\$${expense.price.toStringAsFixed(2)}"),
                        trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Color(0xFF264653)),
                            onPressed: () async {
                              final expenseId =
                                  controller.listExpenses[index].id;
                              await controller.removeExpense(expenseId!);
                            }),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF006000),
        onPressed: () async {
          Get.toNamed("/AddExpences");
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
