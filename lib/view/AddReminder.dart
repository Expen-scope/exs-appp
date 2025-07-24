import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../const/AppBarC.dart';
import '../const/Constants.dart';
import '../controller/ReminderController.dart';
import '../model/Reminder.dart';
import '../utils/dialog_helper.dart';
import 'ReminderPage.dart';

class AddReminderScreen extends StatefulWidget {
  @override
  _AddReminderScreenState createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final ReminderController reminderController = Get.find();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController collectedController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> saveReminder() async {
    print(" saveReminder called");
    print("selectedDate: $selectedDate");
    print("selectedTime: $selectedTime");

    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        collectedController.text.isEmpty ||
        selectedDate == null ||
        selectedTime == null) {
      Get.snackbar(
        "Missing Information",
        "Please fill all fields, including date and time.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // ✅ ضع تعريف finalDateTime هنا بعد التحقق من null
    DateTime finalDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    print("⏰ Local time before sending: $finalDateTime");
    print("⏰ UTC time before sending: ${finalDateTime.toUtc()}");

    ReminderModel newReminder = ReminderModel(
      name: nameController.text,
      price: double.parse(priceController.text),
      collectedoprice: double.parse(collectedController.text),
      time: finalDateTime,
      id: null,
    );

    final ReminderModel? result = await reminderController.addReminder(
      newReminder,
    );

    if (result != null) {
      Get.snackbar(
        "Success",
        "Reminder added successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        "Error",
        reminderController.errorMessage.value.isNotEmpty
            ? reminderController.errorMessage.value
            : "An unknown error occurred.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      print("Date picked: $picked");
      setState(() {
        selectedDate = picked;
      });
    } else {
      print(" Date not picked");
    }
  }

  Future<void> pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(//#006000
//#F8FCF8
//#DBF0DB

        data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF149714),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor:  Color(0xFF149714)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Appbarofpage(TextPage: "Add Reminder"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: hight(context) * 0.025),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: hight(context) * .007),
                  child: TextField(
                    cursorColor:  Color(0xFF006000),
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Reminder Name",
                      labelStyle:
                          TextStyle(color:  Color(0xFF006000), fontSize: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color:  Color(0xFF006000), width: 2),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: hight(context) * 0.024),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: hight(context) * .007),
                  child: TextField(
                    cursorColor:  Color(0xFF006000),
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Amount",
                      labelStyle:
                          TextStyle(color:  Color(0xFF006000), fontSize: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color:  Color(0xFF006000), width: 2),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: hight(context) * 0.024),
                Padding(
                  padding://#006000
//#F8FCF8
//#DBF0DB

                  EdgeInsets.symmetric(horizontal: hight(context) * .007),
                  child: TextField(
                    cursorColor: Color(0xFF006000),
                    controller: collectedController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Amount collected",
                      labelStyle:
                          TextStyle(color:  Color(0xFF006000), fontSize: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Color(0xFF006000), width: 2),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: hight(context) * 0.024),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        right: MediaQuery.of(context).size.height * .23,
                      ),
                      child: GestureDetector(
                        onTap: pickTime,
                        child: Card(
                          elevation: 8,
                          color: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.height * .01,
                              vertical:
                                  MediaQuery.of(context).size.height * .01,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Time: ${selectedTime != null ? selectedTime!.format(context) : ''}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(Icons.calendar_today, color: Colors.blue),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        right: MediaQuery.of(context).size.height * .15,
                      ),
                      child: GestureDetector(
                        onTap: pickDate,
                        child: Card(
                          elevation: 8,
                          color: Colors.grey[100],
                          margin: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.height * .01,
                              vertical:
                                  MediaQuery.of(context).size.height * .01,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  selectedDate == null
                                      ? "Select Deadline"
                                      : "Deadline: ${selectedDate!.toLocal().toString().split(' ')[0]}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.access_time, color: Colors.green),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: hight(context) * 0.034),
                Center(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: hight(context) * .1),
                    child: Obx(
                      () => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(50),
                          backgroundColor: Color(0xFF006000),
                          disabledBackgroundColor: Color(
                            0xFF006000,
                          ).withOpacity(0.5),
                        ),
                        onPressed: reminderController.isLoading.value
                            ? null
                            : saveReminder,
                        child: reminderController.isLoading.value
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                            : const Text(
                                "Add",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
