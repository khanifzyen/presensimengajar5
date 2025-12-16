import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class UserGetProfile extends UserEvent {
  final String userId;

  const UserGetProfile(this.userId);

  @override
  List<Object> get props => [userId];
}

class UserUpdateProfile extends UserEvent {
  final String teacherId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final File? photo;

  const UserUpdateProfile({
    required this.teacherId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.photo,
  });

  @override
  List<Object?> get props => [teacherId, name, email, phone, address, photo];
}
