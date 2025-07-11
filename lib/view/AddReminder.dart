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
  bool isLoading = false;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> saveReminder() async {
    setState(() => isLoading = true);
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        collectedController.text.isEmpty ||
        selectedDate == null ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields are required'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      double.parse(priceController.text);
      double.parse(collectedController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Price and collected amount must be valid numbers'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => isLoading = false);
      return;
    }

    DateTime finalDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    ReminderModel newReminder = ReminderModel(
      name: nameController.text,
      price: double.parse(priceController.text),
      collectedoprice: double.parse(collectedController.text),
      time: finalDateTime,
      id: null,
    );

    bool success = await reminderController.addReminder(newReminder);
    setState(() => isLoading = false);

    if (success) {
      DialogHelper.showSuccessDialog(
        title: 'Success',
        message: 'Reminder added successfully',
        onOkPressed: ()=>  Get.toNamed("/Reminder"),

      );
    }
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF507da0),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF507da0),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
    setState(() => isLoading = false);
  }

  Future<void> pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Color(0xFF507da0),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xFF507da0),
                ),
              )),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: hight(context) * 0.025),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hight(context) * .007),
              child: TextField(
                cursorColor: Color(0xFF264653),
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Reminder Name",
                  labelStyle: TextStyle(color: Color(0xFF264653), fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF264653), width: 2),
                  ),
                ),
              ),
            ),
            SizedBox(height: hight(context) * 0.024),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hight(context) * .007),
              child: TextField(
                cursorColor: Color(0xFF264653),
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount",
                  labelStyle: TextStyle(color: Color(0xFF264653), fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF264653), width: 2),
                  ),
                ),
              ),
            ),
            SizedBox(height: hight(context) * 0.024),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hight(context) * .007),
              child: TextField(
                cursorColor: Color(0xFF264653),
                controller: collectedController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount collected",
                  labelStyle: TextStyle(color: Color(0xFF264653), fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF264653), width: 2),
                  ),
                ),
              ),
            ),
            SizedBox(height: hight(context) * 0.024),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: pickTime,
                  child: Card(
                    elevation: 8,
                    color: Colors.grey[100],
                    margin: EdgeInsets.all(3.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.0, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Time: ${selectedTime != null ? selectedTime!.format(context) : ''}",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.calendar_today, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: pickDate,
                  child: Card(
                    elevation: 8,
                    color: Colors.grey[100],
                    margin: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.0, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            selectedDate == null
                                ? "Select Deadline"
                                : "Deadline: ${selectedDate!.toLocal().toString().split(' ')[0]}",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.access_time, color: Colors.green),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: hight(context) * 0.034),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hight(context) * .1),
                child: Container(
            color: Color(0xFF006000),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                      backgroundColor:Color(0xFF006000),
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: saveReminder,
                    child: Text(
                      "Add",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
