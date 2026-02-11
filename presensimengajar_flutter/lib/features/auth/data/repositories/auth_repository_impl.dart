import 'package:pocketbase/pocketbase.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/error_handler.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final PocketBase pb;

  AuthRepositoryImpl(this.pb);

  @override
  Future<AuthStore> login(String email, String password) async {
    try {
      await pb
          .collection(AppCollections.users)
          .authWithPassword(email, password);
      return pb.authStore;
    } catch (e) {
      throw AuthException(ErrorHandler.parseError(e));
    }
  }

  @override
  Future<void> logout() async {
    pb.authStore.clear();
  }

  @override
  bool get isAuthenticated => pb.authStore.isValid;

  @override
  String? get currentUserId => pb.authStore.record?.id;

  @override
  String? get currentUserRole => pb.authStore.record?.getStringValue('role');

  @override
  Future<UserModel?> getCurrentUser() async {
    if (!isAuthenticated || currentUserId == null) return null;
    try {
      final record = await pb
          .collection(AppCollections.users)
          .getOne(currentUserId!);
      return UserModel.fromRecord(record);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (!isAuthenticated || currentUserId == null) {
      throw AuthException('User not authenticated');
    }

    try {
      await pb
          .collection(AppCollections.users)
          .update(
            currentUserId!,
            body: {
              'password': newPassword,
              'passwordConfirm': newPassword,
              'oldPassword': oldPassword,
            },
          );
    } catch (e) {
      throw AuthException(ErrorHandler.parseError(e));
    }
  }
}
