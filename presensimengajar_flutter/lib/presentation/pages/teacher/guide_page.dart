import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panduan Aplikasi'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildGuideItem(
            context,
            icon: Icons.login,
            title: 'Login',
            description:
                'Gunakan email dan password yang telah didaftarkan oleh admin untuk masuk ke dalam aplikasi.',
          ),
          _buildGuideItem(
            context,
            icon: Icons.camera_alt,
            title: 'Presensi Mengajar',
            description:
                '1. Buka menu "Kelas Saat Ini" di dashboard.\n'
                '2. Pastikan Anda berada di lingkungan sekolah (lokasi terdeteksi).\n'
                '3. Ambil foto selfie di kelas.\n'
                '4. Tekan tombol "Kirim Presensi".',
          ),
          _buildGuideItem(
            context,
            icon: Icons.assignment,
            title: 'Pengajuan Izin',
            description:
                '1. Buka menu "History" atau "Izin".\n'
                '2. Pilih tab "Pengajuan Izin".\n'
                '3. Isi formulir (Tanggal, Jenis, Alasan, Lampiran).\n'
                '4. Tekan "Kirim" dan tunggu persetujuan admin.',
          ),
          _buildGuideItem(
            context,
            icon: Icons.history,
            title: 'Riwayat Presensi',
            description:
                'Anda dapat melihat riwayat kehadiran Anda per bulan pada menu "History". Data mencakup kehadiran tepat waktu, terlambat, izin, dan alpha.',
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
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
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
