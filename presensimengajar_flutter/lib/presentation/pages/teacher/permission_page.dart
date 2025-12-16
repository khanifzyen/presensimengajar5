import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../blocs/leave/leave_bloc.dart';
import '../../blocs/leave/leave_event.dart';
import '../../blocs/leave/leave_state.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_state.dart';
import '../../../core/utils/file_utils.dart'; // import PocketBase removed

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _dateStartController = TextEditingController();
  final _dateEndController = TextEditingController();
  final _reasonController = TextEditingController();
  String? _selectedType;
  File? _selectedFile; // For attachment

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchHistory();
  }

  void _fetchHistory() {
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      context.read<LeaveBloc>().add(LeaveFetchHistory(userState.teacher.id));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _dateStartController.dispose();
    _dateEndController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil Foto (Kamera)'),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final xFile = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (xFile != null) {
                  File file = File(xFile.path);
                  File compressed = await FileUtils.compressImage(file);
                  setState(() => _selectedFile = compressed);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Pilih Foto (Galeri)'),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final xFile = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (xFile != null) {
                  File file = File(xFile.path);
                  File compressed = await FileUtils.compressImage(file);
                  setState(() => _selectedFile = compressed);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Pilih Dokumen (PDF)'),
              onTap: () async {
                Navigator.pop(context);
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                );

                if (result != null && result.files.single.path != null) {
                  setState(() {
                    _selectedFile = File(result.files.single.path!);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final userState = context.read<UserBloc>().state;
      if (userState is UserLoaded) {
        context.read<LeaveBloc>().add(
          LeaveRequestSubmit(
            teacherId: userState.teacher.id,
            type: _selectedType!,
            startDate: _dateStartController.text,
            endDate: _dateEndController.text,
            reason: _reasonController.text,
            attachment: _selectedFile,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildFormTab(), _buildHistoryTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: const Row(
        children: [
          Text(
            'Izin & Cuti',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color(0xFF1E3A8A),
        ),
        indicatorSize: TabBarIndicatorSize.tab, // Makes indicator fill the tab
        dividerColor: Colors.transparent, // Remove default divider
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(
            child: SizedBox(
              width: double.infinity,
              child: Center(child: Text('Buat Pengajuan')),
            ),
          ),
          Tab(
            child: SizedBox(
              width: double.infinity,
              child: Center(child: Text('Riwayat')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormTab() {
    return BlocListener<LeaveBloc, LeaveState>(
      listener: (context, state) {
        if (state is LeaveSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengajuan berhasil dikirim!'),
              backgroundColor: Colors.green,
            ),
          );
          // Reset form
          _dateStartController.clear();
          _dateEndController.clear();
          _reasonController.clear();
          setState(() {
            _selectedType = null;
            _selectedFile = null;
          });
          // Switch to history tab and refresh
          _tabController.animateTo(1);
          _fetchHistory();
        } else if (state is LeaveError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengirim: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdownField(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      'Mulai Tanggal',
                      _dateStartController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePicker(
                      'Sampai Tanggal',
                      _dateEndController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Keterangan / Alasan',
                _reasonController,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              _buildUploadField(),
              const SizedBox(height: 32),
              BlocBuilder<LeaveBloc, LeaveState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state is LeaveLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state is LeaveLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'AJUKAN SEKARANG',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jenis Izin', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedType,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          items: const [
            DropdownMenuItem(value: 'sakit', child: Text('Sakit')),
            DropdownMenuItem(value: 'cuti', child: Text('Cuti Pribadi')),
            DropdownMenuItem(value: 'dinas', child: Text('Dinas Luar')),
          ],
          onChanged: (val) => setState(() => _selectedType = val),
          validator: (val) => val == null ? 'Wajib diisi' : null,
          hint: const Text('Pilih Kategori'),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: const Icon(Icons.calendar_today, size: 20),
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              controller.text = DateFormat('yyyy-MM-dd').format(date);
            }
          },
          validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
        ),
      ],
    );
  }

  Widget _buildUploadField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Lampiran', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: InkWell(
            onTap: _pickFile,
            child: _selectedFile == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ketuk untuk upload file (PDF/JPG)',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 40,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedFile!.path.split('/').last,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Ketuk untuk ganti',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return BlocBuilder<LeaveBloc, LeaveState>(
      builder: (context, state) {
        if (state is LeaveLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is LeaveHistoryLoaded) {
          if (state.history.isEmpty) {
            return const Center(child: Text('Belum ada riwayat pengajuan'));
          }
          return RefreshIndicator(
            onRefresh: () async => _fetchHistory(),
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: state.history.length,
              itemBuilder: (context, index) {
                final item = state.history[index];
                Color badgeColor;
                Color badgeText;
                String statusLabel = item.status;

                // Simple normalization
                if (item.status.toLowerCase() == 'pending') {
                  badgeColor = Colors.orange.withValues(alpha: 0.1);
                  badgeText = Colors.orange;
                  statusLabel = 'Menunggu';
                } else if (item.status.toLowerCase() == 'approved') {
                  badgeColor = Colors.green.withValues(alpha: 0.1);
                  badgeText = Colors.green;
                  statusLabel = 'Disetujui';
                } else {
                  badgeColor = Colors.red.withValues(alpha: 0.1);
                  badgeText = Colors.red;
                  statusLabel = 'Ditolak';
                }

                String dateDisplay = item.startDate == item.endDate
                    ? item.startDate
                    : '${item.startDate} - ${item.endDate}';

                // Capitalize first letter of type
                String typeDisplay = item.type;
                if (typeDisplay.isNotEmpty) {
                  typeDisplay =
                      typeDisplay[0].toUpperCase() + typeDisplay.substring(1);
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            typeDisplay,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: badgeText,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dateDisplay,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.reason,
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                      if (item.rejectionReason != null &&
                          item.rejectionReason!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Alasan Ditolak: ${item.rejectionReason}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        } else if (state is LeaveError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const Center(child: Text('Memuat...')); // Initial state
      },
    );
  }
}
