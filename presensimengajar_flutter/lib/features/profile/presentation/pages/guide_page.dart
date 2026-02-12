import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../blocs/content/content_bloc.dart';
import '../blocs/content/content_event.dart';
import '../blocs/content/content_state.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ContentBloc>()..add(FetchGuides()),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text(
            'Panduan Aplikasi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocBuilder<ContentBloc, ContentState>(
          builder: (context, state) {
            if (state is ContentLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ContentError) {
              return Center(child: Text(state.message));
            }

            if (state is GuidesLoaded) {
              if (state.guides.isEmpty) {
                return const Center(child: Text('Tidak ada panduan'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.guides.length,
                itemBuilder: (context, index) {
                  final guide = state.guides[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ExpansionTile(
                      shape: const Border(),
                      title: Text(
                        guide['title'] ?? 'Panduan',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      leading: const Icon(
                        Icons.book,
                        color: AppTheme.primaryColor,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            guide['content'] ?? '',
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              color: Colors.grey[800],
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }

            return const Center(child: SizedBox());
          },
        ),
      ),
    );
  }
}
