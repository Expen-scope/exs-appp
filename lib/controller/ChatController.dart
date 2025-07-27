import 'package:abo_najib_2/const/Constants.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import '../model/Chat.dart';

class ChatController extends GetxController {
  var messages = <ChatMessage>[].obs;
  var isLoading = false.obs;
  final textController = TextEditingController();
  var errorMessage = Rx<String?>(null);
  var isScreenLoading = true.obs;
  var inputText = ''.obs;
  final _storage = const FlutterSecureStorage();
  String? n8nToken;

  @override
  void onInit() {
    super.onInit();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    n8nToken = await _storage.read(key: 'n8n_session_token');

    if (n8nToken != null && n8nToken!.isNotEmpty) {
      await fetchChatHistory();
    } else {
      errorMessage.value = "Authentication error. Please login again.";
      isScreenLoading.value = false;
    }
  }

  final Dio.Dio dio = Dio.Dio(
    Dio.BaseOptions(
      baseUrl: baseUrl,
      contentType: Dio.Headers.jsonContentType,
      validateStatus: (status) => status! < 500,
    ),
  );

  final Dio.Dio _n8nDio = Dio.Dio(Dio.BaseOptions(
    baseUrl: "https://khaderhashh.app.n8n.cloud/",
    contentType: Dio.Headers.jsonContentType,
    validateStatus: (status) => status! < 500,
  ));

  Future<void> fetchChatHistory() async {
    if (n8nToken == null) return;
    isScreenLoading.value = true;
    errorMessage.value = null;
    try {
      final response = await dio.get(
        '/chat/context',
        options: Dio.Options(
          headers: {'Authorization': 'Bearer $n8nToken'},
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> history = response.data['chatHistory'];

        final chatMessages = history.map((msg) {
          return ChatMessage(
            text: msg['content'],
            isUser: msg['role'] == 'user',
          );
        }).toList();
        messages.assignAll(chatMessages);

        if (messages.isEmpty) {
          messages.add(ChatMessage(
              text: "Hello! How can I assist you today?", isUser: false));
        }
      } else {
        errorMessage.value =
            response.data['message'] ?? 'Failed to load history.';
      }
    } on Dio.DioException catch (e) {
      errorMessage.value = 'Network Error: Please check your connection.';
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred.';
    } finally {
      isScreenLoading.value = false;
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || isLoading.value) return;

    messages.add(ChatMessage(text: text, isUser: true));
    textController.clear();
    inputText.value = '';
    isLoading.value = true;
    errorMessage.value = null;

    try {
      if (n8nToken == null) {
        throw Exception("Auth token is missing.");
      }

      final response = await _n8nDio.post('/webhook/kh',
          data: {'question': text},
          options: Dio.Options(headers: {'Authorization': 'Bearer $n8nToken'}));

      if (response.statusCode == 200) {
        String aiResponseText = response.data.toString();

        if (aiResponseText.contains("srcdoc=\"{")) {
          aiResponseText =
              aiResponseText.split("srcdoc=\"{")[1].split("}\"")[0];
          aiResponseText = aiResponseText.replaceAll('*', '');
        }

        messages.add(ChatMessage(text: aiResponseText, isUser: false));
      } else {
        throw Exception("Error from AI service: ${response.statusMessage}");
      }
    } catch (e) {
      String errorMsg = "An unexpected error occurred.";
      if (e is Dio.DioException) {
        errorMsg = "Network error, please try again.";
      } else {
        errorMsg = e.toString();
      }

      messages.add(ChatMessage(
          text: "Sorry, I couldn't respond. $errorMsg", isUser: false));
    } finally {
      isLoading.value = false;
    }
  }
}
