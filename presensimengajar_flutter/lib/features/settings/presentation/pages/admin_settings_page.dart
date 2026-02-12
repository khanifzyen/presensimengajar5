import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:presensimengajar_flutter/core/theme/app_theme.dart';
import 'package:presensimengajar_flutter/features/settings/presentation/blocs/admin_settings/admin_settings_bloc.dart';
import 'package:presensimengajar_flutter/features/settings/presentation/blocs/admin_settings/admin_settings_event.dart';
import 'package:presensimengajar_flutter/features/settings/presentation/blocs/admin_settings/admin_settings_state.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _radiusController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _toleranceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<AdminSettingsBloc>().add(AdminSettingsFetch());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _radiusController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _toleranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminSettingsBloc, AdminSettingsState>(
      listener: (context, state) {
        if (state is AdminSettingsSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is AdminSettingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is AdminSettingsLoaded) {
          _radiusController.text = state.radius.toString();
          _latController.text = state.latitude.toString();
          _lngController.text = state.longitude.toString();
          _toleranceController.text = state.tolerance.toString();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildRadiusTab(), _buildToleranceTab()],
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
      padding: const EdgeInsets.all(20),
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
                'Pengaturan Sistem',
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

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppTheme.primaryColor,
        tabs: const [
          Tab(
            icon: Icon(FontAwesomeIcons.mapLocationDot),
            text: 'Radius & Lokasi',
          ),
          Tab(icon: Icon(FontAwesomeIcons.clock), text: 'Toleransi Waktu'),
        ],
      ),
    );
  }

  Widget _buildRadiusTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Pengaturan Radius Lokasi',
            'Atur jarak maksimum untuk presensi',
          ),
          const SizedBox(height: 20),
          _buildCard(
            children: [
              _buildInputGroup(
                label: 'Radius Sekolah (meter)',
                controller: _radiusController,
                keyboardType: TextInputType.number,
                icon: FontAwesomeIcons.rulerHorizontal,
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              _buildInputGroup(
                label: 'Latitude',
                controller: _latController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                icon: FontAwesomeIcons.locationDot,
              ),
              const SizedBox(height: 20),
              _buildInputGroup(
                label: 'Longitude',
                controller: _lngController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                icon: FontAwesomeIcons.locationDot,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<AdminSettingsBloc>().add(
                  AdminSettingsUpdate(
                    radius: double.tryParse(_radiusController.text),
                    latitude: double.tryParse(_latController.text),
                    longitude: double.tryParse(_lngController.text),
                  ),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('Simpan Pengaturan Lokasi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToleranceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Pengaturan Toleransi Waktu',
            'Atur batas waktu keterlambatan check-in',
          ),
          const SizedBox(height: 20),
          _buildCard(
            children: [
              _buildInputGroup(
                label: 'Toleransi Keterlambatan (menit)',
                controller: _toleranceController,
                keyboardType: TextInputType.number,
                icon: FontAwesomeIcons.hourglassHalf,
                helperText:
                    'Waktu tambahan yang diperbolehkan sebelum dianggap terlambat',
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<AdminSettingsBloc>().add(
                  AdminSettingsUpdate(
                    tolerance: int.tryParse(_toleranceController.text),
                  ),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('Simpan Pengaturan Waktu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInputGroup({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required IconData icon,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey, size: 20),
            hintText: 'Masukkan $label',
            helperText: helperText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryColor),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }
}
