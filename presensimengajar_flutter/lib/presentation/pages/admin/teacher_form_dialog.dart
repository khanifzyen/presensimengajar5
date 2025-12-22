import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/theme.dart';
import '../../../data/models/teacher_model.dart';

class TeacherFormDialog extends StatefulWidget {
  final TeacherModel? teacher;

  const TeacherFormDialog({super.key, this.teacher});

  @override
  State<TeacherFormDialog> createState() => _TeacherFormDialogState();
}

class _TeacherFormDialogState extends State<TeacherFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _nipController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController =
      TextEditingController(); // Not in lofi visually but needed in repo? Lofi form shows minimal fields? No, I see fields in lofi snippet.
  // Lofi snippet fields: Name, NIP, Subject, Email, Phone, Status, Category, JoinDate, Password.
  // Address is in Repository but maybe not in Lofi form? Or hidden?
  // I'll add Address as optional or bottom.
  final _passwordController = TextEditingController();
  final _joinDateController = TextEditingController();

  String? _selectedSubject;
  String _selectedStatus = 'active';
  String _selectedCategory = 'tetap';
  File? _selectedPhoto;

  // Dummy Subjects for now. In real app might fetch from MasterData.
  final List<String> _subjects = [
    'Matematika',
    'Bahasa Indonesia',
    'Bahasa Inggris',
    'Fisika',
    'Kimia',
    'Biologi',
    'Teknik Komputer',
    'Sejarah',
    'Geografi',
    'Ekonomi',
    'Seni Budaya',
    'Penjaskes',
    'PKN',
    'Bimbingan Konseling',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.teacher != null) {
      final t = widget.teacher!;
      _nameController.text = t.name;
      _nipController.text = t.nip;
      _phoneController.text = t.phone;
      _addressController.text = t.address;
      _selectedSubject =
          t.subjectId; // storing name in subjectId for now based on lofi?
      // Fix: If subjectId (likely an ID from DB) is not in our hardcoded list, add it to prevent crash.
      if (_selectedSubject != null && !_subjects.contains(_selectedSubject)) {
        _subjects.add(_selectedSubject!);
      }
      // Model has subjectId. Repo create uses subjectId.
      // If subjectId is name in my implementation (simple string), fine.
      _selectedStatus = t.status;
      _selectedCategory = t.attendanceCategory;
      _joinDateController.text = t.joinDate; // Format 'YYYY-MM-DD'

      // Email is not in TeacherModel. Can't prefill unless we fetch User.
      // Usually Edit Teacher doesn't allow changing email easily or we just leave empty to ignore.
    }
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
        // Format YYYY-MM-DD
        _joinDateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.teacher != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600, // Fixed width for dialog
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Data Guru' : 'Tambah Guru Baru',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo Picker (Center)
                      Center(
                        child: GestureDetector(
                          onTap: _pickPhoto,
                          child: CircleAvatar(
                            radius: 50,
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
                      const SizedBox(height: 24),

                      // Two columns
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Nama Lengkap',
                              _nameController,
                              required: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              'NIP',
                              _nipController,
                              required: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          Expanded(
                            child: _buildDropdown(
                              'Mata Pelajaran',
                              _subjects,
                              _selectedSubject,
                              (val) => setState(() => _selectedSubject = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Address (Full width)
                      _buildTextField(
                        'Alamat',
                        _addressController,
                        maxLines: 2,
                        required: true,
                      ),

                      const SizedBox(height: 16),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kategori Kehadiran',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedCategory,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'tetap',
                                      child: Text('Guru Tetap'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'jadwal',
                                      child: Text('Guru Jadwal'),
                                    ),
                                  ],
                                  onChanged: (val) =>
                                      setState(() => _selectedCategory = val!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Status',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedStatus,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'active',
                                      child: Text('Aktif'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'inactive',
                                      child: Text('Non-Aktif'),
                                    ),
                                  ],
                                  onChanged: (val) =>
                                      setState(() => _selectedStatus = val!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: InkWell(
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
                          ),
                          // Email & Password only relevant if creating new, or changing.
                          // Email is required for Create.
                          const SizedBox(width: 16),
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
                        'Password ${isEdit ? "(Kosongkan jika tidak ingin mengubah)" : ""}',
                        _passwordController,
                        required: !isEdit,
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(height: 1),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
              horizontal: 12,
              vertical: 12,
            ),
            suffixIcon: suffixIcon,
            hintText: 'Masukkan $label',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          validator: (val) => val == null ? 'Pilih salah satu' : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Create Map or Object to return
      // We can iterate map params
      final data = {
        'name': _nameController.text,
        'nip': _nipController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'password': _passwordController.text,
        'joinDate': _joinDateController.text,
        'status': _selectedStatus,
        'category': _selectedCategory,
        'subjectId': _selectedSubject,
        'photo': _selectedPhoto,
      };

      Navigator.pop(context, data);
    }
  }
}
