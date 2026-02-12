import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:presensimengajar_flutter/features/teachers/data/models/teacher_model.dart';
import 'package:presensimengajar_flutter/features/teachers/domain/repositories/teacher_repository.dart';
import 'admin_teacher_event.dart';
import 'admin_teacher_state.dart';

class AdminTeacherBloc extends Bloc<AdminTeacherEvent, AdminTeacherState> {
  final TeacherRepository teacherRepository;

  AdminTeacherBloc({required this.teacherRepository})
    : super(AdminTeacherInitial()) {
    on<AdminTeacherFetchList>(_onFetchList);
    on<AdminTeacherFilter>(_onFilter);
    on<AdminTeacherAdd>(_onAddTeacher);
    on<AdminTeacherUpdate>(_onUpdateTeacher);
    on<AdminTeacherDelete>(_onDeleteTeacher);
    on<AdminTeacherExport>(_onExportTeachers);
    on<AdminTeacherImport>(_onImportTeachers);
  }

  Future<void> _onFetchList(
    AdminTeacherFetchList event,
    Emitter<AdminTeacherState> emit,
  ) async {
    emit(AdminTeacherLoading());
    try {
      // Fetch ALL teachers
      final teachers = await teacherRepository.getTeachers(
        query: null,
        status: null,
      );

      // Fetch ALL subjects
      final subjects = await teacherRepository.getSubjects();

      emit(
        AdminTeacherLoaded(
          teachers: teachers,
          allTeachers: teachers, // Set source of truth
          subjects: subjects,
          filterStatus: 'all',
        ),
      );
    } catch (e) {
      emit(AdminTeacherError(e.toString()));
    }
  }

  void _onFilter(AdminTeacherFilter event, Emitter<AdminTeacherState> emit) {
    if (state is AdminTeacherLoaded) {
      final currentState = state as AdminTeacherLoaded;
      final allTeachers = currentState.allTeachers;

      List<TeacherModel> filtered = allTeachers.where((t) {
        bool matchQuery = true;
        if (event.query.isNotEmpty) {
          final q = event.query.toLowerCase();
          matchQuery = t.name.toLowerCase().contains(q) || t.nip.contains(q);
        }

        bool matchStatus = true;
        if (event.status != 'all') {
          matchStatus = t.status == event.status;
        }

        return matchQuery && matchStatus;
      }).toList();

      emit(
        AdminTeacherLoaded(
          teachers: filtered,
          allTeachers: allTeachers, // Keep source of truth
          subjects: currentState.subjects, // Preserve subjects
          filterStatus: event.status,
        ),
      );
    }
  }

  Future<void> _onAddTeacher(
    AdminTeacherAdd event,
    Emitter<AdminTeacherState> emit,
  ) async {
    emit(AdminTeacherLoading());
    try {
      await teacherRepository.createTeacher(
        email: event.email,
        password: event.password,
        nip: event.nip,
        name: event.name,
        position: event.position,
        phone: event.phone,
        address: event.address,
        attendanceCategory: event.attendanceCategory,
        status: event.status,
        joinDate: event.joinDate,
        subjectId: event.subjectId,
        photo: event.photo,
      );
      emit(const AdminTeacherOperationSuccess('Guru berhasil ditambahkan'));
      // Reload list
      add(const AdminTeacherFetchList());
    } catch (e) {
      emit(AdminTeacherError(e.toString()));
    }
  }

  Future<void> _onUpdateTeacher(
    AdminTeacherUpdate event,
    Emitter<AdminTeacherState> emit,
  ) async {
    emit(AdminTeacherLoading());
    try {
      await teacherRepository.updateTeacherAdmin(
        teacherId: event.teacherId,
        nip: event.nip,
        name: event.name,
        position: event.position,
        phone: event.phone,
        address: event.address,
        attendanceCategory: event.attendanceCategory,
        status: event.status,
        joinDate: event.joinDate,
        subjectId: event.subjectId,
        password: event.password,
        photo: event.photo,
      );
      emit(const AdminTeacherOperationSuccess('Data guru berhasil diperbarui'));
      add(const AdminTeacherFetchList());
    } catch (e) {
      emit(AdminTeacherError(e.toString()));
    }
  }

  Future<void> _onDeleteTeacher(
    AdminTeacherDelete event,
    Emitter<AdminTeacherState> emit,
  ) async {
    emit(AdminTeacherLoading());
    try {
      await teacherRepository.deleteTeacher(event.teacherId);
      emit(const AdminTeacherOperationSuccess('Guru berhasil dihapus'));
      add(const AdminTeacherFetchList());
    } catch (e) {
      emit(AdminTeacherError(e.toString()));
    }
  }

  Future<void> _onExportTeachers(
    AdminTeacherExport event,
    Emitter<AdminTeacherState> emit,
  ) async {
    emit(AdminTeacherLoading());
    try {
      // Platform specific path customization
      String? directoryPath;

      if (Platform.isAndroid) {
        // Request Storage Permission
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }

        // For Android 11+ (API 30+) usually need MANAGE_EXTERNAL_STORAGE for generic files
        // OR just save to standard public dir.
        // Let's try standard Download dir.
        if (status.isGranted ||
            await Permission.manageExternalStorage.isGranted ||
            status.isLimited) {
          directoryPath = '/storage/emulated/0/Download';
        } else {
          // Fallback path
          directoryPath = '/storage/emulated/0/Download';
        }

        // Verify existence
        final dir = Directory(directoryPath);
        if (!await dir.exists()) {
          // Fallback to app directory
          final appDir = await getApplicationDocumentsDirectory();
          directoryPath = appDir.path;
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        directoryPath = directory.path;
      }

      final teachers = await teacherRepository.getTeachers();
      List<List<dynamic>> rows = [];
      rows.add([
        'NIP',
        'Nama',
        'Email (User)',
        'Phone',
        'Address',
        'Status',
        'Category',
        'Join Date',
      ]);

      for (var t in teachers) {
        rows.add([
          t.nip,
          t.name,
          '',
          t.phone,
          t.address,
          t.status,
          t.attendanceCategory,
          t.joinDate,
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '$directoryPath/data_guru_$timestamp.csv';

      final file = File(path);
      await file.writeAsString(csv);

      emit(AdminTeacherExportSuccess(path, 'File tersimpan di: $path'));

      add(const AdminTeacherFetchList());
    } catch (e) {
      emit(AdminTeacherError('Gagal ekspor: $e'));
    }
  }

  Future<void> _onImportTeachers(
    AdminTeacherImport event,
    Emitter<AdminTeacherState> emit,
  ) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        emit(AdminTeacherLoading());
        File file = File(result.files.single.path!);
        final csvString = await file.readAsString();
        List<List<dynamic>> rows = const CsvToListConverter().convert(
          csvString,
          eol: '\n',
        );

        if (rows.isEmpty) throw Exception('File kosong');

        int success = 0;
        int failed = 0;

        for (int i = 1; i < rows.length; i++) {
          try {
            final row = rows[i];
            if (row.length < 8) continue;

            final nip = row[0].toString();
            final name = row[1].toString();
            final email = row[2].toString();
            final phone = row[3].toString();
            final address = row[4].toString();
            final status = row[5].toString();
            final category = row[6].toString();
            final joinDate = row[7].toString();
            String position = 'Guru Pengajar';
            if (row.length > 8) {
              position = row[8].toString();
            }

            final password = 'password123';

            if (email.isEmpty) {
              failed++;
              continue;
            }

            await teacherRepository.createTeacher(
              email: email,
              password: password,
              nip: nip,
              name: name,
              position: position,
              phone: phone,
              address: address,
              attendanceCategory: category,
              status: status,
              joinDate: joinDate,
            );
            success++;
          } catch (e) {
            debugPrint('Import Row $i failed: $e');
            failed++;
          }
        }

        emit(
          AdminTeacherOperationSuccess(
            'Impor selesai: $success berhasil, $failed gagal',
          ),
        );
        add(const AdminTeacherFetchList());
      }
    } catch (e) {
      emit(AdminTeacherError('Gagal impor: $e'));
    }
  }
}
