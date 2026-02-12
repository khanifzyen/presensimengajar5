import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../blocs/content/content_bloc.dart';
import '../blocs/content/content_event.dart';
import '../blocs/content/content_state.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ContentBloc>()..add(FetchAppInfo()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tentang Aplikasi'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<ContentBloc, ContentState>(
          builder: (context, state) {
            String version = '1.0.0';
            String changelog = '';
            String contactEmail = 'admin@sekolah.sch.id';

            if (state is AppInfoLoaded) {
              version = state.appInfo['version'] ?? '1.0.0';
              changelog = state.appInfo['changelog'] ?? '';
              contactEmail =
                  state.appInfo['contact_email'] ?? 'admin@sekolah.sch.id';
            }

            if (state is ContentLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        FontAwesomeIcons.graduationCap,
                        size: 64,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // App Name & Version
                    const Text(
                      'Presensi Mengajar',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Versi $version',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Description
                    const Text(
                      'Aplikasi Presensi Mengajar untuk SMP Negeri 1. \nMemudahkan guru dalam melakukan pencatatan kehadiran mengajar secara real-time dan akurat berbasis lokasi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),

                    if (changelog.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Apa yang baru:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          changelog,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Credits / Developer Info
                    _buildInfoRow('Dikembangkan oleh', 'Tim IT Sekolah'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Kontak Support', contactEmail),

                    const SizedBox(height: 48),

                    // Copyright
                    Text(
                      '© ${DateTime.now().year} SMP Negeri 1. All Rights Reserved.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
