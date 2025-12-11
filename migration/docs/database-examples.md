# Database Examples & Implementation Guide - EduPresence

## Contoh Data Sample

### 1. Sample Data untuk Users
```json
[
  {
    "id": "admin_001",
    "email": "admin@sekolah.sch.id",
    "password": "$2a$10$hashed_password_here",
    "role": "admin",
    "verified": true,
    "created": "2024-01-01T00:00:00Z",
    "updated": "2024-01-01T00:00:00Z"
  },
  {
    "id": "user_001",
    "email": "budi.santoso@sekolah.sch.id",
    "password": "$2a$10$hashed_password_here",
    "role": "teacher",
    "verified": true,
    "created": "2024-01-01T00:00:00Z",
    "updated": "2024-01-01T00:00:00Z"
  }
]
```

### 2. Sample Data untuk Teachers
```json
[
  {
    "id": "teacher_001",
    "user_id": "user_001",
    "nip": "198506152008011001",
    "name": "Budi Santoso, S.Pd",
    "phone": "0812-3456-7890",
    "address": "Jl. Pendidikan No. 123, Jakarta Selatan",
    "subject_id": "subject_001",
    "position": "guru",
    "attendance_category": "tetap",
    "status": "active",
    "join_date": "2020-01-15",
    "created": "2024-01-01T00:00:00Z",
    "updated": "2024-01-01T00:00:00Z"
  },
  {
    "id": "teacher_002",
    "user_id": "user_002",
    "nip": "198703122009022001",
    "name": "Siti Aminah, S.Pd",
    "phone": "0813-4567-8901",
    "address": "Jl. Guru No. 45, Jakarta Timur",
    "subject_id": "subject_002",
    "position": "guru",
    "attendance_category": "jadwal",
    "status": "active",
    "join_date": "2015-03-10",
    "created": "2024-01-01T00:00:00Z",
    "updated": "2024-01-01T00:00:00Z"
  }
]
```

### 3. Sample Data untuk Subjects
```json
[
  {
    "id": "subject_001",
    "name": "Matematika",
    "code": "MAT",
    "description": "Mata pelajaran Matematika",
    "created": "2024-01-01T00:00:00Z",
    "updated": "2024-01-01T00:00:00Z"
  },
  {
    "id": "subject_002",
    "name": "Bahasa Indonesia",
    "code": "BIN",
    "description": "Mata pelajaran Bahasa Indonesia",
    "created": "2024-01-01T00:00:00Z",
    "updated": "2024-01-01T00:00:00Z"
  }
]
```

### 4. Sample Data untuk Classes
```json
[
  {
    "id": "class_001",
    "name": "XII IPA 1",
    "level": "XII",
    "major": "IPA",
    "room": "Lab IPA 1",
    "capacity": 36,
    "created": "2024-01-01T00:00:00Z",
    "updated": "2024-01-01T00:00:00Z"
  },
  {
    "id": "class_002",
    "name": "XII IPS 1",
    "level": "XII",
    "major": "IPS",
    "room": "Ruang 201",
    "capacity": 32,
    "created": "2024-01-01T00:00:00Z",
    "updated": "2024-01-01T00:00:00Z"
  }
]
```

### 5. Sample Data untuk Academic Periods
```json
[
  {
    "id": "period_001",
    "name": "2024/2025",
    "semester": "ganjil",
    "start_date": "2024-07-01",
    "end_date": "2025-01-31",
    "is_active": true,
    "created": "2024-01-01T00:00:00Z",
    "updated": "2024-01-01T00:00:00Z"
  },
  {
    "id": "period_002",
    "name": "2023/2024",
    "semester": "genap",
    "start_date": "2024-01-01",
    "end_date": "2024-06-30",
    "is_active": false,
    "created": "2023-07-01T00:00:00Z",
    "updated": "2023-07-01T00:00:00Z"
  }
]
```

### 6. Sample Data untuk Schedules
```json
[
  {
    "id": "schedule_001",
    "teacher_id": "teacher_001",
    "subject_id": "subject_001",
    "class_id": "class_001",
    "period_id": "period_001",
    "day": "senin",
    "start_time": "07:00",
    "end_time": "08:30",
    "room": "Lab Matematika",
    "created": "2024-01-01T00:00:00Z",
    "updated": "2024-01-01T00:00:00Z"
  },
  {
    "id": "schedule_002",
    "teacher_id": "teacher_001",
    "subject_id": "subject_001",
    "class_id": "class_002",
    "period_id": "period_001",
    "day": "senin",
    "start_time": "09:00",
    "end_time": "10:30",
    "room": "Ruang 12",
    "created": "2024-01-01T00:00:00Z",
    "updated": "2024-01-01T00:00:00Z"
  }
]
```

### 7. Sample Data untuk Attendances
```json
[
  {
    "id": "attendance_001",
    "teacher_id": "teacher_001",
    "schedule_id": "schedule_001",
    "date": "2024-12-10",
    "type": "class",
    "check_in": "2024-12-10T06:55:00Z",
    "check_out": "2024-12-10T08:30:00Z",
    "status": "hadir",
    "latitude": -7.250445,
    "longitude": 112.768945,
    "location_address": "SMP Negeri 1, Jakarta",
    "photo": "face_verification_001.jpg",
    "notes": "Presensi kelas tepat waktu",
    "created": "2024-12-10T06:55:00Z",
    "updated": "2024-12-10T08:30:00Z"
  },
  {
    "id": "attendance_002",
    "teacher_id": "teacher_001",
    "schedule_id": "schedule_002",
    "date": "2024-12-10",
    "type": "class",
    "check_in": "2024-12-10T08:55:00Z",
    "check_out": "2024-12-10T10:30:00Z",
    "status": "hadir",
    "latitude": -7.250445,
    "longitude": 112.768945,
    "location_address": "SMP Negeri 1, Jakarta",
    "photo": "face_verification_002.jpg",
    "notes": "Presensi kelas tepat waktu",
    "created": "2024-12-10T08:55:00Z",
    "updated": "2024-12-10T10:30:00Z"
  }
]
```

### 8. Sample Data untuk Leave Requests
```json
[
  {
    "id": "leave_001",
    "teacher_id": "teacher_001",
    "type": "sakit",
    "start_date": "2024-12-12",
    "end_date": "2024-12-13",
    "reason": "Demam tinggi, perlu istirahat",
    "attachment": "surat_dokter.pdf",
    "status": "pending",
    "approved_by": null,
    "approved_at": null,
    "rejection_reason": null,
    "created": "2024-12-11T10:00:00Z",
    "updated": "2024-12-11T10:00:00Z"
  },
  {
    "id": "leave_002",
    "teacher_id": "teacher_002",
    "type": "cuti",
    "start_date": "2024-11-15",
    "end_date": "2024-11-16",
    "reason": "Acara keluarga di luar kota",
    "attachment": "surat_izin.pdf",
    "status": "approved",
    "approved_by": "admin_001",
    "approved_at": "2024-11-14T09:00:00Z",
    "rejection_reason": null,
    "created": "2024-11-10T08:00:00Z",
    "updated": "2024-11-14T09:00:00Z"
  }
]
```

### 9. Sample Data untuk Settings
```json
[
  {
    "id": "setting_001",
    "key": "school_name",
    "value": "SMP Negeri 1",
    "type": "text",
    "description": "Nama sekolah",
    "category": "general",
    "created": "2024-01-01T00:00:00Z",
    "updated": "2024-01-01T00:00:00Z"
  },
  {
    "id": "setting_002",
    "key": "attendance_radius",
    "value": "100",
    "type": "number",
    "description": "Radius presensi (meter)",
    "category": "location",
    "created": "2024-01-01T00:00:00Z",
    "updated": "2024-01-01T00:00:00Z"
  },
  {
    "id": "setting_003",
    "key": "office_start_time",
    "value": "07:00",
    "type": "text",
    "description": "Jam masuk kantor",
    "category": "time",
    "created": "2024-01-01T00:00:00Z",
    "updated": "2024-01-01T00:00:00Z"
  }
]
```

### 10. Sample Data untuk Notifications
```json
[
  {
    "id": "notif_001",
    "user_id": "admin_001",
    "title": "Pengajuan Izin Baru",
    "message": "Budi Santoso mengajukan izin sakit untuk tanggal 12-13 Desember 2024",
    "type": "info",
    "is_read": false,
    "data": {
      "leave_request_id": "leave_001",
      "teacher_name": "Budi Santoso"
    },
    "created": "2024-12-11T10:00:00Z",
    "updated": "2024-12-11T10:00:00Z"
  },
  {
    "id": "notif_002",
    "user_id": "user_001",
    "title": "Izin Disetujui",
    "message": "Pengajuan izin Anda telah disetujui oleh Admin",
    "type": "success",
    "is_read": true,
    "data": {
      "leave_request_id": "leave_002"
    },
    "created": "2024-11-14T09:00:00Z",
    "updated": "2024-11-14T10:00:00Z"
  }
]
```

## Query Examples untuk React Native Expo

### 1. Authentication Service
```javascript
import PocketBase from 'pocketbase';

const pb = new PocketBase('https://your-pocketbase-url.com');

export class AuthService {
  static async login(email, password) {
    try {
      const authData = await pb.collection('users').authWithPassword(email, password);
      return {
        success: true,
        user: authData.record,
        token: authData.token
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  static async logout() {
    pb.authStore.clear();
    return true;
  }

  static getCurrentUser() {
    return pb.authStore.model;
  }

  static isAuthenticated() {
    return pb.authStore.isValid;
  }
}
```

### 2. Teacher Service
```javascript
export class TeacherService {
  static async getTeacherByUserId(userId) {
    try {
      const teacher = await pb.collection('teachers').getFirstListItem(`user_id="${userId}"`, {
        expand: 'subject_id'
      });
      return {
        success: true,
        data: teacher
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  static async updateTeacher(teacherId, data) {
    try {
      const updatedTeacher = await pb.collection('teachers').update(teacherId, data);
      return {
        success: true,
        data: updatedTeacher
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  static async getAllTeachers() {
    try {
      const teachers = await pb.collection('teachers').getFullList({
        expand: 'subject_id'
      });
      return {
        success: true,
        data: teachers
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }
}
```

### 3. Attendance Service
```javascript
export class AttendanceService {
  static async checkIn(teacherId, attendanceData) {
    try {
      const attendance = await pb.collection('attendances').create({
        teacher_id: teacherId,
        date: new Date().toISOString().split('T')[0],
        type: attendanceData.type,
        check_in: new Date().toISOString(),
        latitude: attendanceData.latitude,
        longitude: attendanceData.longitude,
        location_address: attendanceData.locationAddress,
        photo: attendanceData.photo,
        status: attendanceData.status,
        schedule_id: attendanceData.scheduleId || null
      });
      return {
        success: true,
        data: attendance
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  static async checkOut(attendanceId) {
    try {
      const updatedAttendance = await pb.collection('attendances').update(attendanceId, {
        check_out: new Date().toISOString()
      });
      return {
        success: true,
        data: updatedAttendance
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  static async getTodayAttendance(teacherId) {
    try {
      const today = new Date().toISOString().split('T')[0];
      const attendance = await pb.collection('attendances').getFirstListItem(
        `teacher_id="${teacherId}" && date="${today}"`
      );
      return {
        success: true,
        data: attendance
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  static async getMonthlyAttendance(teacherId, year, month) {
    try {
      const startDate = new Date(year, month - 1, 1).toISOString().split('T')[0];
      const endDate = new Date(year, month, 0).toISOString().split('T')[0];
      
      const attendances = await pb.collection('attendances').getFullList({
        filter: `teacher_id="${teacherId}" && date >= "${startDate}" && date <= "${endDate}"`,
        sort: '-date'
      });
      
      return {
        success: true,
        data: attendances
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }
}
```

### 4. Schedule Service
```javascript
export class ScheduleService {
  static async getTeacherSchedule(teacherId, day = null) {
    try {
      let filter = `teacher_id="${teacherId}"`;
      if (day) {
        filter += ` && day="${day}"`;
      }
      
      const schedules = await pb.collection('schedules').getFullList({
        filter: filter,
        expand: 'subject_id, class_id'
      });
      
      return {
        success: true,
        data: schedules
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  static async getTodaySchedule(teacherId) {
    const days = ['minggu', 'senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu'];
    const today = days[new Date().getDay()];
    
    return this.getTeacherSchedule(teacherId, today);
  }

  static async createSchedule(scheduleData) {
    try {
      const schedule = await pb.collection('schedules').create(scheduleData);
      return {
        success: true,
        data: schedule
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  static async updateSchedule(scheduleId, scheduleData) {
    try {
      const updatedSchedule = await pb.collection('schedules').update(scheduleId, scheduleData);
      return {
        success: true,
        data: updatedSchedule
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  static async deleteSchedule(scheduleId) {
    try {
      await pb.collection('schedules').delete(scheduleId);
      return {
        success: true
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }
}
```

### 5. Leave Request Service
```javascript
export class LeaveRequestService {
  static async submitLeaveRequest(leaveData) {
    try {
      const leaveRequest = await pb.collection('leave_requests').create(leaveData);
      return {
        success: true,
        data: leaveRequest
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  static async getTeacherLeaveRequests(teacherId) {
    try {
      const leaveRequests = await pb.collection('leave_requests').getFullList({
        filter: `teacher_id="${teacherId}"`,
        sort: '-created'
      });
      
      return {
        success: true,
        data: leaveRequests
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  static async getAllLeaveRequests(status = null) {
    try {
      let filter = '';
      if (status) {
        filter = `status="${status}"`;
      }
      
      const leaveRequests = await pb.collection('leave_requests').getFullList({
        filter: filter,
        expand: 'teacher_id',
        sort: '-created'
      });
      
      return {
        success: true,
        data: leaveRequests
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  static async approveLeaveRequest(leaveRequestId, adminId, note = null) {
    try {
      const updatedRequest = await pb.collection('leave_requests').update(leaveRequestId, {
        status: 'approved',
        approved_by: adminId,
        approved_at: new Date().toISOString()
      });
      
      return {
        success: true,
        data: updatedRequest
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  static async rejectLeaveRequest(leaveRequestId, adminId, rejectionReason) {
    try {
      const updatedRequest = await pb.collection('leave_requests').update(leaveRequestId, {
        status: 'rejected',
        approved_by: adminId,
        approved_at: new Date().toISOString(),
        rejection_reason: rejectionReason
      });
      
      return {
        success: true,
        data: updatedRequest
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }
}
```

### 6. Settings Service
```javascript
export class SettingsService {
  static async getSetting(key) {
    try {
      const setting = await pb.collection('settings').getFirstListItem(`key="${key}"`);
      return {
        success: true,
        data: setting.value
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  static async getAllSettings() {
    try {
      const settings = await pb.collection('settings').getFullList();
      
      // Convert to key-value object
      const settingsObj = {};
      settings.forEach(setting => {
        settingsObj[setting.key] = setting.value;
      });
      
      return {
        success: true,
        data: settingsObj
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  static async updateSetting(key, value) {
    try {
      const setting = await pb.collection('settings').getFirstListItem(`key="${key}"`);
      const updatedSetting = await pb.collection('settings').update(setting.id, { value });
      
      return {
        success: true,
        data: updatedSetting
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }
}
```

### 7. Report Service
```javascript
export class ReportService {
  static async getAttendanceReport(filters = {}) {
    try {
      let filter = '';
      
      if (filters.teacherId) {
        filter += `teacher_id="${filters.teacherId}"`;
      }
      
      if (filters.startDate && filters.endDate) {
        filter += filter ? ' && ' : '';
        filter += `date >= "${filters.startDate}" && date <= "${filters.endDate}"`;
      }
      
      if (filters.status) {
        filter += filter ? ' && ' : '';
        filter += `status="${filters.status}"`;
      }
      
      if (filters.type) {
        filter += filter ? ' && ' : '';
        filter += `type="${filters.type}"`;
      }
      
      const attendances = await pb.collection('attendances').getFullList({
        filter: filter,
        expand: 'teacher_id',
        sort: '-date'
      });
      
      return {
        success: true,
        data: attendances
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  static async getMonthlySummary(year, month) {
    try {
      const startDate = new Date(year, month - 1, 1).toISOString().split('T')[0];
      const endDate = new Date(year, month, 0).toISOString().split('T')[0];
      
      const attendances = await pb.collection('attendances').getFullList({
        filter: `date >= "${startDate}" && date <= "${endDate}"`
      });
      
      // Calculate summary
      const summary = {
        totalDays: attendances.length,
        hadir: attendances.filter(a => a.status === 'hadir').length,
        telat: attendances.filter(a => a.status === 'telat').length,
        izin: attendances.filter(a => a.status === 'izin').length,
        sakit: attendances.filter(a => a.status === 'sakit').length,
        alpha: attendances.filter(a => a.status === 'alpha').length
      };
      
      return {
        success: true,
        data: summary
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }
}
```

## Implementation Tips

### 1. File Upload Handling
```javascript
export const uploadFile = async (file) => {
  try {
    const formData = new FormData();
    formData.append('file', file);
    
    const result = await pb.collection('attendances').create(formData);
    return result;
  } catch (error) {
    console.error('Upload error:', error);
    throw error;
  }
};
```

### 2. Error Handling
```javascript
export const handlePocketBaseError = (error) => {
  if (error.status === 400) {
    return 'Data yang dimasukkan tidak valid';
  } else if (error.status === 401) {
    return 'Unauthorized - Silakan login kembali';
  } else if (error.status === 404) {
    return 'Data tidak ditemukan';
  } else if (error.status === 500) {
    return 'Terjadi kesalahan pada server';
  } else {
    return error.message || 'Terjadi kesalahan yang tidak diketahui';
  }
};
```

### 3. Pagination
```javascript
export const getPaginatedData = async (collection, page = 1, limit = 20, filter = '') => {
  try {
    const result = await pb.collection(collection).getList(page, limit, {
      filter: filter,
      sort: '-created'
    });
    
    return {
      success: true,
      data: result.items,
      totalPages: result.totalPages,
      totalItems: result.totalItems
    };
  } catch (error) {
    return {
      success: false,
      error: handlePocketBaseError(error)
    };
  }
};
```

## Testing Data

### 1. Test User Creation
```javascript
const createTestUser = async () => {
  try {
    const user = await pb.collection('users').create({
      email: 'test@teacher.com',
      password: 'test123456',
      passwordConfirm: 'test123456',
      role: 'teacher'
    });
    
    const teacher = await pb.collection('teachers').create({
      user_id: user.id,
      nip: '123456789012345678',
      name: 'Test Teacher',
      attendance_category: 'jadwal',
      status: 'active'
    });
    
    console.log('Test user created:', { user, teacher });
  } catch (error) {
    console.error('Error creating test user:', error);
  }
};
```

### 2. Test Attendance Creation
```javascript
const createTestAttendance = async () => {
  try {
    const attendance = await pb.collection('attendances').create({
      teacher_id: 'teacher_001',
      date: new Date().toISOString().split('T')[0],
      type: 'class',
      check_in: new Date().toISOString(),
      status: 'hadir',
      latitude: -7.250445,
      longitude: 112.768945
    });
    
    console.log('Test attendance created:', attendance);
  } catch (error) {
    console.error('Error creating test attendance:', error);
  }
};
```

## Performance Optimization

### 1. Caching Strategy
```javascript
class CacheService {
  static cache = new Map();
  static cacheTimeout = 5 * 60 * 1000; // 5 minutes

  static async get(key, fetchFunction) {
    const cached = this.cache.get(key);
    
    if (cached && Date.now() - cached.timestamp < this.cacheTimeout) {
      return cached.data;
    }
    
    const data = await fetchFunction();
    this.cache.set(key, {
      data,
      timestamp: Date.now()
    });
    
    return data;
  }
}
```

### 2. Batch Operations
```javascript
export const batchCreateAttendances = async (attendances) => {
  const results = [];
  
  for (const attendance of attendances) {
    try {
      const result = await pb.collection('attendances').create(attendance);
      results.push({ success: true, data: result });
    } catch (error) {
      results.push({ success: false, error: error.message });
    }
  }
  
  return results;
};
```

## Security Implementation

### 1. Token Refresh
```javascript
export const setupTokenRefresh = () => {
  pb.collection('users').authRefresh(() => {
    console.log('Token refreshed');
  });
};
```

### 2. Request Interceptor
```javascript
export const setupRequestInterceptor = () => {
  pb.beforeSend = (url, options) => {
    // Add custom headers
    options.headers = {
      ...options.headers,
      'X-Custom-Header': 'EduPresence-Mobile'
    };
    
    return { url, options };
  };
};
```

## Conclusion

Contoh implementasi ini menyediakan:
- Data sample yang realistis untuk testing
- Service classes yang terstruktur untuk React Native
- Error handling yang komprehensif
- Performance optimization tips
- Security best practices
- Testing utilities

Implementasi ini siap digunakan sebagai foundation untuk pengembangan aplikasi React Native dengan Expo dan PocketBase backend.