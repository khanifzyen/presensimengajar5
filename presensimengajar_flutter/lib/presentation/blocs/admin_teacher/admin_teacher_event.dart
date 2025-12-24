import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class AdminTeacherEvent extends Equatable {
  const AdminTeacherEvent();

  @override
  List<Object?> get props => [];
}

class AdminTeacherFetchList extends AdminTeacherEvent {
  // Now purely for fetching/refetching from DB. No params.
  const AdminTeacherFetchList();

  @override
  List<Object?> get props => [];
}

class AdminTeacherFilter extends AdminTeacherEvent {
  final String query;
  final String status;

  const AdminTeacherFilter({this.query = '', this.status = 'all'});

  @override
  List<Object?> get props => [query, status];
}

class AdminTeacherAdd extends AdminTeacherEvent {
  final String email;
  final String password;
  final String nip;
  final String name;
  final String position;
  final String phone;
  final String address;
  final String attendanceCategory;
  final String status;
  final String joinDate;
  final String? subjectId;
  final File? photo;

  const AdminTeacherAdd({
    required this.email,
    required this.password,
    required this.nip,
    required this.name,
    required this.position,
    required this.phone,
    required this.address,
    required this.attendanceCategory,
    required this.status,
    required this.joinDate,
    this.subjectId,
    this.photo,
  });

  @override
  List<Object?> get props => [
    email,
    password,
    nip,
    name,
    phone,
    address,
    attendanceCategory,
    status,
    joinDate,
    subjectId,
    photo,
  ];
}

class AdminTeacherUpdate extends AdminTeacherEvent {
  final String teacherId;
  final String nip;
  final String name;
  final String position;
  final String phone;
  final String address;
  final String attendanceCategory;
  final String status;
  final String joinDate;
  final String? subjectId;
  final String? password;
  final File? photo;

  const AdminTeacherUpdate({
    required this.teacherId,
    required this.nip,
    required this.name,
    required this.position,
    required this.phone,
    required this.address,
    required this.attendanceCategory,
    required this.status,
    required this.joinDate,
    this.subjectId,
    this.password,
    this.photo,
  });

  @override
  List<Object?> get props => [
    teacherId,
    nip,
    name,
    position,
    phone,
    address,
    attendanceCategory,
    status,
    joinDate,
    subjectId,
    password,
    photo,
  ];
}

class AdminTeacherExport extends AdminTeacherEvent {}

class AdminTeacherImport extends AdminTeacherEvent {}

class AdminTeacherDelete extends AdminTeacherEvent {
  final String teacherId;

  const AdminTeacherDelete(this.teacherId);

  @override
  List<Object?> get props => [teacherId];
}
