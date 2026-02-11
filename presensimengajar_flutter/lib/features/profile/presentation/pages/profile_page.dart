import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../auth/presentation/blocs/auth/auth_bloc.dart';
import '../../../auth/presentation/blocs/auth/auth_event.dart';
import 'package:presensimengajar_flutter/features/profile/presentation/blocs/user/user_bloc.dart';
import 'package:presensimengajar_flutter/features/profile/presentation/blocs/user/user_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is UserLoaded) {
                    final teacher = state.teacher;
                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 60), // Top padding
                          // Avatar with white border
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              backgroundImage: teacher.photo.isNotEmpty
                                  ? NetworkImage(
                                      teacher.getPhotoUrl(
                                        dotenv.env['POCKETBASE_URL'] ??
                                            'https://pb-presensi.pasarjepara.com',
                                      ),
                                    )
                                  : null,
                              child: teacher.photo.isEmpty
                                  ? Text(
                                      teacher.name
                                          .split(' ')
                                          .map((word) => word[0])
                                          .take(2)
                                          .join()
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Name
                          Text(
                            teacher.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          // NIP
                          Text(
                            'NIP. ${teacher.nip}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Guru Pengajar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30), // Bottom padding
                        ],
                      ),
                    );
                  } else if (state is UserLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return const Center(child: Text('Gagal memuat profil'));
                  }
                },
              ),

              const SizedBox(height: 20),

              // Menu List
              _buildMenuItem(
                context,
                icon: FontAwesomeIcons.userPen,
                title: 'Edit Profil',
                onTap: () {
                  context.push('/edit-profile');
                },
              ),
              _buildMenuItem(
                context,
                icon: FontAwesomeIcons.lock,
                title: 'Ubah Kata Sandi',
                onTap: () {
                  context.push('/change-password');
                },
              ),
              _buildMenuItem(
                context,
                icon: FontAwesomeIcons.circleQuestion,
                title: 'Bantuan',
                onTap: () {
                  context.push('/guide');
                },
              ),
              _buildMenuItem(
                context,
                icon: FontAwesomeIcons.circleInfo,
                title: 'Tentang Aplikasi',
                onTap: () {
                  context.push('/about');
                },
              ),

              const SizedBox(height: 40),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                    context.go('/login');
                  },
                  icon: const Icon(FontAwesomeIcons.rightFromBracket),
                  label: const Text('Keluar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'EduPresence v1.0.0',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
