import '../models/user_model.dart';
import 'api_config.dart';
import 'api_service.dart';

class AuthApiService {
  final ApiService _apiService = ApiService(baseUrl: ApiConfig.baseUrl);

  Future<UserModel?> login(String username, String password) async {
    try {
      final data = await _apiService.postJson('/api/auth/login', {
        'username': username,
        'password': password,
      });

      return UserModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<bool> register(
    String fullName,
    String username,
    String password,
  ) async {
    try {
      await _apiService.postJson('/api/auth/register', {
        'fullName': fullName,
        'username': username,
        'password': password,
      });

      return true;
    } catch (_) {
      return false;
    }
  }
  
}
