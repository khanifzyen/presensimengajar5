require('dotenv').config();
const PocketBase = require('pocketbase/cjs');

const pb = new PocketBase(process.env.POCKETBASE_URL);

async function seed() {
    try {
        console.log('Authenticating as admin...');
        await pb.collection('_superusers').authWithPassword(
            process.env.POCKETBASE_ADMIN_EMAIL,
            process.env.POCKETBASE_ADMIN_PASSWORD
        );
        console.log('Authentication successful.');

        // --- 1. Seed Subjects ---
        console.log('Seeding Subjects...');
        const subjectsData = [
            { name: 'Matematika', code: 'MAT', description: 'Mata pelajaran Matematika' },
            { name: 'Bahasa Indonesia', code: 'IND', description: 'Mata pelajaran Bahasa Indonesia' },
            { name: 'Fisika', code: 'FIS', description: 'Mata pelajaran Fisika' },
            { name: 'Kimia', code: 'KIM', description: 'Mata pelajaran Kimia' },
            { name: 'Teknik Komputer', code: 'TIK', description: 'Mata pelajaran TIK' },
            { name: 'Biologi', code: 'BIO', description: 'Mata pelajaran Biologi' },
            { name: 'Bahasa Inggris', code: 'ING', description: 'Mata pelajaran Bahasa Inggris' }
        ];

        const subjectsMap = {}; // name -> id

        for (const data of subjectsData) {
            try {
                // Check if exists
                const existing = await pb.collection('subjects').getFirstListItem(`name="${data.name}"`).catch(() => null);
                if (existing) {
                    subjectsMap[data.name] = existing.id;
                    console.log(`Subject '${data.name}' already exists.`);
                } else {
                    const record = await pb.collection('subjects').create(data);
                    subjectsMap[data.name] = record.id;
                    console.log(`Created Subject: ${data.name}`);
                }
            } catch (err) {
                console.error(`Error creating subject ${data.name}:`, err.message);
            }
        }

        // --- 2. Seed Classes ---
        console.log('Seeding Classes...');
        const classesData = [
            { name: 'X IPA 1', level: 'X', major: 'IPA', room: 'Ruang 1', capacity: 30 },
            { name: 'X IPA 2', level: 'X', major: 'IPA', room: 'Ruang 2', capacity: 30 },
            { name: 'X IPS 1', level: 'X', major: 'IPS', room: 'Ruang 3', capacity: 30 },
            { name: 'X IPS 2', level: 'X', major: 'IPS', room: 'Ruang 4', capacity: 30 },
            { name: 'XI IPA 1', level: 'XI', major: 'IPA', room: 'Ruang 5', capacity: 30 },
            { name: 'XI IPA 2', level: 'XI', major: 'IPA', room: 'Ruang 6', capacity: 30 },
            { name: 'XI IPS 1', level: 'XI', major: 'IPS', room: 'Ruang 7', capacity: 30 },
            { name: 'XI IPS 2', level: 'XI', major: 'IPS', room: 'Ruang 8', capacity: 30 },
            { name: 'XII IPA 1', level: 'XII', major: 'IPA', room: 'Ruang 9', capacity: 30 },
            { name: 'XII IPA 2', level: 'XII', major: 'IPA', room: 'Ruang 10', capacity: 30 },
            { name: 'XII IPS 1', level: 'XII', major: 'IPS', room: 'Ruang 11', capacity: 30 },
            { name: 'XII IPS 2', level: 'XII', major: 'IPS', room: 'Ruang 12', capacity: 30 },
        ];

        const classesMap = {}; // name -> id

        for (const data of classesData) {
            try {
                const existing = await pb.collection('classes').getFirstListItem(`name="${data.name}"`).catch(() => null);
                if (existing) {
                    classesMap[data.name] = existing.id;
                    console.log(`Class '${data.name}' already exists.`);
                } else {
                    const record = await pb.collection('classes').create(data);
                    classesMap[data.name] = record.id;
                    console.log(`Created Class: ${data.name}`);
                }
            } catch (err) {
                console.error(`Error creating class ${data.name}:`, err.message);
            }
        }

        // --- 3. Seed Academic Periods ---
        console.log('Seeding Academic Periods...');
        const periodsData = [
            { name: '2024/2025 Ganjil', semester: 'ganjil', start_date: '2024-07-15', end_date: '2024-12-20', is_active: true },
            { name: '2024/2025 Genap', semester: 'genap', start_date: '2025-01-06', end_date: '2025-06-20', is_active: false }
        ];

        const periodsMap = {}; // name -> id

        for (const data of periodsData) {
            try {
                const existing = await pb.collection('academic_periods').getFirstListItem(`name="${data.name}"`).catch(() => null);
                if (existing) {
                    periodsMap[data.name] = existing.id;
                    console.log(`Period '${data.name}' already exists.`);
                } else {
                    const record = await pb.collection('academic_periods').create(data);
                    periodsMap[data.name] = record.id;
                    console.log(`Created Period: ${data.name}`);
                }
            } catch (err) {
                console.error(`Error creating period ${data.name}:`, err.message);
            }
        }

        // --- 4. Seed Teachers (and Users) ---
        console.log('Seeding Teachers...');
        // Data from lofi/js/manajemen-guru.js
        const teachersData = [
            {
                name: 'Budi Santoso, S.Pd',
                nip: '198506152008011001',
                subjectName: 'Matematika',
                email: 'budi.santoso@smpn1.sch.id',
                phone: '08123456789',
                status: 'active',
                join_date: '2020-01-15',
                attendance_category: 'tetap',
                position: 'guru'
            },
            {
                name: 'Siti Aminah, S.Pd',
                nip: '198703122009022001',
                subjectName: 'Bahasa Indonesia',
                email: 'siti.aminah@smpn1.sch.id',
                phone: '08234567890',
                status: 'active',
                join_date: '2015-03-20',
                attendance_category: 'jadwal',
                position: 'guru'
            },
            {
                name: 'Ahmad Dahlan, S.Pd',
                nip: '198209101997031001',
                subjectName: 'Fisika',
                email: 'ahmad.dahlan@smpn1.sch.id',
                phone: '08345678901',
                status: 'inactive',
                join_date: '2010-09-10',
                attendance_category: 'tetap',
                position: 'guru'
            },
            {
                name: 'Dewi Sartika, S.Pd',
                nip: '199012152019032001',
                subjectName: 'Kimia',
                email: 'dewi.sartika@smpn1.sch.id',
                phone: '08456789012',
                status: 'active',
                join_date: '2019-12-15',
                attendance_category: 'jadwal',
                position: 'guru'
            },
            {
                name: 'Eko Prasetyo, S.Kom',
                nip: '198805202010011001',
                subjectName: 'Teknik Komputer',
                email: 'eko.prasetyo@smpn1.sch.id',
                phone: '08567890123',
                status: 'active',
                join_date: '2024-05-20',
                attendance_category: 'jadwal',
                position: 'guru'
            },
            // From dashboard-mengajar.js
            {
                name: 'Siti Nurhaliza, S.Pd',
                nip: '199501012020012001', // Dummy NIP
                subjectName: 'Matematika',
                email: 'siti.nurhaliza@smpn1.sch.id',
                phone: '08111222333',
                status: 'active',
                join_date: '2021-01-01',
                attendance_category: 'jadwal',
                position: 'guru'
            }
        ];

        const teachersMap = {}; // name -> id

        for (const data of teachersData) {
            try {
                // 1. Create User
                let userId;
                const existingUser = await pb.collection('users').getFirstListItem(`email="${data.email}"`).catch(() => null);

                if (existingUser) {
                    userId = existingUser.id;
                    console.log(`User '${data.email}' already exists.`);
                } else {
                    const userRecord = await pb.collection('users').create({
                        email: data.email,
                        emailVisibility: true,
                        password: 'password123',
                        passwordConfirm: 'password123',
                        role: 'teacher',
                        verified: true
                    });
                    userId = userRecord.id;
                    console.log(`Created User: ${data.email}`);
                }

                // 2. Create Teacher
                const existingTeacher = await pb.collection('teachers').getFirstListItem(`nip="${data.nip}"`).catch(() => null);
                if (existingTeacher) {
                    teachersMap[data.name] = existingTeacher.id;
                    console.log(`Teacher '${data.name}' already exists.`);
                } else {
                    const teacherRecord = await pb.collection('teachers').create({
                        user_id: userId,
                        nip: data.nip,
                        name: data.name,
                        phone: data.phone,
                        subject_id: subjectsMap[data.subjectName],
                        position: data.position,
                        attendance_category: data.attendance_category,
                        status: data.status,
                        join_date: data.join_date
                    });
                    teachersMap[data.name] = teacherRecord.id;
                    console.log(`Created Teacher: ${data.name}`);
                }
            } catch (err) {
                console.error(`Error creating teacher ${data.name}:`, err.message);
            }
        }

        // --- 5. Seed Schedules ---
        console.log('Seeding Schedules...');
        // Data from lofi/js/dashboard-mengajar.js (for Siti Nurhaliza)
        // Note: The lofi data has class names like "Matematika Wajib - XII IPA 1"
        // We need to parse this or map it manually.
        const activePeriodId = periodsMap['2024/2025 Ganjil'];
        const teacherId = teachersMap['Siti Nurhaliza, S.Pd'];
        const subjectId = subjectsMap['Matematika'];

        if (activePeriodId && teacherId && subjectId) {
            const schedulesData = [
                // Senin
                { day: 'senin', start_time: '07:00', end_time: '08:30', className: 'XII IPA 1', room: 'Lab Matematika' },
                { day: 'senin', start_time: '09:00', end_time: '10:30', className: 'XII IPA 2', room: 'Ruang 12' },
                // Selasa
                { day: 'selasa', start_time: '07:00', end_time: '08:30', className: 'XII IPS 1', room: 'Ruang 15' },
                { day: 'selasa', start_time: '09:00', end_time: '10:30', className: 'XII IPS 2', room: 'Ruang 16' },
                // Rabu
                { day: 'rabu', start_time: '07:00', end_time: '08:30', className: 'X IPA 1', room: 'Ruang 3' },
                { day: 'rabu', start_time: '09:00', end_time: '10:30', className: 'X IPA 2', room: 'Ruang 4' },
                { day: 'rabu', start_time: '11:00', end_time: '12:30', className: 'XII IPA 1', room: 'Lab Matematika' },
                // Kamis
                { day: 'kamis', start_time: '07:00', end_time: '08:30', className: 'X IPS 1', room: 'Ruang 5' },
                { day: 'kamis', start_time: '09:00', end_time: '10:30', className: 'X IPS 2', room: 'Ruang 6' },
                // Jumat
                { day: 'jumat', start_time: '07:00', end_time: '08:30', className: 'XI IPS 1', room: 'Ruang 13' },
                { day: 'jumat', start_time: '09:00', end_time: '10:30', className: 'XI IPS 2', room: 'Ruang 14' },
                { day: 'jumat', start_time: '11:00', end_time: '12:30', className: 'XII IPA 2', room: 'Lab Matematika' },
            ];

            for (const sched of schedulesData) {
                try {
                    const classId = classesMap[sched.className];
                    if (!classId) {
                        console.warn(`Class '${sched.className}' not found for schedule.`);
                        continue;
                    }

                    // Check for existing schedule (simple check)
                    const existing = await pb.collection('schedules').getFirstListItem(`
                        teacher_id="${teacherId}" && 
                        day="${sched.day}" && 
                        start_time="${sched.start_time}"
                    `).catch(() => null);

                    if (existing) {
                        console.log(`Schedule for ${sched.day} ${sched.start_time} already exists.`);
                    } else {
                        await pb.collection('schedules').create({
                            teacher_id: teacherId,
                            subject_id: subjectId,
                            class_id: classId,
                            period_id: activePeriodId,
                            day: sched.day,
                            start_time: sched.start_time,
                            end_time: sched.end_time,
                            room: sched.room
                        });
                        console.log(`Created Schedule: ${sched.day} ${sched.start_time} - ${sched.className}`);
                    }

                } catch (err) {
                    console.error(`Error creating schedule:`, err.message);
                }
            }
        } else {
            console.error('Skipping schedules: Missing dependencies (Period, Teacher, or Subject).');
        }

        console.log('Seeding completed.');

    } catch (error) {
        console.error('Seeding failed:', error);
    }
}

seed();
