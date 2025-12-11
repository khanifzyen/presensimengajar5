import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_state.dart';

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
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Theme.of(context).primaryColor,
                            backgroundImage: teacher.photo.isNotEmpty
                                ? NetworkImage(
                                    teacher.photo,
                                  ) // Ensure full URL handling
                                : null,
                            child: teacher.photo.isEmpty
                                ? Text(
                                    teacher.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 40,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            teacher.name,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'NIP. ${teacher.nip}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Guru Pengajar',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
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
                  // TODO: Navigate to Edit Profile
                },
              ),
              _buildMenuItem(
                context,
                icon: FontAwesomeIcons.lock,
                title: 'Ubah Kata Sandi',
                onTap: () {
                  // TODO: Navigate to Change Password
                },
              ),
              _buildMenuItem(
                context,
                icon: FontAwesomeIcons.circleQuestion,
                title: 'Bantuan',
                onTap: () {
                  // TODO: Navigate to Help
                },
              ),
              _buildMenuItem(
                context,
                icon: FontAwesomeIcons.circleInfo,
                title: 'Tentang Aplikasi',
                onTap: () {
                  // TODO: Navigate to About
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
