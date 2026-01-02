import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // For web attachments
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../core/theme.dart';
import '../../blocs/admin_leave/admin_leave_bloc.dart';
import '../../blocs/admin_leave/admin_leave_event.dart';
import '../../blocs/admin_leave/admin_leave_state.dart';
import '../../../data/models/leave_request_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

class AdminLeaveApprovalPage extends StatefulWidget {
  const AdminLeaveApprovalPage({super.key});

  @override
  State<AdminLeaveApprovalPage> createState() => _AdminLeaveApprovalPageState();
}

class _AdminLeaveApprovalPageState extends State<AdminLeaveApprovalPage> {
  String _activeTab = 'all'; // all, pending, approved, rejected
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AdminLeaveBloc>().add(const AdminLeaveFetchList());
  }

  void _onTabChanged(String tab) {
    setState(() {
      _activeTab = tab;
    });
    // We filter locally in UI or Bloc?
    // Bloc state has filterStatus.
    // Let's us Bloc Filtering for consistency if list is huge,
    // but for now local filter on 'allLeaves' from state is smoother UI.
    // Actually, let's just trigger Bloc filter event for proper state management.
    context.read<AdminLeaveBloc>().add(
      AdminLeaveFetchList(status: tab, query: _searchQuery),
    );
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    // Trigger search
    // We could debounce this
    context.read<AdminLeaveBloc>().add(
      AdminLeaveFetchList(status: _activeTab, query: query),
    );
  }

  Future<void> _approveRequest(String leaveId, String teacherName) async {
    // Show Confirmation Dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Persetujuan'),
        content: Text(
          'Apakah Anda yakin ingin menyetujui pengajuan izin dari $teacherName?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            onPressed: () => context.pop(true),
            icon: const Icon(Icons.check),
            label: const Text('Ya, Setujui'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authState = context.read<AuthBloc>().state;
      final adminId = authState is AuthAuthenticated ? authState.userId : '';

      if (adminId.isEmpty) {
        CustomSnackBar.showError(context, 'Sesi tidak valid');
        return;
      }

      // Dispatch Event
      context.read<AdminLeaveBloc>().add(
        AdminLeaveApprove(leaveId: leaveId, adminId: adminId),
      );
    }
  }

  Future<void> _rejectRequest(String leaveId, String teacherName) async {
    final reasonController = TextEditingController();

    // Show Rejection Dialog
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Penolakan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin menolak pengajuan izin dari $teacherName?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan Penolakan *',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Alasan wajib diisi')),
                );
                return;
              }
              context.pop(reasonController.text);
            },
            icon: const Icon(Icons.close),
            label: const Text('Ya, Tolak'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (reason != null && mounted) {
      final authState = context.read<AuthBloc>().state;
      final adminId = authState is AuthAuthenticated ? authState.userId : '';

      if (adminId.isEmpty) {
        CustomSnackBar.showError(context, 'Sesi tidak valid');
        return;
      }

      context.read<AdminLeaveBloc>().add(
        AdminLeaveReject(
          leaveId: leaveId,
          reason: reason,
          adminId: adminId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocConsumer<AdminLeaveBloc, AdminLeaveState>(
        listener: (context, state) {
          if (state is AdminLeaveOperationSuccess) {
            CustomSnackBar.showSuccess(context, state.message);
          } else if (state is AdminLeaveError) {
            CustomSnackBar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          int pendingCount = 0;
          int approvedCount = 0;
          int rejectedCount = 0;
          List<LeaveRequestModel> displayList = [];

          if (state is AdminLeaveLoaded) {
            displayList = state.leaves;
            pendingCount = state.totalPending;
            approvedCount = state.totalApproved;
            rejectedCount = state.totalRejected;
          }

          return Column(
            children: [
              // Header
              _buildHeader(),

              // Tabs
              _buildFilterTabs(pendingCount, approvedCount, rejectedCount),

              // Search
              _buildSearchBar(),

              // List
              Expanded(
                child: state is AdminLeaveLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildRequestsList(displayList),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Panel Admin',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                'Approval Izin',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            child: Text('AD', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(int pending, int approved, int rejected) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildTabButton('Semua', 'all', pending + approved + rejected),
          const SizedBox(width: 8),
          _buildTabButton(
            'Menunggu',
            'pending',
            pending,
            countColor: Colors.orange,
          ),
          const SizedBox(width: 8),
          _buildTabButton(
            'Disetujui',
            'approved',
            approved,
            countColor: Colors.green,
          ),
          const SizedBox(width: 8),
          _buildTabButton(
            'Ditolak',
            'rejected',
            rejected,
            countColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    String label,
    String value,
    int count, {
    Color? countColor,
  }) {
    final isActive = _activeTab == value;
    return GestureDetector(
      onTap: () => _onTabChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: isActive ? Border.all(color: AppTheme.primaryColor) : null,
        ),
        child: Row(
          children: [
            if (count > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (countColor ?? Colors.grey[600])!.withValues(
                    alpha: 0.2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: countColor ?? Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? AppTheme.primaryColor : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onSubmitted: _onSearch,
        decoration: InputDecoration(
          hintText: 'Cari nama guru atau jenis izin...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildRequestsList(List<LeaveRequestModel> leaves) {
    if (leaves.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada data pengajuan',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: leaves.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final leave = leaves[index];
        return _buildRequestCard(leave);
      },
    );
  }

  Widget _buildRequestCard(LeaveRequestModel leave) {
    Color statusColor;
    String statusLabel;

    switch (leave.status) {
      case 'approved':
        statusColor = Colors.green;
        statusLabel = 'Disetujui';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusLabel = 'Ditolak';
        break;
      default:
        statusColor = Colors.orange;
        statusLabel = 'Menunggu';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(left: BorderSide(color: statusColor, width: 4)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      leave.teacherPhoto != null &&
                          leave.teacherPhoto!.isNotEmpty
                      ? NetworkImage(
                          '${dotenv.env['POCKETBASE_URL']}/api/files/teachers/${leave.teacherId}/${leave.teacherPhoto}',
                        )
                      : null,
                  child:
                      leave.teacherPhoto == null || leave.teacherPhoto!.isEmpty
                      ? Text(
                          leave.teacherName?.substring(0, 1) ?? '?',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leave.teacherName ?? 'Unknown Teacher',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      // Optional: Subject/Position if we had it
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(Icons.label, leave.type.toUpperCase()),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.calendar_today,
                  '${_formatDate(leave.startDate)} - ${_formatDate(leave.endDate)}',
                ),
                // Duration logic could be added here
                const SizedBox(height: 16),
                const Text(
                  'Alasan:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(leave.reason, style: TextStyle(color: Colors.grey[700])),

                if (leave.attachment != null &&
                    leave.attachment!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      // Open attachment
                      final url =
                          '${dotenv.env['POCKETBASE_URL']}/api/files/leave_requests/${leave.id}/${leave.attachment}';
                      launchUrl(Uri.parse(url));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.attachment,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Lampiran',
                            style: TextStyle(color: Colors.blue[700]),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.open_in_new,
                            size: 12,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                if (leave.status == 'rejected' &&
                    leave.rejectionReason != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alasan Penolakan:',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          leave.rejectionReason!,
                          style: TextStyle(color: Colors.red[900]),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          if (leave.status == 'pending') ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _rejectRequest(leave.id, leave.teacherName ?? 'Guru'),
                      icon: const Icon(Icons.close),
                      label: const Text('Tolak'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveRequest(
                        leave.id,
                        leave.teacherName ?? 'Guru',
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text('Setujui'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMM y').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}
