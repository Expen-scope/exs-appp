import 'package:flutter/material.dart';

class Appbarofpage extends StatelessWidget implements PreferredSizeWidget {
  final String TextPage;

  const Appbarofpage({super.key, required this.TextPage});
  //#006000
  //#F8FCF8
  //#DBF0DB
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF006000)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                TextPage,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006000),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}
