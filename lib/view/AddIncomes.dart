import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../const/AppBarC.dart';
import '../const/Constants.dart'; // افترض وجود هذا الملف
import '../controller/IncomesController.dart';
import '../model/Incomes.dart';

class AddIncomes extends StatefulWidget {
  const AddIncomes({super.key});

  @override
  State<AddIncomes> createState() => _AddIncomesState();
}

class _AddIncomesState extends State<AddIncomes> {
  final TextEditingController sourceController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController currencyController =
      TextEditingController(text: 'USD');
  final TextEditingController descriptionController = TextEditingController();
  final RxnString selectedCategory = RxnString(null);
  final IncomesController controller = Get.find<IncomesController>();

  @override
  void initState() {
    super.initState();
    if (controller.incomeCategories.isEmpty) {
      controller.fetchCategories().then((_) {
        if (mounted && controller.incomeCategories.isNotEmpty) {
          setState(() {
            selectedCategory.value = controller.incomeCategories.first;
          });
        }
      });
    } else {
      selectedCategory.value = controller.incomeCategories.first;
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
    final newCategoryController = TextEditingController();
    Get.defaultDialog(
      title: "Add New Category",
      titleStyle: const TextStyle(
          color: Color(0xFF006000), fontWeight: FontWeight.bold),
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
        style:
            ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006000)),
        onPressed: () {
          String newCategory = newCategoryController.text.trim();
          if (newCategory.isNotEmpty &&
              !controller.incomeCategories.contains(newCategory)) {
            controller.incomeCategories.add(newCategory);
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
        child: const Text("Add", style: TextStyle(color: Colors.white)),
      ),
      cancel: TextButton(
          onPressed: () => Get.back(),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
      appBar: Appbarofpage(TextPage: "Add Income"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            _buildTextField(
                controller: sourceController, label: "Income Source"),
            _buildTextField(
                controller: valueController,
                label: "Amount",
                keyboardType: TextInputType.number),
            _buildTextField(controller: currencyController, label: "Currency"),
            _buildTextField(
                controller: descriptionController,
                label: "Description (Optional)"),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Obx(() {
                if (controller.incomeCategories.isEmpty) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF006000)));
                }
                final currentSelection =
                    controller.incomeCategories.contains(selectedCategory.value)
                        ? selectedCategory.value
                        : controller.incomeCategories.first;
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: hight(Get.context!) * .007),
                  child: DropdownButtonFormField<String>(
                    value: currentSelection,
                    items: controller.incomeCategories.map((category) {
                      final categoryInfo =
                          controller.incomeCategoriesData[category] ??
                              CategoryInfo(
                                  color: Colors.grey,
                                  icon: Icon(Icons.category));

                      return DropdownMenuItem<String>(
                        value: category,
                        child: Row(
                          children: [
                            Icon(categoryInfo.icon.icon,
                                color: categoryInfo.color),
                            const SizedBox(width: 8),
                            Text(category),
                          ],
                        ),
                      );
                    }).toList(),
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
                  ),
                );
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                print("Button Pressed!");
                print("Source: ${sourceController.text}");
                print("Value: ${valueController.text}");
                print("Currency: ${currencyController.text}");
                print("Category: ${selectedCategory.value}");
                if (sourceController.text.isNotEmpty &&
                    valueController.text.isNotEmpty &&
                    selectedCategory.value != null) {
                  final newIncome = Income(
                    source: sourceController.text,
                    price: double.tryParse(valueController.text) ?? 0.0,
                    category: selectedCategory.value!,
                    date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    currency: currencyController.text.toUpperCase(),
                    description: descriptionController.text.isEmpty
                        ? null
                        : descriptionController.text,
                  );
                  controller.addIncome(newIncome);
                } else {
                  Get.snackbar(
                      "Input Error", "Please fill all required fields.",
                      snackPosition: SnackPosition.BOTTOM);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFF006000),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Add Income",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
