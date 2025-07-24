import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../const/AppBarC.dart';
import '../controller/ReminderController.dart';
import '../model/Reminder.dart';
import 'AddReminder.dart';
import 'EditReminderScreen.dart';

class Reminders extends StatelessWidget {
  static String id = "Reminders";
  final ReminderController reminderController = Get.find<ReminderController>();

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      appBar: Appbarofpage(TextPage: "Reminders"),
      body: RefreshIndicator(
        onRefresh: () => reminderController.fetchReminders(),
        child: Obx(() {
          if (reminderController.isLoading.value &&
              reminderController.reminders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (reminderController.errorMessage.value.isNotEmpty) {
            return Center(
              child: Text('Error: ${reminderController.errorMessage.value}'),
            );
          }

          if (reminderController.reminders.isEmpty) {
            return const Center(
              child: Text(
                'No reminders added yet!',
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * .0,
              horizontal: MediaQuery.of(context).size.height * .002,
            ),
            child: ReorderableListView.builder(
              itemCount: reminderController.reminders.length,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex--;
                final item = reminderController.reminders[oldIndex];
                reminderController.reminders.removeAt(oldIndex);
                reminderController.reminders.insert(newIndex, item);
              },
              itemBuilder: (context, index) {
                final reminder = reminderController.reminders[index];
                print(" Reminder displayed time: ${reminder.time}");
                final remainingDuration = reminder.time.difference(
                  DateTime.now(),
                );
                final remainingMinutes = remainingDuration.inMinutes % 60;
                final remainingSeconds = remainingDuration.inSeconds % 60;

                return ListTile(
                  key: ValueKey('reminder_${reminder.id ?? 'null'}_$index'),
                  onTap: () async {
                    await Get.to(
                      () => EditReminderScreen(reminder: reminder),
                      fullscreenDialog: true,
                    );
                  },
                  contentPadding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * .01,
                    horizontal: MediaQuery.of(context).size.height * .01,
                  ),
                  leading: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * .01,
                      horizontal: MediaQuery.of(context).size.height * .02,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F5F1),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Icon(
                      _getIconForReminder(reminder.name ?? ''),
                      color: Colors.black87,
                      size: 28,
                    ),
                  ),
                  title: Text(
                    reminder.name ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    _getDueDateString(remainingDuration),
                    style: TextStyle(fontSize: 14, color: Colors.green[800]),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () async {
                      bool success = await reminderController.deleteReminder(
                        reminder.id!,
                      );
                      if (success) {
                        Get.snackbar(
                          "Success",
                          "Reminder deleted successfully",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      } else {
                        Get.snackbar(
                          "Error",
                          "Failed to delete reminder",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                  ),
                );
              },
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.to(() => AddReminderScreen());
        },
        tooltip: 'Add Reminder',
        backgroundColor: const Color(0xFF006000),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  IconData _getIconForReminder(String reminderName) {
    final name = reminderName.toLowerCase();
    if (name.contains('rent')) {
      return Icons.home_outlined;
    } else if (name.contains('card')) {
      return Icons.credit_card_outlined;
    } else if (name.contains('utilities')) {
      return Icons.chat_bubble_outline;
    } else {
      return Icons.list_alt_outlined;
    }
  }

  String _getDueDateString(Duration remainingDuration) {
    if (remainingDuration.isNegative) return 'Overdue';

    final days = remainingDuration.inDays;
    if (days >= 7) {
      final weeks = (days / 7).floor();
      return 'Due in ${weeks} week${weeks > 1 ? 's' : ''}';
    }
    if (days > 0) {
      return 'Due in ${days} day${days > 1 ? 's' : ''}';
    }
    final hours = remainingDuration.inHours;
    if (hours > 0) {
      return 'Due in ${hours} hour${hours > 1 ? 's' : ''}';
    }
    return 'Due soon';
  }
}
