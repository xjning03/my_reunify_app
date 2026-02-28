import 'package:my_reunify_app/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> registerUser({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  });

  Future<User> loginUser({required String email, required String password});

  Future<void> logoutUser();

  Future<User?> getCurrentUser();

  Future<void> resetPassword(String email);

  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
  });

  Future<bool> isUserAuthenticated();
}
