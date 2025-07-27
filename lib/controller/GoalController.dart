import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../const/Constants.dart';
import '../model/Goal.dart';

class GoalController extends GetxController {
  final RxList<GoalModel> goals = <GoalModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // final String _baseUrl = "http://10.0.2.2:8000/api/user";

  @override
  void onInit() {
    super.onInit();
    fetchGoals();
  }

  Future<String?> _getAuthToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> fetchGoals() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final token = await _getAuthToken();
      if (token == null) throw Exception('Authentication token not found.');

      final response = await _dio.get(
        '$baseUrl/user/goals',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        goals.value = data.map((json) => GoalModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load goals: ${response.statusMessage}');
      }
    } catch (e) {
      errorMessage.value = 'Error fetching goals: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<GoalModel?> addGoal(GoalModel goal) async {
    isLoading.value = true;
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Authentication token not found.');

      final response = await _dio.post(
        '$baseUrl/user/goals',
        data: goal.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final newGoal = GoalModel.fromJson(response.data);
        goals.insert(0, newGoal);
        Get.offNamed('/Goals');
        return newGoal;
      } else {
        throw Exception('Failed to add goal: ${response.statusMessage}');
      }
    } catch (e) {
      errorMessage.value = 'Error adding goal: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateGoal(GoalModel goal) async {
    isLoading.value = true;
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Authentication token not found.');
      if (goal.id == null) throw Exception('Goal ID is missing');

      final response = await _dio.put(
        '$baseUrl/user/goals/${goal.id}',
        data: goal.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final index = goals.indexWhere((g) => g.id == goal.id);
        if (index != -1) goals[index] = goal;

        Get.snackbar('Success', 'Goal updated successfully!',
            snackPosition: SnackPosition.BOTTOM);
        return true;
      } else {
        throw Exception('Failed to update goal: ${response.statusMessage}');
      }
    } catch (e) {
      errorMessage.value = 'Error updating goal: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteGoal(int goalId) async {
    isLoading.value = true;
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Authentication token not found.');

      final response = await _dio.delete(
        '$baseUrl/user/goals/$goalId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        goals.removeWhere((g) => g.id == goalId);
        Get.snackbar('Success', 'Goal deleted successfully',
            snackPosition: SnackPosition.BOTTOM);
        return true;
      } else {
        throw Exception('Failed to delete goal: ${response.statusMessage}');
      }
    } catch (e) {
      errorMessage.value = 'Error deleting goal: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
