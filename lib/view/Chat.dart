import 'package:abo_najib_2/const/AppBarC.dart';
import 'package:abo_najib_2/controller/ChatController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../const/MessageBubble.dart';

class ChatPage extends StatelessWidget {
  ChatPage({super.key});
  final ChatController controller = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Appbarofpage(TextPage: "Support"),
      body: Obx(() {
        if (controller.isScreenLoading.value) {
          return const Center(
              child: CircularProgressIndicator(
            color: Color(0xFF006000),
          ));
        }
        if (controller.errorMessage.value != null) {
          return Center(child: Text('Error: ${controller.errorMessage.value}'));
        }
        return Column(
          children: [
            Expanded(
              child: Obx(
                () => ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width * 0.05,
                  ),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        controller.messages.reversed.toList()[index];
                    return MessageBubble(message: message);
                  },
                ),
              ),
            ),
            Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF006000),
                      ),
                      SizedBox(width: 8),
                      Text("AI is thinking..."),
                    ],
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
            _buildTextInputBar(context),
            SizedBox(
              width: MediaQuery.of(context).size.height * 0.1,
            )
          ],
        );
      }),
    );
  }

  Widget _buildTextInputBar(BuildContext context) {
    return Obx(() => Container(
          color: Color(0xFFf5f5f5),
          padding: EdgeInsets.fromLTRB(
            MediaQuery.of(context).size.height * 0.01,
            MediaQuery.of(context).size.height * 0.02,
            MediaQuery.of(context).size.height * 0.01,
            MediaQuery.of(context).size.height * 0.03,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FAF0),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: TextField(
                    controller: controller.textController,
                    onChanged: (text) => controller.inputText.value = text,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                icon: Icon(
                  Icons.send,
                  color: controller.inputText.isNotEmpty
                      ? const Color(0xFF006000)
                      : Colors.grey,
                ),
                onPressed: controller.inputText.isNotEmpty
                    ? () {
                        final text = controller.textController.text.trim();
                        controller.sendMessage(text);
                      }
                    : null,
              ),
            ],
          ),
        ));
  }
}
