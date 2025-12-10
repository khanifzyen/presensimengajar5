# Database Validation & Implementation Guide - EduPresence

## Validasi Relasi Antar Tabel

### 1. Relasi User-Teacher
```sql
-- Validasi: Setiap teacher harus memiliki user yang valid
-- Rule: users.role = 'teacher' untuk teacher records
-- Cascade: Jika user dihapus, teacher juga dihapus

SELECT t.*, u.email, u.role 
FROM teachers t 
JOIN users u ON t.user_id = u.id 
WHERE u.role = 'teacher';

-- Check untuk teacher tanpa user yang valid
SELECT t.id, t.name, t.user_id 
FROM teachers t 
LEFT JOIN users u ON t.user_id = u.id 
WHERE u.id IS NULL OR u.role != 'teacher';
```

### 2. Relasi Teacher-Subject
```sql
-- Validasi: Subject harus ada untuk teacher
-- Rule: Subject bisa null jika teacher tidak mengajar mata pelajaran spesifik

SELECT t.name as teacher_name, s.name as subject_name 
FROM teachers t 
LEFT JOIN subjects s ON t.subject_id = s.id;

-- Check untuk teacher dengan subject yang tidak valid
SELECT t.id, t.name, t.subject_id 
FROM teachers t 
LEFT JOIN subjects s ON t.subject_id = s.id 
WHERE t.subject_id IS NOT NULL AND s.id IS NULL;
```

### 3. Relasi Schedule (Teacher-Subject-Class-Period)
```sql
-- Validasi: Semua relasi schedule harus valid
-- Rule: Tidak boleh ada schedule yang bertabrakan waktu untuk teacher yang sama

SELECT 
    sch.id,
    t.name as teacher_name,
    sub.name as subject_name,
    c.name as class_name,
    ap.name as period_name,
    sch.day,
    sch.start_time,
    sch.end_time
FROM schedules sch
JOIN teachers t ON sch.teacher_id = t.id
JOIN subjects sub ON sch.subject_id = sub.id
JOIN classes c ON sch.class_id = c.id
JOIN academic_periods ap ON sch.period_id = ap.id;

-- Check untuk schedule dengan relasi yang tidak valid
SELECT sch.id, sch.teacher_id, sch.subject_id, sch.class_id, sch.period_id
FROM schedules sch
LEFT JOIN teachers t ON sch.teacher_id = t.id
LEFT JOIN subjects sub ON sch.subject_id = sub.id
LEFT JOIN classes c ON sch.class_id = c.id
LEFT JOIN academic_periods ap ON sch.period_id = ap.id
WHERE t.id IS NULL OR sub.id IS NULL OR c.id IS NULL OR ap.id IS NULL;

-- Check untuk schedule yang bertabrakan
SELECT sch1.teacher_id, sch1.day, sch1.start_time, sch1.end_time, sch2.id as conflict_id
FROM schedules sch1
JOIN schedules sch2 ON sch1.teacher_id = sch2.teacher_id 
    AND sch1.day = sch2.day 
    AND sch1.id != sch2.id
    AND (
        (sch1.start_time >= sch2.start_time AND sch1.start_time < sch2.end_time) OR
        (sch1.end_time > sch2.start_time AND sch1.end_time <= sch2.end_time) OR
        (sch1.start_time <= sch2.start_time AND sch1.end_time >= sch2.end_time)
    );
```

### 4. Relasi Attendance-Teacher-Schedule
```sql
-- Validasi: Attendance harus memiliki teacher yang valid
-- Rule: Schedule bisa null untuk presensi kantor

SELECT 
    a.id,
    t.name as teacher_name,
    a.date,
    a.type,
    a.status,
    sch.day,
    sch.start_time,
    sch.end_time
FROM attendances a
JOIN teachers t ON a.teacher_id = t.id
LEFT JOIN schedules sch ON a.schedule_id = sch.id;

-- Check untuk attendance dengan teacher yang tidak valid
SELECT a.id, a.teacher_id, a.date 
FROM attendances a
LEFT JOIN teachers t ON a.teacher_id = t.id
WHERE t.id IS NULL;

-- Check untuk attendance dengan schedule yang tidak valid
SELECT a.id, a.schedule_id 
FROM attendances a
LEFT JOIN schedules sch ON a.schedule_id = sch.id
WHERE a.schedule_id IS NOT NULL AND sch.id IS NULL;

-- Validasi: Teacher tidak boleh ada double attendance per hari per type
SELECT a.teacher_id, a.date, a.type, COUNT(*) as count
FROM attendances a
GROUP BY a.teacher_id, a.date, a.type
HAVING COUNT(*) > 1;
```

### 5. Relasi Leave Request-Teacher-User (Approval)
```sql
-- Validasi: Leave request harus memiliki teacher yang valid
-- Rule: approved_by harus user dengan role 'admin'

SELECT 
    lr.id,
    t.name as teacher_name,
    lr.type,
    lr.start_date,
    lr.end_date,
    lr.status,
    u.email as approved_by_email
FROM leave_requests lr
JOIN teachers t ON lr.teacher_id = t.id
LEFT JOIN users u ON lr.approved_by = u.id;

-- Check untuk leave request dengan teacher yang tidak valid
SELECT lr.id, lr.teacher_id 
FROM leave_requests lr
LEFT JOIN teachers t ON lr.teacher_id = t.id
WHERE t.id IS NULL;

-- Check untuk leave request dengan approver yang tidak valid
SELECT lr.id, lr.approved_by 
FROM leave_requests lr
LEFT JOIN users u ON lr.approved_by = u.id
WHERE lr.approved_by IS NOT NULL AND (u.id IS NULL OR u.role != 'admin');
```

## Business Logic Validation

### 1. Validasi Presensi Guru Tetap vs Jadwal
```sql
-- Guru tetap hanya boleh presensi kantor 1x per hari
-- Foto wajah wajib diupload saat presensi (Face Verification) sesuai jadwal

-- Check guru tetap yang presensi lebih dari 1x per hari
SELECT a.teacher_id, a.date, COUNT(*) as attendance_count
FROM attendances a
JOIN teachers t ON a.teacher_id = t.id
WHERE t.attendance_category = 'tetap' AND a.type = 'office'
GROUP BY a.teacher_id, a.date
HAVING COUNT(*) > 1;

-- Check guru jadwal yang presensi di luar jadwal
SELECT a.teacher_id, a.date, a.check_in
FROM attendances a
JOIN teachers t ON a.teacher_id = t.id
WHERE t.attendance_category = 'jadwal' 
    AND a.type = 'class'
    AND a.schedule_id IS NULL;
```

### 2. Validasi Tanggal Izin vs Jadwal
```sql
-- Izin tidak boleh bertabrakan dengan jadwal mengajar
-- Atau jika bertabrakan, harus ada guru pengganti

SELECT 
    lr.teacher_id,
    lr.start_date,
    lr.end_date,
    sch.day,
    sch.start_time,
    sch.end_time
FROM leave_requests lr
JOIN teachers t ON lr.teacher_id = t.id
JOIN schedules sch ON t.id = sch.teacher_id
WHERE lr.status = 'approved'
    AND (
        (lr.start_date <= sch.day_date AND lr.end_date >= sch.day_date)
    );
```

### 3. Validasi Jam Presensi vs Jam Kerja
```sql
-- Presensi harus dalam jam kerja yang ditentukan
-- Dengan toleransi keterlambatan

SELECT 
    a.id,
    a.teacher_id,
    a.date,
    a.check_in,
    a.status,
    s.value as office_start_time,
    t.value as tolerance_minutes
FROM attendances a
CROSS JOIN settings s
CROSS JOIN settings t
WHERE s.key = 'office_start_time' 
    AND t.key = 'tolerance_minutes'
    AND a.type = 'office'
    AND TIME(a.check_in) > TIME(s.value || '+' || t.value || ' minutes');
```

## Data Integrity Constraints

### 1. Unique Constraints
```sql
-- Email harus unique
ALTER TABLE users ADD CONSTRAINT users_email_unique UNIQUE (email);

-- NIP harus unique
ALTER TABLE teachers ADD CONSTRAINT teachers_nip_unique UNIQUE (nip);

-- User-Teacher relationship harus unique
ALTER TABLE teachers ADD CONSTRAINT teachers_user_id_unique UNIQUE (user_id);

-- Attendance per teacher per date per type harus unique
ALTER TABLE attendances ADD CONSTRAINT attendances_teacher_date_type_unique UNIQUE (teacher_id, date, type);
```

### 2. Check Constraints
```sql
-- Email format validation
ALTER TABLE users ADD CONSTRAINT users_email_check CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Role validation
ALTER TABLE users ADD CONSTRAINT users_role_check CHECK (role IN ('admin', 'teacher'));

-- Teacher status validation
ALTER TABLE teachers ADD CONSTRAINT teachers_status_check CHECK (status IN ('active', 'inactive'));

-- Attendance category validation
ALTER TABLE teachers ADD CONSTRAINT teachers_attendance_category_check CHECK (attendance_category IN ('tetap', 'jadwal'));

-- Attendance status validation
ALTER TABLE attendances ADD CONSTRAINT attendances_status_check CHECK (status IN ('hadir', 'telat', 'izin', 'sakit', 'alpha'));

-- Leave request status validation
ALTER TABLE leave_requests ADD CONSTRAINT leave_requests_status_check CHECK (status IN ('pending', 'approved', 'rejected'));
```

## Trigger untuk Business Logic

### 1. Trigger untuk Update Timestamp
```sql
-- Auto update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to all tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_teachers_updated_at BEFORE UPDATE ON teachers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_attendances_updated_at BEFORE UPDATE ON attendances FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_leave_requests_updated_at BEFORE UPDATE ON leave_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### 2. Trigger untuk Validasi Presensi
```sql
-- Validasi double attendance
CREATE OR REPLACE FUNCTION prevent_double_attendance()
RETURNS TRIGGER AS $$
BEGIN
    DECLARE existing_count INTEGER;
    
    SELECT COUNT(*) INTO existing_count
    FROM attendances
    WHERE teacher_id = NEW.teacher_id 
        AND date = NEW.date 
        AND type = NEW.type;
    
    IF existing_count > 0 THEN
        RAISE EXCEPTION 'Teacher already has attendance record for this date and type';
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER prevent_double_attendance_trigger 
BEFORE INSERT ON attendances 
FOR EACH ROW EXECUTE FUNCTION prevent_double_attendance();
```

## Data Migration Scripts

### 1. Initial Data Setup
```sql
-- Insert default settings
INSERT INTO settings (key, value, type, description, category) VALUES
('school_name', 'SMP Negeri 1', 'text', 'Nama sekolah', 'general'),
('school_latitude', '-7.250445', 'number', 'Latitude lokasi sekolah', 'location'),
('school_longitude', '112.768945', 'number', 'Longitude lokasi sekolah', 'location'),
('attendance_radius', '100', 'number', 'Radius presensi (meter)', 'location'),
('office_start_time', '07:00', 'text', 'Jam masuk kantor', 'time'),
('office_end_time', '15:00', 'text', 'Jam pulang kantor', 'time'),
('tolerance_minutes', '15', 'number', 'Toleransi keterlambatan (menit)', 'time'),
('notification_enabled', 'true', 'boolean', 'Status notifikasi', 'notification');

-- Insert default subjects
INSERT INTO subjects (name, code, description) VALUES
('Matematika', 'MAT', 'Mata pelajaran Matematika'),
('Bahasa Indonesia', 'BIN', 'Mata pelajaran Bahasa Indonesia'),
('Bahasa Inggris', 'ENG', 'Mata pelajaran Bahasa Inggris'),
('Fisika', 'FIS', 'Mata pelajaran Fisika'),
('Kimia', 'KIM', 'Mata pelajaran Kimia'),
('Biologi', 'BIO', 'Mata pelajaran Biologi'),
('Teknik Komputer', 'TKJ', 'Mata pelajaran Teknik Komputer'),
('Akuntansi', 'AKT', 'Mata pelajaran Akuntansi'),
('Ekonomi', 'EKO', 'Mata pelajaran Ekonomi'),
('Geografi', 'GEO', 'Mata pelajaran Geografi'),
('Sejarah', 'SEJ', 'Mata pelajaran Sejarah'),
('PKN', 'PKN', 'Mata pelajaran PKN'),
('Penjaskes', 'PJOK', 'Mata pelajaran Penjaskes'),
('Seni Budaya', 'SB', 'Mata pelajaran Seni Budaya'),
('Bimbingan Konseling', 'BK', 'Mata pelajaran Bimbingan Konseling');

-- Insert default classes
INSERT INTO classes (name, level, major, room, capacity) VALUES
('X IPA 1', 'X', 'IPA', 'Lab IPA 1', 36),
('X IPA 2', 'X', 'IPA', 'Lab IPA 2', 36),
('X IPA 3', 'X', 'IPA', 'Lab IPA 3', 36),
('X IPS 1', 'X', 'IPS', 'Ruang 101', 32),
('X IPS 2', 'X', 'IPS', 'Ruang 102', 32),
('XI IPA 1', 'XI', 'IPA', 'Lab IPA 1', 36),
('XI IPA 2', 'XI', 'IPA', 'Lab IPA 2', 36),
('XI IPS 1', 'XI', 'IPS', 'Ruang 201', 32),
('XI IPS 2', 'XI', 'IPS', 'Ruang 202', 32),
('XII IPA 1', 'XII', 'IPA', 'Lab IPA 1', 36),
('XII IPA 2', 'XII', 'IPA', 'Lab IPA 2', 36),
('XII IPS 1', 'XII', 'IPS', 'Ruang 301', 32),
('XII IPS 2', 'XII', 'IPS', 'Ruang 302', 32);

-- Insert default academic period
INSERT INTO academic_periods (name, semester, start_date, end_date, is_active) VALUES
('2024/2025', 'ganjil', '2024-07-01', '2025-01-31', true);
```

### 2. Data Validation Script
```sql
-- Comprehensive data validation
CREATE OR REPLACE FUNCTION validate_all_data()
RETURNS TABLE(validation_type TEXT, status TEXT, message TEXT) AS $$
BEGIN
    -- Validate user-teacher relationships
    RETURN QUERY
    SELECT 
        'user_teacher_relation' as validation_type,
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END as status,
        'Teachers without valid users: ' || COUNT(*) as message
    FROM teachers t
    LEFT JOIN users u ON t.user_id = u.id
    WHERE u.id IS NULL OR u.role != 'teacher';
    
    -- Validate schedule conflicts
    RETURN QUERY
    SELECT 
        'schedule_conflicts' as validation_type,
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END as status,
        'Schedule conflicts found: ' || COUNT(*) as message
    FROM schedules sch1
    JOIN schedules sch2 ON sch1.teacher_id = sch2.teacher_id 
        AND sch1.day = sch2.day 
        AND sch1.id != sch2.id
        AND (
            (sch1.start_time >= sch2.start_time AND sch1.start_time < sch2.end_time) OR
            (sch1.end_time > sch2.start_time AND sch1.end_time <= sch2.end_time) OR
            (sch1.start_time <= sch2.start_time AND sch1.end_time >= sch2.end_time)
        );
    
    -- Validate double attendance
    RETURN QUERY
    SELECT 
        'double_attendance' as validation_type,
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END as status,
        'Double attendance records: ' || COUNT(*) as message
    FROM (
        SELECT teacher_id, date, type, COUNT(*) as count
        FROM attendances
        GROUP BY teacher_id, date, type
        HAVING COUNT(*) > 1
    ) double_att;
    
    -- Validate leave request approvals
    RETURN QUERY
    SELECT 
        'leave_request_approvals' as validation_type,
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END as status,
        'Leave requests with invalid approvers: ' || COUNT(*) as message
    FROM leave_requests lr
    LEFT JOIN users u ON lr.approved_by = u.id
    WHERE lr.approved_by IS NOT NULL AND (u.id IS NULL OR u.role != 'admin');
    
END;
$$ language 'plpgsql';

-- Run validation
SELECT * FROM validate_all_data();
```

## Performance Monitoring

### 1. Query Performance Analysis
```sql
-- Analyze slow queries
EXPLAIN ANALYZE 
SELECT a.*, t.name as teacher_name, s.name as subject_name, c.name as class_name
FROM attendances a
JOIN teachers t ON a.teacher_id = t.id
LEFT JOIN schedules sch ON a.schedule_id = sch.id
LEFT JOIN subjects s ON sch.subject_id = s.id
LEFT JOIN classes c ON sch.class_id = c.id
WHERE a.date >= '2024-01-01' AND a.date <= '2024-12-31'
ORDER BY a.date DESC;

-- Check index usage
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;
```

### 2. Database Statistics
```sql
-- Table sizes
SELECT 
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Row counts
SELECT 
    'users' as table_name, COUNT(*) as row_count FROM users
UNION ALL
SELECT 
    'teachers' as table_name, COUNT(*) as row_count FROM teachers
UNION ALL
SELECT 
    'attendances' as table_name, COUNT(*) as row_count FROM attendances
UNION ALL
SELECT 
    'schedules' as table_name, COUNT(*) as row_count FROM schedules
UNION ALL
SELECT 
    'leave_requests' as table_name, COUNT(*) as row_count FROM leave_requests;
```

## Backup and Recovery Procedures

### 1. Backup Script
```bash
#!/bin/bash
# Daily backup script
DB_NAME="edupresence"
DB_USER="pocketbase"
BACKUP_DIR="/backup/pocketbase"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR

# Full backup
pg_dump -U $DB_USER -h localhost $DB_NAME > $BACKUP_DIR/full_backup_$DATE.sql

# Compress backup
gzip $BACKUP_DIR/full_backup_$DATE.sql

# Keep last 7 days
find $BACKUP_DIR -name "full_backup_*.sql.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_DIR/full_backup_$DATE.sql.gz"
```

### 2. Recovery Script
```bash
#!/bin/bash
# Recovery script
DB_NAME="edupresence"
DB_USER="pocketbase"
BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file>"
    exit 1
fi

# Drop existing database
dropdb -U $DB_USER $DB_NAME

# Create new database
createdb -U $DB_USER $DB_NAME

# Restore from backup
if [[ $BACKUP_FILE == *.gz ]]; then
    gunzip -c $BACKUP_FILE | psql -U $DB_USER $DB_NAME
else
    psql -U $DB_USER $DB_NAME < $BACKUP_FILE
fi

echo "Recovery completed from: $BACKUP_FILE"
```

## Security Audit

### 1. User Access Audit
```sql
-- Check user permissions
SELECT 
    u.email,
    u.role,
    CASE 
        WHEN u.role = 'admin' THEN 'Full access'
        WHEN u.role = 'teacher' THEN 'Limited to own data'
        ELSE 'Unknown'
    END as access_level
FROM users u
ORDER BY u.role;

-- Check data access patterns
SELECT 
    u.email,
    u.role,
    COUNT(a.id) as attendance_count,
    COUNT(lr.id) as leave_request_count
FROM users u
LEFT JOIN teachers t ON u.id = t.user_id
LEFT JOIN attendances a ON t.id = a.teacher_id
LEFT JOIN leave_requests lr ON t.id = lr.teacher_id
GROUP BY u.id, u.email, u.role
ORDER BY u.role;
```

### 2. Data Privacy Check
```sql
-- Check for sensitive data exposure
SELECT 
    'teachers_phone' as data_type,
    COUNT(*) as record_count,
    'Phone numbers stored' as note
FROM teachers 
WHERE phone IS NOT NULL

UNION ALL

SELECT 
    'teachers_address' as data_type,
    COUNT(*) as record_count,
    'Addresses stored' as note
FROM teachers 
WHERE address IS NOT NULL

UNION ALL

SELECT 
    'attendances_location' as data_type,
    COUNT(*) as record_count,
    'Location data stored' as note
FROM attendances 
WHERE latitude IS NOT NULL AND longitude IS NOT NULL;
```

## Conclusion

Dokumentasi validasi ini menyediakan:
- Validasi relasi antar tabel yang komprehensif
- Business logic validation untuk memastikan integritas data
- Trigger dan constraint untuk otomasi validasi
- Script untuk monitoring performa dan keamanan
- Prosedur backup dan recovery yang terstruktur

Implementasi validasi ini akan memastikan:
- Data consistency dan integrity
- Performance optimal dengan index yang tepat
- Security yang memadai untuk data sensitif
- Maintenance yang mudah dengan monitoring tools

Database ini siap diimplementasikan dengan PocketBase dan akan mendukung semua fitur aplikasi EduPresence dengan andal dan aman.