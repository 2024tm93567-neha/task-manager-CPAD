import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AuthService {
  /// Register a new user with email and password
  Future<ParseResponse> register({
    required String email,
    required String password,
  }) async {
    final user = ParseUser(email, password, email);
    return await user.signUp();
  }

  /// Login with email and password
  Future<ParseResponse> login({
    required String email,
    required String password,
  }) async {
    final user = ParseUser(email, password, null);
    return await user.login();
  }

  /// Logout current session
  Future<void> logout() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    await user?.logout();
  }

  /// Get the currently logged-in user
  Future<ParseUser?> getCurrentUser() async {
    return await ParseUser.currentUser() as ParseUser?;
  }

  /// Check if a user session is currently active
  Future<bool> isLoggedIn() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user == null) return false;
    final response = await ParseUser.getCurrentUserFromServer(user.sessionToken!);
    return response?.success ?? false;
  }
}
