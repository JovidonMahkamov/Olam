import 'package:hive/hive.dart';
import 'auth_local_data_source.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box box;
  AuthLocalDataSourceImpl(this.box);

  // ================= REMEMBER ME =================
  @override
  Future<void> saveRememberMe(String login, String password) async {
    await box.put('login', login);
    await box.put('password', password);
  }

  @override
  String? getLogin() => box.get('login');

  @override
  String? getPassword() => box.get('password');

  // ================= TOKENS =================

  @override
  Future<void> saveAccessToken(String accessToken) async {
    await box.put('accessToken', accessToken);
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) async {
    await box.put('refreshToken', refreshToken);
  }

  @override
  String? getAccessToken() => box.get('accessToken');

  @override
  String? getRefreshToken() => box.get('refreshToken');

  // ================= USER =================

  @override
  Future<void> saveUserId(int id) async {
    await box.put('id', id);
  }

  @override
  int? getUserId() => box.get('id');

  // ================= CLEAR =================

  @override
  Future<void> clearAll() async {
    await box.clear();
  }

}
