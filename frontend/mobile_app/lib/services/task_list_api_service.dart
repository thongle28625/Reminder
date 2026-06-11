import '../models/task_list_model.dart';
import 'api_config.dart';
import 'api_service.dart';
import '../core/session.dart';

class TaskListApiService {
  TaskListApiService({ApiService? apiService})
    : _apiService = apiService ?? ApiService(baseUrl: ApiConfig.baseUrl);

  final ApiService _apiService;

  Future<List<TaskListModel>> fetchLists() async {
    final userId = Session.currentUserId;

    print('FETCH LIST USER = $userId');

    final data =
        await _apiService.getJson('/api/tasklists/user/$userId')
            as List<dynamic>;

    return data
        .map((item) => TaskListModel.fromApiJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<TaskListModel> createList(TaskListModel list) async {
    final data =
        await _apiService.postJson('/api/tasklists', list.toApiMap())
            as Map<String, dynamic>;
    return TaskListModel.fromApiJson(data);
  }

  Future<TaskListModel> updateList(TaskListModel list) async {
    print('UPDATE LIST');
    print(list.toApiMap());

    final data =
        await _apiService.putJson('/api/tasklists/${list.id}', list.toApiMap())
            as Map<String, dynamic>;
    return TaskListModel.fromApiJson(data);
  }

  Future<void> deleteList(int id) async {
    await _apiService.deleteJson('/api/tasklists/$id');
  }
}
