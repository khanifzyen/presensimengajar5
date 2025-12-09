# EduPresence - Aplikasi Presensi Mobile

## Deskripsi
EduPresence adalah aplikasi presensi mobile untuk guru yang dirancang dengan tampilan yang responsif dan user-friendly. Aplikasi ini memungkinkan guru untuk melakukan presensi mengajar dengan mudah melalui perangkat mobile.

## Fitur
- **Presensi Lokasi**: Validasi presensi berdasarkan lokasi (geolocation)
- **Verifikasi Wajah**: Sistem presensi dengan verifikasi foto wajah
- **Jadwal Mengajar**: Menampilkan jadwal mengajar harian
- **Riwayat Presensi**: Melihat riwayat presensi bulanan
- **Pengajuan Izin**: Mengajukan izin sakit, cuti, atau dinas luar
- **Profil Guru**: Mengelola data profil guru
- **Manajemen Guru**: Kelola data guru lengkap (Admin)
- **Jadwal Guru**: Atur dan kelola jadwal mengajar guru (Admin)
- **Approval Izin**: Sistem approval untuk pengajuan izin guru (Admin)
- **Laporan Presensi**: Rekapitulasi dan laporan presensi lengkap (Admin)

## Perbaikan Mobile Terbaru

### 1. Responsive Design
- Mobile frame otomatis hilang saat dibuka di perangkat mobile
- Tampilan menyesuaikan dengan ukuran layar perangkat
- Support untuk berbagai ukuran layar mobile

### 2. Smooth Navigation
- Transisi halus saat berpindah halaman
- Animasi fade-in untuk setiap halaman
- Touch feedback untuk interaksi mobile

### 3. Bottom Navigation
- Navigasi bawah yang konsisten di semua halaman
- Active state yang jelas untuk halaman saat ini
- Touch-friendly dengan ukuran tap target yang optimal

### 4. Performance Optimizations
- Smooth scrolling dengan touch support
- Prevent elastic scroll pada iOS
- Optimized touch performance

## Struktur File

```
lofi/
├── index.html          # Halaman onboarding/splash screen
├── login.html          # Halaman login
├── dashboard-guru.html # Dashboard utama guru
├── dashboard-admin.html # Dashboard admin dengan monitoring lengkap
├── manajemen-guru.html # Halaman manajemen data guru (Admin)
├── jadwal-guru.html   # Halaman manajemen jadwal guru (Admin)
├── approval-izin.html # Halaman approval izin (Admin)
├── laporan.html       # Halaman laporan dan rekap presensi (Admin)
├── presensi.html       # Halaman proses presensi
├── profil.html         # Halaman profil guru
├── riwayat.html        # Halaman riwayat presensi
├── izin.html          # Halaman pengajuan izin dan cuti
├── edit-profil.html    # Halaman edit profil guru
├── ubah-kata-sandi.html # Halaman ubah kata sandi
├── panduan.html        # Halaman panduan penggunaan
├── tentang-aplikasi.html # Halaman tentang aplikasi
├── css/
│   ├── style.css       # CSS utama dengan responsive design
│   ├── dashboard.css   # CSS khusus dashboard
│   ├── admin.css       # CSS khusus dashboard admin
│   ├── manajemen-guru.css # CSS khusus manajemen guru dan jadwal
│   ├── approval-izin.css # CSS khusus approval izin
│   ├── laporan.css       # CSS khusus laporan dan rekap presensi
│   ├── presensi.css    # CSS khusus presensi
│   ├── profil.css      # CSS khusus profil
│   ├── riwayat.css     # CSS khusus riwayat
│   ├── izin.css       # CSS khusus izin dan cuti
│   ├── edit-profil.css # CSS khusus edit profil
│   ├── ubah-kata-sandi.css # CSS khusus ubah kata sandi
│   ├── panduan.css    # CSS khusus panduan
│   ├── tentang-aplikasi.css # CSS khusus tentang aplikasi
│   ├── login.css       # CSS khusus login
│   └── onboarding.css  # CSS khusus onboarding
└── js/
    ├── navigation.js    # JavaScript untuk navigasi dan transisi
    ├── dashboard.js    # JavaScript fungsionalitas dashboard
    ├── dashboard-admin.js # JavaScript fungsionalitas dashboard admin
    ├── manajemen-guru.js # JavaScript fungsionalitas manajemen guru
    ├── jadwal-guru.js   # JavaScript fungsionalitas jadwal guru
    ├── approval-izin.js # JavaScript fungsionalitas approval izin
    ├── laporan.js       # JavaScript fungsionalitas laporan dan rekap presensi
    ├── presensi.js     # JavaScript fungsionalitas presensi
    └── onboarding.js   # JavaScript fungsionalitas onboarding
```

## Cara Penggunaan

1. Buka `index.html` untuk memulai aplikasi
2. Lakukan onboarding atau langsung ke halaman login
3. Masuk dengan kredensial guru
4. Gunakan bottom navigation untuk berpindah halaman:
   - **Guru**:
     - Home: Dashboard utama
     - Calendar: Riwayat presensi
     - Camera: Presensi harian
     - File: Pengajuan izin dan cuti
     - User: Profil guru
   - **Admin**:
     - Dash: Dashboard admin
     - Guru: Manajemen data guru
     - Izin: Persetujuan izin
     - Rekap: Laporan dan rekapitulasi
     - Set: Pengaturan sistem

## Browser Support
- Chrome (Mobile & Desktop)
- Safari (iOS & macOS)
- Firefox (Mobile & Desktop)
- Edge (Mobile & Desktop)

## Responsive Breakpoints
- **Mobile**: < 768px (Tanpa frame, full viewport)
- **Desktop**: ≥ 768px (Dengan frame simulasi mobile)

## Teknologi yang Digunakan
- HTML5
- CSS3 dengan Media Queries
- Vanilla JavaScript
- Font Awesome untuk icons
- Google Fonts (Inter)

## Fitur Admin Terbaru (Desember 2025)

### Manajemen Guru
- **Data Guru Lengkap**: Kelola informasi guru (nama, NIP, mata pelajaran, email, telepon)
- **Status Guru**: Kelola status aktif/non-aktif guru
- **Pencarian dan Filter**: Cari guru berdasarkan nama, NIP, atau mata pelajaran
- **Statistik Guru**: Monitor total guru, aktif, baru, dan non-aktif
- **CRUD Operations**: Tambah, edit, dan hapus data guru

### Manajemen Jadwal
- **Jadwal Mingguan**: Kelola jadwal mengajar per minggu
- **Multi-Periode**: Support beberapa jadwal dalam satu hari
- **Navigasi Minggu**: Pindah antar minggu dengan mudah
- **Informasi Kelas**: Atur mata pelajaran, kelas, dan ruangan
- **Salin Jadwal**: Salin jadwal antar guru
- **Export/Print**: Export jadwal ke CSV dan fungsi print
- **Statistik Jadwal**: Monitor jam mengajar, jumlah kelas, dan hari aktif

### Approval Izin
- **Dashboard Izin**: Monitor pengajuan izin dengan statistik lengkap
- **Filter & Search**: Filter izin berdasarkan status, jenis, dan periode
- **Detail Review**: Lihat detail lengkap pengajuan izin dengan dokumen
- **Quick Actions**: Approve/reject dengan satu klik
- **Batch Actions**: Approve multiple izin sekaligus
- **Export Data**: Export data izin ke Excel dan PDF

### Laporan Presensi
- **Filter Lanjutan**: Filter presensi berdasarkan periode, guru, mata pelajaran, dan status
- **Ringkasan Visual**: Kartu statistik dengan visualisasi data
- **Tabel Detail**: Tabel presensi dengan informasi lengkap
- **Export Options**: Export ke Excel, PDF, dan Print
- **Responsive Design**: Tampilan optimal di desktop dan mobile

## Update Terakhir
- Desember 2025:
  - Perbaikan responsive design dan navigasi mobile
  - Tambah fitur manajemen guru dan jadwal untuk admin
  - Enhanced admin dashboard dengan monitoring lengkap
  - Tambah sistem approval izin untuk admin
  - Tambah halaman laporan dan rekap presensi lengkap
  - Perbaikan filter accordion dan tombol export yang responsif