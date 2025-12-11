import 'package:pocketbase/pocketbase.dart';
import '../../core/constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/error_handler.dart';
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
}
