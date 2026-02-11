import 'package:pocketbase/pocketbase.dart';

class UserModel {
  final String id;
  final String created;
  final String updated;
  final String email;
  final String username;
  final bool verified;
  final String role; // 'admin' | 'teacher'

  UserModel({
    required this.id,
    required this.created,
    required this.updated,
    required this.email,
    required this.username,
    required this.verified,
    required this.role,
  });

  factory UserModel.fromRecord(RecordModel record) {
    return UserModel(
      id: record.id,
      created: record.getStringValue('created'),
      updated: record.getStringValue('updated'),
      email: record.getStringValue('email'),
      username: record.getStringValue('username'),
      verified: record.getBoolValue('verified'),
      role: record.getStringValue('role'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created': created,
      'updated': updated,
      'email': email,
      'username': username,
      'verified': verified,
      'role': role,
    };
  }
}
