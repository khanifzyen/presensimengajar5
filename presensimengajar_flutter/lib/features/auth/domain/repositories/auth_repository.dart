import 'package:pocketbase/pocketbase.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<AuthStore> login(String email, String password);
  Future<void> logout();
  bool get isAuthenticated;
  String? get currentUserId;
  String? get currentUserRole;
  Future<UserModel?> getCurrentUser();
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}
