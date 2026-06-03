import '../models/task_model.dart';
import 'api_config.dart';
import 'api_service.dart';

class TaskApiService {
  TaskApiService({ApiService? apiService})
      : _apiService = apiService ?? ApiService(baseUrl: ApiConfig.baseUrl);

  final ApiService _apiService;

  Future<List<TaskModel>> fetchTasks() async {
    final data = await _apiService.getJson('/api/tasks') as List<dynamic>;
    return data
        .map((item) => TaskModel.fromApiJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<TaskModel>> fetchTasksByList(int listId) async {
    final data = await _apiService.getJson('/api/tasks/by-list/$listId') as List<dynamic>;
    return data
        .map((item) => TaskModel.fromApiJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final data = await _apiService.postJson('/api/tasks', task.toApiMap())
        as Map<String, dynamic>;
    return TaskModel.fromApiJson(data);
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    final data = await _apiService.putJson('/api/tasks/${task.id}', task.toApiMap())
        as Map<String, dynamic>;
    return TaskModel.fromApiJson(data);
  }

  Future<void> deleteTask(int id) async {
    await _apiService.deleteJson('/api/tasks/$id');
  }
}
