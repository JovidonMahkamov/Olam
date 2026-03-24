abstract class AuthLocalDataSource {
  // Remember me
  Future<void> saveRememberMe(String login, String password);
  String? getLogin();
  String? getPassword();

  // Tokens
  Future<void> saveAccessToken(String accessToken);
  Future<void> saveRefreshToken(String refreshToken);
  String? getAccessToken();
  String? getRefreshToken();

  // User
  Future<void> saveUserId(int id);
  int? getUserId();

  // Clear
  Future<void> clearAll();

}
