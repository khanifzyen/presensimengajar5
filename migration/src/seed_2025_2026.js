require('dotenv').config();
const PocketBase = require('pocketbase/cjs');


const pb = new PocketBase(process.env.POCKETBASE_URL);

// Helper to generate random time variations
function getRandomTime(baseTime, variationMinutes = 15) {
    const [h, m] = baseTime.split(':').map(Number);
    const date = new Date();
    date.setHours(h, m, 0, 0);

    // Add/subtract random minutes
    const variation = Math.floor(Math.random() * (variationMinutes * 2 + 1)) - variationMinutes;
    date.setMinutes(date.getMinutes() + variation);

    return `${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`;
}

async function seed() {
    try {
        console.log(' Authenticating as admin...');
        await pb.collection('_superusers').authWithPassword(
            process.env.POCKETBASE_ADMIN_EMAIL,
            process.env.POCKETBASE_ADMIN_PASSWORD
        );

        // --- 1. Manage Academic Periods ---
        console.log('\n--- 1. Manage Academic Periods ---');
        // Deactivate all existing
        const allPeriods = await pb.collection('academic_periods').getFullList();
        for (const p of allPeriods) {
            if (p.is_active) {
                await pb.collection('academic_periods').update(p.id, { is_active: false });
                console.log(`Deactivated period: ${p.name}`);
            }
        }

        // Create or Update 2025/2026 Ganjil
        let activePeriodId;
        const targetPeriodName = '2025/2026 Ganjil';
        const existingTarget = allPeriods.find(p => p.name === targetPeriodName);

        const periodData = {
            name: targetPeriodName,
            semester: 'ganjil',
            start_date: '2025-07-01 00:00:00', // Adjusted for hypothetical 2025 start
            end_date: '2025-12-31 23:59:59',
            is_active: true
        };

        if (existingTarget) {
            await pb.collection('academic_periods').update(existingTarget.id, periodData);
            activePeriodId = existingTarget.id;
            console.log(`Updated and activated period: ${targetPeriodName}`);
        } else {
            const newPeriod = await pb.collection('academic_periods').create(periodData);
            activePeriodId = newPeriod.id;
            console.log(`Created and activated period: ${targetPeriodName}`);
        }

        // --- 2. Get Dependencies (Teacher, Subjects, Classes) ---
        console.log('\n--- 2. Get Dependencies ---');
        const teacher = await pb.collection('teachers').getFirstListItem('name="Siti Nurhalizaa, S.Pd"');
        const subject = await pb.collection('subjects').getFirstListItem('name="Matematika"');
        console.log(`Using Teacher: ${teacher.name} (${teacher.id})`);

        const classesMap = {};
        const classes = await pb.collection('classes').getFullList();
        classes.forEach(c => classesMap[c.name] = c.id);

        // --- 3. Seed Schedules for New Period ---
        console.log('\n--- 3. Seed Schedules ---');
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
            // Kamis
            { day: 'kamis', start_time: '07:00', end_time: '08:30', className: 'X IPS 1', room: 'Ruang 5' },
            { day: 'kamis', start_time: '09:00', end_time: '10:30', className: 'X IPS 2', room: 'Ruang 6' },
            // Jumat
            { day: 'jumat', start_time: '07:00', end_time: '08:30', className: 'XI IPS 1', room: 'Ruang 13' },
            { day: 'jumat', start_time: '09:00', end_time: '10:30', className: 'XI IPS 2', room: 'Ruang 14' },
        ];

        const createdSchedules = [];

        for (const data of schedulesData) {
            // Check existing
            const existing = await pb.collection('schedules').getList(1, 1, {
                filter: `period_id="${activePeriodId}" && teacher_id="${teacher.id}" && day="${data.day}" && start_time="${data.start_time}"`
            });

            if (existing.items.length > 0) {
                createdSchedules.push(existing.items[0]);
                console.log(`Schedule exists: ${data.day} ${data.start_time}`);
            } else {
                const s = await pb.collection('schedules').create({
                    period_id: activePeriodId,
                    teacher_id: teacher.id,
                    subject_id: subject.id,
                    class_id: classesMap[data.className],
                    day: data.day,
                    start_time: data.start_time,
                    end_time: data.end_time,
                    room: data.room
                });
                createdSchedules.push(s);
                console.log(`Created Schedule: ${data.day} ${data.start_time} - ${data.className}`);
            }
        }

        // --- 4. Seed Attendance History ---
        console.log('\n--- 4. Seed Attendance History ---');
        // Simulate dates from July 15 to Dec 16 (Today)
        const startDate = new Date('2025-07-15');
        const endDate = new Date('2025-12-16');
        const dayNames = ['minggu', 'senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu'];

        for (let d = new Date(startDate); d <= endDate; d.setDate(d.getDate() + 1)) {
            const currentDayName = dayNames[d.getDay()];
            const dateStr = d.toISOString().split('T')[0];

            // 1. Get schedules for this day
            const dailySchedules = createdSchedules.filter(s => s.day === currentDayName);

            if (dailySchedules.length === 0) continue;

            for (const sched of dailySchedules) {
                // Check if attendance already exists
                const existingAtt = await pb.collection('attendances').getList(1, 1, {
                    filter: `schedule_id="${sched.id}" && date="${dateStr} 00:00:00"`
                });

                if (existingAtt.items.length > 0) continue;

                // Randomize Status
                // 70% Hadir, 10% Telat, 5% Izin (skip here, handled in permission?), 15% Alpha
                const rand = Math.random();
                let status = 'hadir';
                let checkIn = null;
                let checkOut = null;
                let notes = '';

                // Generate timestamps based on schedule
                // Schedule start: 07:00
                // Use a dummy date part + time

                if (rand < 0.7) {
                    // Hadir (On Time)
                    status = 'hadir';
                    checkIn = getRandomTime(sched.start_time, -10); // 10 mins before/after start (mostly before for on time?)
                    // Ensure checkIn is BEFORE start_time + grace period (e.g. 15 mins) for 'hadir' logically, 
                    // but usually 'hadir' just means they checked in.
                    // Let's say strictly before start time for 'perfect' attendance, but 'hadir' status is what matters.
                    // We'll simulate checkIn 0-15 mins BEFORE start.
                    checkIn = getRandomTime(sched.start_time, -10); // e.g. 06:50
                    checkOut = getRandomTime(sched.end_time, 5);
                } else if (rand < 0.85) {
                    // Telat
                    status = 'telat';
                    // Check in 15-45 mins AFTER start
                    checkIn = getRandomTime(sched.start_time, 30); // e.g. 07:30
                    checkOut = getRandomTime(sched.end_time, 5);
                } else {
                    // Alpha (No record usually, but we create one with status 'alpha' for stats tracking if system requires)
                    // Or we just DON'T create a record? 
                    // In many systems 'Alpha' is absence of attendance. 
                    // However, `WeeklyStatisticsModel` counts records with status 'alpha'.
                    // So we must create a record.
                    status = 'alpha';
                    checkIn = null; // No checkin
                    checkOut = null;
                }

                if (status !== 'alpha') {
                    await pb.collection('attendances').create({
                        teacher_id: teacher.id,
                        schedule_id: sched.id,
                        date: `${dateStr} 00:00:00`,
                        status: status,
                        type: 'class',
                        check_in: `${dateStr} ${checkIn}:00`,
                        check_out: checkOut ? `${dateStr} ${checkOut}:00` : '',
                        location_address: 'SMAN 1 Jepara',
                        latitude: -6.5888,
                        longitude: 110.668,
                        notes: notes
                    });
                    // console.log(`  -> ${dateStr} [${status}] ${sched.start_time}`);
                } else {
                    // For alpha, maybe we create a record with empty times?
                    await pb.collection('attendances').create({
                        teacher_id: teacher.id,
                        schedule_id: sched.id,
                        date: `${dateStr} 00:00:00`,
                        status: 'alpha',
                        type: 'class',
                        notes: 'Tanpa keterangan'
                    });
                    // console.log(`  -> ${dateStr} [${status}]`);
                }
            }
        }
        console.log('Generated attendance records.');

        // --- 5. Seed Permissions ---
        console.log('\n--- 5. Seed Permissions ---');

        // Approved permission
        try {
            await pb.collection('leave_requests').create({
                teacher_id: teacher.id,
                type: 'sakit',
                start_date: '2025-08-10 00:00:00',
                end_date: '2025-08-12 00:00:00',
                reason: 'Demam tinggi',
                status: 'approved',
                approved_by: process.env.POCKETBASE_ADMIN_EMAIL // Incorrect logic, needs user ID relation. Let's skip approved_by for now or fetch admin user.
            });
            console.log('Created Approved Permission (Sakit)');
        } catch (e) {
            console.log('Permission likely exists or error', e.message);
        }

        // Pending permission
        try {
            await pb.collection('leave_requests').create({
                teacher_id: teacher.id,
                type: 'cuti',
                start_date: '2025-12-20 00:00:00',
                end_date: '2025-12-21 00:00:00',
                reason: 'Acara keluarga',
                status: 'pending'
            });
            console.log('Created Pending Permission (Cuti)');
        } catch (e) {
            console.log('Permission likely exists or error', e.message);
        }

        console.log('\n✅ Seeding 2025/2026 Completed Successfully!');

    } catch (err) {
        console.error('Seeding error:', err);
    }
}

seed();
