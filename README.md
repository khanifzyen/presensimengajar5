# EduPresence Database Documentation

## Overview

Dokumentasi ini berisi struktur database PocketBase yang komprehensif untuk aplikasi presensi guru EduPresence berdasarkan analisis UI/UX yang telah dilakukan.

## 📁 File Structure

```
database-documentation/
├── README.md                    # File ini - Executive Summary
├── database-structure.md       # Struktur database lengkap
├── database-examples.md         # Contoh data & implementasi React Native
└── database-validation.md       # Validasi & business logic
```

## 🚀 Quick Start

### 1. Prerequisites
- PocketBase v0.22.0 atau lebih tinggi
- React Native dengan Expo
- Node.js v18+ untuk development

### 2. Database Setup
```bash
# Download PocketBase
wget https://github.com/pocketbase/pocketbase/releases/download/v0.22.0/pocketbase_0.22.0_linux_amd64.zip

# Extract dan setup
unzip pocketbase_0.22.0_linux_amd64.zip
cd pocketbase

# Start PocketBase
./pocketbase serve --http=0.0.0.0:8090
```

### 3. Import Database Structure
1. Buka PocketBase Admin Panel di `http://localhost:8090/_/`
2. Import collections dari [`database-structure.md`](database-structure.md)
3. Jalankan migration scripts dari [`database-validation.md`](database-validation.md)

## 📊 Database Architecture

### Core Entities
- **Users**: Authentication & authorization
- **Teachers**: Guru profile & data
- **Attendances**: Presensi harian
- **Schedules**: Jadwal mengajar
- **Leave Requests**: Pengajuan izin
- **Subjects**: Mata pelajaran
- **Classes**: Data kelas
- **Settings**: Konfigurasi sistem

### Key Features Supported
✅ **Multi-role System** (Admin & Guru)  
✅ **Attendance with Location & Photo**  
✅ **Schedule Management**  
✅ **Leave Request & Approval**  
✅ **Real-time Notifications**  
✅ **Comprehensive Reporting**  
✅ **System Settings**  

## 🔧 Implementation Guide

### React Native Integration
```javascript
import PocketBase from 'pocketbase';

const pb = new PocketBase('https://your-pocketbase-url.com');

// Authentication
const authData = await pb.collection('users').authWithPassword(email, password);

// API Calls
const teachers = await pb.collection('teachers').getFullList({
  expand: 'subject_id'
});
```

### Key Services
- [`AuthService`](database-examples.md#1-authentication-service) - Login/Logout
- [`TeacherService`](database-examples.md#2-teacher-service) - Guru management
- [`AttendanceService`](database-examples.md#3-attendance-service) - Presensi
- [`ScheduleService`](database-examples.md#4-schedule-service) - Jadwal
- [`LeaveRequestService`](database-examples.md#5-leave-request-service) - Izin

## 📱 Mobile App Features Mapping

### Guru Features
| Feature | Database Table | API Endpoint |
|---------|---------------|--------------|
| Login | `users` | `POST /api/users/auth-with-password` |
| Dashboard | `attendances`, `schedules` | `GET /api/attendances/records` |
| Presensi | `attendances` | `POST /api/attendances/records` (Scan/Face Verification) |
| Riwayat | `attendances` | `GET /api/attendances/records` |
| Izin | `leave_requests` | `POST /api/leave_requests/records` |
| Profil | `teachers` | `GET /api/teachers/records` |

### Admin Features
| Feature | Database Table | API Endpoint |
|---------|---------------|--------------|
| Dashboard | `attendances`, `teachers` | `GET /api/attendances/records` |
| Manajemen Guru | `teachers` | `CRUD /api/teachers/records` |
| Jadwal Guru | `schedules` | `CRUD /api/schedules/records` |
| Approval Izin | `leave_requests` | `PATCH /api/leave_requests/records` |
| Laporan | `attendances` | `GET /api/attendances/records` |
| Pengaturan | `settings` | `CRUD /api/settings/records` |

## 🔐 Security Features

### Authentication & Authorization
- **Role-based Access Control** (Admin/Teacher)
- **JWT Token Authentication**
- **Password Hashing** dengan bcrypt
- **Session Management**

### Data Protection
- **Input Validation** untuk semua API endpoints
- **File Upload Validation** untuk foto & dokumen
- **Location-based Attendance** dengan radius validation
- **Audit Trail** untuk semua perubahan data

## 📈 Performance Optimization

### Database Indexes
- `teachers_user_id_unique`
- `attendances_teacher_id_date_unique`
- `schedules_teacher_id_index`
- `leave_requests_status_index`

### Caching Strategy
- Settings cache (5 minutes)
- User session cache
- Schedule cache (daily)

### Query Optimization
- Pagination untuk large datasets
- Efficient filtering dengan proper indexes
- Batch operations untuk bulk data

## 🧪 Testing

### Sample Data
Lihat [`database-examples.md`](database-examples.md#contoh-data-sample) untuk sample data lengkap.

### Test Scripts
```javascript
// Create test user
const createTestUser = async () => {
  const user = await pb.collection('users').create({
    email: 'test@teacher.com',
    password: 'test123456',
    passwordConfirm: 'test123456',
    role: 'teacher'
  });
  return user;
};
```

## 🔄 Migration & Backup

### Data Migration
- Automated migration scripts
- Data validation checks
- Rollback procedures

### Backup Strategy
- Daily automated backups
- Point-in-time recovery
- Data export in JSON format

## 📋 Validation Rules

### Business Logic
- **Double Attendance Prevention**: Guru tidak bisa presensi ganda
- **Schedule Conflict Detection**: Tidak ada jadwal yang bentrok
- **Leave Request Validation**: Izin tidak boleh bentrok jadwal
- **Location Validation**: Presensi harus dalam radius sekolah

### Data Integrity
- **Unique Constraints**: Email, NIP, user-teacher relationship
- **Foreign Key Constraints**: All relationships validated
- **Check Constraints**: Enum values validation

## 🚀 Deployment

### Production Setup
1. **PocketBase Server**: Deploy di VPS atau cloud provider
2. **Database**: SQLite dengan regular backups
3. **File Storage**: Local atau cloud storage untuk foto & dokumen
4. **SSL/TLS**: HTTPS untuk production

### Environment Variables
```bash
POCKETBASE_URL=https://your-domain.com
POCKETBASE_ADMIN_EMAIL=admin@sekolah.sch.id
POCKETBASE_ADMIN_PASSWORD=secure_password
ATTENDANCE_RADIUS=100
OFFICE_START_TIME=07:00
```

## 📞 Support & Maintenance

### Monitoring
- Database performance metrics
- API response times
- Error tracking & logging
- User activity monitoring

### Maintenance Tasks
- Weekly data backup verification
- Monthly performance optimization
- Quarterly security audit
- Annual data archival

## 📚 Documentation Links

- [Database Structure Details](database-structure.md) - Complete schema documentation
- [Implementation Examples](database-examples.md) - React Native code examples
- [Validation & Rules](database-validation.md) - Business logic & constraints

## 🤝 Contributing

1. Fork repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Related Projects

- [EduPresence Mobile App](../expo-app/) - React Native implementation
- [EduPresence Admin Panel](../admin-panel/) - Web admin interface
- [EduPresence API](../api/) - RESTful API documentation

---

**Note**: Database ini dirancang khusus untuk aplikasi EduPresence dengan fitur presensi guru yang komprehensif. Untuk pertanyaan atau dukungan teknis, silakan hubungi development team.