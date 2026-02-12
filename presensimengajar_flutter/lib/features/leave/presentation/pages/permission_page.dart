import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart'; // Add import at the top

import 'package:presensimengajar_flutter/features/leave/presentation/blocs/leave/leave_bloc.dart';
import 'package:presensimengajar_flutter/features/leave/presentation/blocs/leave/leave_event.dart';
import 'package:presensimengajar_flutter/features/leave/presentation/blocs/leave/leave_state.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/constants/app_constants.dart';

import '../../../profile/presentation/blocs/user/user_bloc.dart';
import '../../../profile/presentation/blocs/user/user_state.dart';
import '../../../../core/utils/file_utils.dart';

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
                context.pop();
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
                context.pop();
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
                context.pop();
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
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserLoaded) {
          _fetchHistory();
        }
      },
      child: Scaffold(
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
          initialValue: _selectedType,
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
    bool isImage = false;
    if (_selectedFile != null) {
      final ext = _selectedFile!.path.split('.').last.toLowerCase();
      isImage = ['jpg', 'jpeg', 'png'].contains(ext);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Lampiran', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickFile,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 100),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _selectedFile == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
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
                    ),
                  )
                : Column(
                    children: [
                      if (isImage)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.file(
                            _selectedFile!,
                            width: double.infinity,
                            fit: BoxFit.contain, // Show full image
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.picture_as_pdf,
                                size: 50,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedFile!.path.split('/').last,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                      // Footer actions
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(12),
                          ),
                          border: Border(
                            top: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!isImage) ...[
                              TextButton.icon(
                                onPressed: () {
                                  OpenFile.open(_selectedFile!.path);
                                },
                                icon: const Icon(Icons.visibility, size: 18),
                                label: const Text('Lihat PDF'),
                              ),
                              const SizedBox(width: 16),
                            ],
                            TextButton.icon(
                              onPressed: _pickFile,
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Ganti File'),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                Color statusColor;
                Color badgeBgColor;
                Color badgeTextColor;
                String statusLabel;

                switch (item.status.toLowerCase()) {
                  case 'approved':
                    statusColor = const Color(0xFF10B981); // Green
                    badgeBgColor = const Color(0xFFD1FAE5);
                    badgeTextColor = const Color(0xFF047857);
                    statusLabel = 'Disetujui';
                    break;
                  case 'rejected':
                    statusColor = const Color(0xFFEF4444); // Red
                    badgeBgColor = const Color(0xFFFEE2E2);
                    badgeTextColor = const Color(0xFFB91C1C);
                    statusLabel = 'Ditolak';
                    break;
                  default: // pending
                    statusColor = const Color(0xFFF59E0B); // Amber
                    badgeBgColor = const Color(0xFFFEF3C7);
                    badgeTextColor = const Color(0xFFB45309);
                    statusLabel = 'Menunggu';
                }

                // Date Formatting
                String dateDisplay = '';
                try {
                  // PocketBase datetime string format: YYYY-MM-DD HH:mm:ss.SSSZ
                  final start = DateTime.parse(item.startDate);
                  final end = DateTime.parse(item.endDate);
                  final formatter = DateFormat('d MMM yyyy', 'id_ID');

                  // Check if same day
                  if (start.year == end.year &&
                      start.month == end.month &&
                      start.day == end.day) {
                    dateDisplay = formatter.format(start);
                  } else {
                    dateDisplay =
                        '${formatter.format(start)} - ${formatter.format(end)}';
                  }
                } catch (e) {
                  dateDisplay = item.startDate; // Fallback
                }

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
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    // Left colored border
                    border: Border(
                      left: BorderSide(color: statusColor, width: 5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              typeDisplay,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: badgeTextColor,
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
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.reason,
                        style: TextStyle(color: Colors.grey[800], fontSize: 14),
                      ),

                      // Attachment Button
                      if (item.attachment != null &&
                          item.attachment!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () {
                            final url =
                                '${dotenv.env['POCKETBASE_URL']}/api/files/${AppCollections.leaveRequests}/${item.id}/${item.attachment}';
                            final isPdf = item.attachment!
                                .toLowerCase()
                                .endsWith('.pdf');

                            context.push(
                              '/attachment-viewer',
                              extra: {
                                'url': url,
                                'fileName': item.attachment!,
                                'isPdf': isPdf,
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item.attachment!.toLowerCase().endsWith(
                                        '.pdf',
                                      )
                                      ? Icons.picture_as_pdf
                                      : Icons.image,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Lihat Lampiran',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Rejection Reason
                      if (item.status.toLowerCase() == 'rejected')
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Alasan Ditolak',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.rejectionReason?.isNotEmpty == true
                                      ? item.rejectionReason!
                                      : '-',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
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
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Menyiapkan data...'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchHistory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Muat Ulang',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
