import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/FinancialController.dart';
import '../controller/user_controller.dart';
import '../view/ReminderPage.dart';
import 'Constants.dart';

final UserController controller = Get.find<UserController>();

Widget CustomDrawer(BuildContext context) {
  return Drawer(
    child: Column(
      children: [
        Obx(() => UserAccountsDrawerHeader(
              accountName: Text(
                controller.user.value?.name ?? 'Guest',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                controller.user.value?.email ?? 'No email',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                radius: width(context) * 0.16,
                backgroundImage: controller.selectedImage.value != null
                    ? FileImage(controller.selectedImage.value!)
                        as ImageProvider
                    : const AssetImage('assets/Photo/me.jpg'),
              ),
              decoration: BoxDecoration(
                color: Color(0xFF06402B),
              ),
            )),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildDrawerItem(
                icon: Icons.access_alarm,
                title: 'Reminders',
                route: () => Get.to(() => Reminders()),
              ),
              _buildDrawerItem(
                icon: Icons.flag,
                title: 'Goals',
                route: () => Get.toNamed("/Goals"),
              ),
              _buildDrawerItem(
                icon: Icons.attach_money,
                title: 'Incomes',
                route: () => Get.toNamed("/IncomesScreens"),
              ),
              _buildDrawerItem(
                icon: Icons.money_off,
                title: 'Expenses',
                route: () => Get.toNamed("/ExpencesScreens"),
              ),
              _buildDrawerItem(
                icon: Icons.settings,
                title: 'Settings',
                route: () => Get.toNamed("/Setting"),
              ),
              const Divider(height: 20),
              _buildDrawerItem(
                icon: Icons.logout,
                title: 'Log Out',
                color: Colors.red,
                route: () => _showLogoutDialog(context),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildDrawerItem({
  required IconData icon,
  required String title,
  required Function() route,
  Color? color,
}) {
  return ListTile(
    leading: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Color(0xFFF8FCF8),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color ?? Color(0xFF06402B)),
    ),
    title: Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color ?? Colors.grey[800],
      ),
    ),
    onTap: route,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    visualDensity: const VisualDensity(vertical: 0),
  );
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Log Out'),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Get.toNamed("/Login");
          },
          child: const Text(
            'Log Out',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}
