import 'package:pocketbase/pocketbase.dart';
import '../../domain/repositories/content_repository.dart';

class ContentRepositoryImpl implements ContentRepository {
  final PocketBase pb;

  ContentRepositoryImpl(this.pb);

  @override
  Future<List<Map<String, dynamic>>> getGuides() async {
    try {
      final records = await pb.collection('guides').getFullList(sort: 'order');
      return records.map((r) => r.data).toList();
    } catch (e) {
      // Fallback data if collection doesn't exist
      return [
        {
          'title': 'Cara Melakukan Presensi',
          'content':
              'Buka menu Jadwal, pilih jadwal aktif, lalu klik tombol Check-In. Pastikan Anda berada di radius sekolah.',
        },
        {
          'title': 'Cara Mengajukan Izin',
          'content':
              'Buka menu Izin, klik tombol Tambah (+), isi formulir izin, lampirkan bukti jika ada, lalu kirim.',
        },
        {
          'title': 'Cara Mengubah Profil',
          'content':
              'Masuk ke menu Profil, klik Edit Profil, ubah data yang diinginkan, lalu Simpan.',
        },
      ];
    }
  }

  @override
  Future<Map<String, dynamic>> getAppInfo() async {
    try {
      final record = await pb.collection('app_info').getFirstListItem('');
      return record.data;
    } catch (e) {
      // Fallback data
      return {
        'version': '1.0.0',
        'build_number': '1',
        'changelog':
            'Initial Release\n- Fitur Presensi\n- Fitur Izin\n- Fitur Jadwal',
        'contact_email': 'admin@sekolah.sch.id',
        'contact_phone': '08123456789',
      };
    }
  }
}
