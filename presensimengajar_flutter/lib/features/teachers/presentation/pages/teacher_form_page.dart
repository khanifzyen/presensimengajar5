import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/teacher_model.dart';
import '../../../admin/data/models/master_models.dart';
import '../blocs/admin_teacher/admin_teacher_bloc.dart';
import '../blocs/admin_teacher/admin_teacher_event.dart';
import '../blocs/admin_teacher/admin_teacher_state.dart';

class TeacherFormPage extends StatefulWidget {
  final TeacherModel? teacher;

  const TeacherFormPage({super.key, this.teacher});

  @override
  State<TeacherFormPage> createState() => _TeacherFormPageState();
}

class _TeacherFormPageState extends State<TeacherFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _nipController = TextEditingController();
  // Position is now a dropdown
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _joinDateController = TextEditingController();

  String _selectedPosition = 'guru'; // Default
  String? _selectedSubject;
  String _selectedStatus = 'active';
  String _selectedCategory = 'tetap';
  File? _selectedPhoto;

  @override
  void initState() {
    super.initState();
    if (widget.teacher != null) {
      final t = widget.teacher!;
      _nameController.text = t.name;
      _nipController.text = t.nip;

      // Handle position
      const validPositions = [
        'guru',
        'kepala_sekolah',
        'wakil_kepala',
        'staff_tu',
      ];
      if (validPositions.contains(t.position)) {
        _selectedPosition = t.position;
      } else {
        _selectedPosition = 'guru'; // Fallback
      }

      _phoneController.text = t.phone;
      _addressController.text = t.address;

      // Subject Selection
      _selectedSubject = t.subjectId;
      // We will validate subject existence in build or assume it's valid for now.
      // Accessing bloc in initState to check subjects might be racy or unclean.
      // Better to rely on the dropdown list in build.

      _selectedStatus = t.status;
      _selectedCategory = t.attendanceCategory;
      _joinDateController.text = t.joinDate;
    }
    // Defaults already set
  }

  Future<void> _pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _selectedPhoto = File(result.files.single.path!);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _joinDateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.teacher != null;

    return BlocListener<AdminTeacherBloc, AdminTeacherState>(
      listener: (context, state) {
        if (state is AdminTeacherOperationSuccess) {
          context.pop(); // Go back on success
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEdit ? 'Edit Data Guru' : 'Tambah Guru Baru',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo Picker
                Center(
                  child: GestureDetector(
                    onTap: _pickPhoto,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _selectedPhoto != null
                          ? FileImage(_selectedPhoto!) as ImageProvider
                          : (isEdit && widget.teacher!.photo.isNotEmpty)
                          ? NetworkImage(
                              widget.teacher!.getPhotoUrl(
                                dotenv.env['POCKETBASE_URL'] ??
                                    'http://127.0.0.1:8090',
                              ),
                            )
                          : null,
                      child:
                          (_selectedPhoto == null &&
                              (!isEdit || widget.teacher!.photo.isEmpty))
                          ? const Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Ketuk untuk ubah foto',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 32),

                // Section 1: Data Identitas
                _buildSectionTitle('Identitas Guru'),
                const SizedBox(height: 16),

                _buildTextField(
                  'Nama Lengkap',
                  _nameController,
                  required: true,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'NIP',
                        _nipController,
                        required: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                        'Jabatan',
                        const [
                          DropdownMenuItem(value: 'guru', child: Text('Guru')),
                          DropdownMenuItem(
                            value: 'kepala_sekolah',
                            child: Text('Kepala Sekolah'),
                          ),
                          DropdownMenuItem(
                            value: 'wakil_kepala',
                            child: Text('Wakil Kepala'),
                          ),
                          DropdownMenuItem(
                            value: 'staff_tu',
                            child: Text('Staff TU'),
                          ),
                        ],
                        _selectedPosition,
                        (val) => setState(() => _selectedPosition = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Section 2: Kontak & Alamat
                _buildSectionTitle('Kontak & Alamat'),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'No. Telepon',
                        _phoneController,
                        required: true,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Email only if new (or handle properly)
                    if (!isEdit)
                      Expanded(
                        child: _buildTextField(
                          'Email',
                          _emailController,
                          required: true,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      )
                    else
                      const Spacer(),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  'Alamat Lengkap',
                  _addressController,
                  maxLines: 3,
                  required: true,
                ),
                const SizedBox(height: 16),

                // Section 3: Data Kepegawaian
                _buildSectionTitle('Data Kepegawaian'),
                const SizedBox(height: 16),

                _buildSubjectDropdown(),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        'Kategori Kehadiran',
                        const [
                          DropdownMenuItem(
                            value: 'tetap',
                            child: Text('Guru Tetap'),
                          ),
                          DropdownMenuItem(
                            value: 'jadwal',
                            child: Text('Guru Jadwal'),
                          ),
                        ],
                        _selectedCategory,
                        (val) => setState(() => _selectedCategory = val!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                        'Status Guru',
                        const [
                          DropdownMenuItem(
                            value: 'active',
                            child: Text('Aktif'),
                          ),
                          DropdownMenuItem(
                            value: 'inactive',
                            child: Text('Non-Aktif'),
                          ),
                        ],
                        _selectedStatus,
                        (val) => setState(() => _selectedStatus = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                InkWell(
                  onTap: () => _selectDate(context),
                  child: IgnorePointer(
                    child: _buildTextField(
                      'Tanggal Bergabung',
                      _joinDateController,
                      required: true,
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Section 4: Akun
                _buildSectionTitle('Pengaturan Akun'),
                const SizedBox(height: 16),
                _buildTextField(
                  'Password ${isEdit ? "(Kosongkan jika tidak ingin mengubah)" : ""}',
                  _passwordController,
                  required: !isEdit,
                  obscureText: true,
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Simpan Data Guru',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const Divider(thickness: 1),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool required = false,
    bool obscureText = false,
    int maxLines = 1,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: required
              ? (val) => val == null || val.isEmpty ? 'Wajib diisi' : null
              : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: suffixIcon,
            hintText: 'Masukkan $label',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectDropdown() {
    // Get subjects from Bloc
    final state = context.read<AdminTeacherBloc>().state;
    List<SubjectModel> subjects = [];
    if (state is AdminTeacherLoaded) {
      subjects = state.subjects;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mata Pelajaran',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedSubject,
          isExpanded: true,
          items: subjects.map((s) {
            return DropdownMenuItem(
              value: s.id,
              child: Text(s.name, overflow: TextOverflow.ellipsis, maxLines: 1),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedSubject = val),
          validator: (val) => val == null ? 'Pilih salah satu' : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    List<DropdownMenuItem<String>> items,
    String? value,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          validator: (val) => val == null ? 'Pilih salah satu' : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (widget.teacher == null) {
        // Add
        context.read<AdminTeacherBloc>().add(
          AdminTeacherAdd(
            name: _nameController.text,
            nip: _nipController.text,
            position: _selectedPosition,
            email: _emailController.text,
            password: _passwordController.text,
            phone: _phoneController.text,
            address: _addressController.text,
            status: _selectedStatus,
            attendanceCategory: _selectedCategory,
            joinDate: _joinDateController.text,
            subjectId: _selectedSubject,
            photo: _selectedPhoto,
          ),
        );
      } else {
        // Update
        context.read<AdminTeacherBloc>().add(
          AdminTeacherUpdate(
            teacherId: widget.teacher!.id,
            name: _nameController.text,
            nip: _nipController.text,
            position: _selectedPosition,
            phone: _phoneController.text,
            address: _addressController.text,
            status: _selectedStatus,
            attendanceCategory: _selectedCategory,
            joinDate: _joinDateController.text,
            subjectId: _selectedSubject,
            password: _passwordController.text.isNotEmpty
                ? _passwordController.text
                : null,
            photo: _selectedPhoto,
          ),
        );
      }
    }
  }
}
