import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../../domain/repositories/teacher_repository.dart';
import 'admin_teacher_event.dart';
import 'admin_teacher_state.dart';

class AdminTeacherBloc extends Bloc<AdminTeacherEvent, AdminTeacherState> {
  final TeacherRepository teacherRepository;

  AdminTeacherBloc({required this.teacherRepository})
    : super(AdminTeacherInitial()) {
    on<AdminTeacherFetchList>(_onFetchList);
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
      final teachers = await teacherRepository.getTeachers(
        query: event.query,
        status: event.status,
      );
      emit(
        AdminTeacherLoaded(
          teachers: teachers,
          filterStatus: event.status ?? 'all',
        ),
      );
    } catch (e) {
      emit(AdminTeacherError(e.toString()));
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
      // Re-fetch to show list even after error? Or just stay in Error state?
      // Better to stay in Error state or go back to Loaded?
      // UI usually handles error state by showing snackbar.
      // But if we stay in Error state, the list disappears.
      // So maybe we should just emit Error and then reload?
      // For now, simple error state.
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
    // Keep current loaded state if possible, but for now Loading
    emit(AdminTeacherLoading());
    try {
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
        // Note: Email is in User record, not directly in TeacherModel usually unless joined.
        // TeacherModel currently doesn't have email.
        // We'll skip email for now or leave empty.
        rows.add([
          t.nip,
          t.name,
          '', // Email not available in TeacherModel
          t.phone,
          t.address,
          t.status,
          t.attendanceCategory,
          t.joinDate,
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);

      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/data_guru.csv';
      final file = File(path);
      await file.writeAsString(csv);

      await Share.shareXFiles([XFile(path)], text: 'Data Guru');

      // Reload list to restore UI
      add(const AdminTeacherFetchList());
    } catch (e) {
      emit(AdminTeacherError('Gagal ekspor: $e'));
    }
  }

  Future<void> _onImportTeachers(
    AdminTeacherImport event,
    Emitter<AdminTeacherState> emit,
  ) async {
    // No Loading state initially to avoid UI flicker if cancel?
    // Usually BLoC sits behind UI. UI calls Pick File using FilePicker?
    // If we do FilePicker here, it blocks ISolate? No, it's async.

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

        // Assume Header Row 0
        int success = 0;
        int failed = 0;

        // Start from 1
        for (int i = 1; i < rows.length; i++) {
          try {
            final row = rows[i];
            // Setup expected columns: NIP, Name, Email, Phone, Address, Status, Category, JoinDate, Password
            // If User provides exact format from Export, Index 2 is Email (which was empty in export).
            // We need a template.

            // Simple robust check
            if (row.length < 8) continue; // Skip incomplete

            final nip = row[0].toString();
            final name = row[1].toString();
            final email = row[2].toString(); // Needs email for create
            final phone = row[3].toString();
            final address = row[4].toString();
            final status = row[5].toString();
            final category = row[6].toString();
            final joinDate = row[7].toString();
            // Password default or generic?
            // Let's assume generic '12345678' if not provided or generate.
            final password = 'password123';

            if (email.isEmpty) {
              // Generate fake email if missing? No, createTeacher needs email.
              // We'll skip if no email.
              failed++;
              continue;
            }

            await teacherRepository.createTeacher(
              email: email,
              password: password,
              nip: nip,
              name: name,
              phone: phone,
              address: address,
              attendanceCategory: category,
              status: status,
              joinDate: joinDate,
            );
            success++;
          } catch (e) {
            print('Import Row $i failed: $e');
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
