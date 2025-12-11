require('dotenv').config();
const PocketBase = require('pocketbase/cjs');

const pb = new PocketBase(process.env.POCKETBASE_URL);

async function seedActivity() {
    try {
        console.log('Authenticating as admin...');
        await pb.collection('_superusers').authWithPassword(
            process.env.POCKETBASE_ADMIN_EMAIL,
            process.env.POCKETBASE_ADMIN_PASSWORD
        );
        console.log('Authentication successful.');

        // --- 1. Seed Settings ---
        console.log('Seeding Settings...');
        const settingsData = [
            { key: 'school_name', value: 'SMP Negeri 1 Jepara', type: 'text', category: 'general', description: 'Nama Sekolah' },
            { key: 'school_address', value: 'Jl. Jend. Sudirman No. 1', type: 'text', category: 'general', description: 'Alamat Sekolah' },
            { key: 'location_lat', value: '-6.5888', type: 'number', category: 'location', description: 'Latitude Lokasi Sekolah' },
            { key: 'location_lng', value: '110.6688', type: 'number', category: 'location', description: 'Longitude Lokasi Sekolah' },
            { key: 'location_radius', value: '100', type: 'number', category: 'location', description: 'Radius Presensi (meter)' },
            { key: 'work_start', value: '07:00', type: 'text', category: 'time', description: 'Jam Masuk Kantor' },
            { key: 'work_end', value: '15:30', type: 'text', category: 'time', description: 'Jam Pulang Kantor' },
            { key: 'tolerance_minutes', value: '15', type: 'number', category: 'time', description: 'Toleransi Keterlambatan (menit)' },
        ];

        for (const data of settingsData) {
            try {
                const existing = await pb.collection('settings').getFirstListItem(`key="${data.key}"`).catch(() => null);
                if (existing) {
                    console.log(`Setting '${data.key}' already exists.`);
                } else {
                    await pb.collection('settings').create(data);
                    console.log(`Created Setting: ${data.key}`);
                }
            } catch (err) {
                console.error(`Error creating setting ${data.key}:`, err.message);
            }
        }

        // --- Helper: Fetch Teachers ---
        const teachers = await pb.collection('teachers').getFullList();
        const teachersMap = {}; // name -> id
        teachers.forEach(t => teachersMap[t.name] = t.id);

        const users = await pb.collection('users').getFullList();
        const adminUser = users.find(u => u.role === 'admin') || users[0]; // Fallback to first user

        // --- 2. Seed Leave Requests ---
        console.log('Seeding Leave Requests...');

        const leaveRequestsData = [
            {
                teacherName: 'Dewi Sartika, S.Pd',
                type: 'sakit',
                start_date: new Date().toISOString().split('T')[0], // Today
                end_date: new Date().toISOString().split('T')[0],
                reason: 'Demam tinggi dan flu',
                status: 'pending'
            },
            {
                teacherName: 'Ahmad Dahlan, S.Pd',
                type: 'cuti',
                start_date: '2025-12-01',
                end_date: '2025-12-03',
                reason: 'Acara keluarga',
                status: 'approved',
                approved_by: adminUser ? adminUser.id : null,
                approved_at: '2025-11-30 10:00:00'
            }
        ];

        for (const data of leaveRequestsData) {
            const teacherId = teachersMap[data.teacherName];
            if (!teacherId) {
                console.warn(`Teacher '${data.teacherName}' not found for leave request.`);
                continue;
            }

            try {
                // Simple check to avoid duplicates (same teacher, same start date)
                const existing = await pb.collection('leave_requests').getFirstListItem(`
                    teacher_id="${teacherId}" && start_date="${data.start_date}"
                `).catch(() => null);

                if (existing) {
                    console.log(`Leave request for ${data.teacherName} on ${data.start_date} already exists.`);
                } else {
                    await pb.collection('leave_requests').create({
                        teacher_id: teacherId,
                        type: data.type,
                        start_date: data.start_date,
                        end_date: data.end_date,
                        reason: data.reason,
                        status: data.status,
                        approved_by: data.approved_by,
                        approved_at: data.approved_at
                    });
                    console.log(`Created Leave Request for: ${data.teacherName}`);
                }
            } catch (err) {
                console.error(`Error creating leave request for ${data.teacherName}:`, err.message);
            }
        }

        // --- 3. Seed Attendances ---
        console.log('Seeding Attendances...');

        // 3a. Office Attendance
        const officeAttendanceData = [
            {
                teacherName: 'Budi Santoso, S.Pd',
                date: new Date().toISOString().split('T')[0], // Today
                type: 'office',
                check_in: new Date().toISOString().replace('T', ' ').split('.')[0], // Now
                status: 'hadir',
                location_address: 'Kantor Guru',
                latitude: -6.5888,
                longitude: 110.6688
            },
            {
                teacherName: 'Siti Aminah, S.Pd',
                date: new Date().toISOString().split('T')[0],
                type: 'office',
                check_in: new Date(Date.now() - 3600000).toISOString().replace('T', ' ').split('.')[0], // 1 hour ago
                status: 'telat',
                notes: 'Ban bocor',
                location_address: 'Gerbang Sekolah',
                latitude: -6.5889,
                longitude: 110.6689
            }
        ];

        for (const data of officeAttendanceData) {
            const teacherId = teachersMap[data.teacherName];
            if (!teacherId) continue;

            try {
                const existing = await pb.collection('attendances').getFirstListItem(`
                    teacher_id="${teacherId}" && date="${data.date}" && type="office"
                `).catch(() => null);

                if (existing) {
                    console.log(`Office attendance for ${data.teacherName} today already exists.`);
                } else {
                    await pb.collection('attendances').create({
                        teacher_id: teacherId,
                        date: data.date,
                        type: data.type,
                        check_in: data.check_in,
                        status: data.status,
                        location_address: data.location_address,
                        latitude: data.latitude,
                        longitude: data.longitude,
                        notes: data.notes
                    });
                    console.log(`Created Office Attendance for: ${data.teacherName}`);
                }
            } catch (err) {
                console.error(`Error creating office attendance for ${data.teacherName}:`, err.message);
            }
        }

        // 3b. Class Attendance (for Siti Nurhaliza)
        // We need to fetch her schedules first
        const sitiId = teachersMap['Siti Nurhaliza, S.Pd'];
        if (sitiId) {
            const schedules = await pb.collection('schedules').getFullList({
                filter: `teacher_id="${sitiId}"`
            });

            if (schedules.length > 0) {
                // Pick the first schedule to create attendance for
                const sched = schedules[0];
                const today = new Date().toISOString().split('T')[0];

                try {
                    const existing = await pb.collection('attendances').getFirstListItem(`
                        teacher_id="${sitiId}" && schedule_id="${sched.id}" && date="${today}"
                    `).catch(() => null);

                    if (existing) {
                        console.log(`Class attendance for Siti Nurhaliza (Schedule ${sched.id}) already exists.`);
                    } else {
                        await pb.collection('attendances').create({
                            teacher_id: sitiId,
                            schedule_id: sched.id,
                            date: today,
                            type: 'class',
                            check_in: new Date().toISOString().replace('T', ' ').split('.')[0],
                            status: 'hadir',
                            location_address: sched.room || 'Kelas',
                            latitude: -6.5888,
                            longitude: 110.6688
                        });
                        console.log(`Created Class Attendance for: Siti Nurhaliza (Schedule ${sched.id})`);
                    }
                } catch (err) {
                    console.error(`Error creating class attendance:`, err.message);
                }
            }
        }

        console.log('Activity seeding completed.');

    } catch (error) {
        console.error('Seeding failed:', error);
    }
}

seedActivity();
