import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../const/AppBarC.dart';
import '../const/Constants.dart';
import '../controller/ExpensesController.dart';
import '../model/Expenses.dart';

class AddExpences extends StatefulWidget {
  const AddExpences({super.key});

  @override
  State<AddExpences> createState() => _AddExpencesState();
}

class _AddExpencesState extends State<AddExpences> {
  final TextEditingController sourceController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController currencyController =
      TextEditingController(text: 'USD');
  final TextEditingController descriptionController = TextEditingController();

  final RxnString selectedCategory = RxnString(null);
  var  type_transaction;

  final ExpencesController controller = Get.find<ExpencesController>();

  @override
  void initState() {
    super.initState();
    if (controller.expenseCategories.isEmpty) {
      controller.fetchCategories().then((_) {
        if (mounted && controller.expenseCategories.isNotEmpty) {
          setState(() {
            selectedCategory.value = controller.expenseCategories.first;
          });
        }
      });
    } else {
      selectedCategory.value = controller.expenseCategories.first;
    }
  }

  @override
  void dispose() {
    sourceController.dispose();
    valueController.dispose();
    currencyController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog() {
    final TextEditingController newCategoryController = TextEditingController();
    Get.defaultDialog(
      title: "Add New Category",
      titleStyle:
          TextStyle(color: Color(0xFF006000), fontWeight: FontWeight.bold),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          controller: newCategoryController,
          decoration: InputDecoration(
            labelText: "Category Name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF006000)),
        onPressed: () {
          String newCategory = newCategoryController.text.trim();
          if (newCategory.isNotEmpty &&
              !controller.expenseCategories.contains(newCategory)) {
            controller.expenseCategories.add(newCategory);
            setState(() {
              selectedCategory.value = newCategory;
            });
            Get.back();
          } else if (newCategory.isEmpty) {
            Get.snackbar("Error", "Category name cannot be empty.");
          } else {
            Get.snackbar("Error", "Category already exists.");
          }
        },
        child: Text("Add", style: TextStyle(color: Colors.white)),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text("Cancel", style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: hight(context) * 0.01),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        cursorColor: const Color(0xFF006000),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF006000), width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Appbarofpage(TextPage: "Add Expense"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16),
            _buildTextField(
                controller: sourceController, label: "Expense Source"),
            _buildTextField(
                controller: valueController,
                label: "Amount",
                keyboardType: TextInputType.number),
            _buildTextField(controller: currencyController, label: "Currency "),
            _buildTextField(
                controller: descriptionController, label: "Description"),
            Padding(
              padding: EdgeInsets.symmetric(vertical: hight(context) * 0.01),
              child: Obx(() {
                if (controller.expenseCategories.isEmpty) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF006000)));
                } else {
                  final currentSelection = controller.expenseCategories
                          .contains(selectedCategory.value)
                      ? selectedCategory.value
                      : controller.expenseCategories.first;

                  return DropdownButtonFormField<String>(
                    value: currentSelection,
                    items: controller.expenseCategories
                        .map((category) => DropdownMenuItem(
                            value: category, child: Text(category)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory.value = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Select Category",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              }),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _showAddCategoryDialog,
                icon: const Icon(Icons.add, color: Color(0xFF006000)),
                label: const Text("Add New Category",
                    style: TextStyle(color: Color(0xFF006000))),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                print("Button Pressed!");
                print("Source: ${sourceController.text}");
                print("Value: ${valueController.text}");
                print("Currency: ${currencyController.text}");
                print("Category: ${selectedCategory.value}");
                if (sourceController.text.isNotEmpty &&
                    valueController.text.isNotEmpty &&
                    currencyController.text.isNotEmpty &&
                    selectedCategory.value != null) {
                  final String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

                  final newExpense = Expense(
                    source: sourceController.text,
                    price: double.tryParse(valueController.text) ?? 0.0,
                    category: selectedCategory.value!,
                    date: formattedDate,
                    currency: currencyController.text.toUpperCase(),
                    description: descriptionController.text.isEmpty
                        ? null
                        : descriptionController.text,
                  );

                  controller.addExpense(newExpense);
                } else {
                  Get.snackbar(
                    "Input Error",
                    "Please fill all required fields: Source, Amount, and Currency.",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFF006000),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Add Expense",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
