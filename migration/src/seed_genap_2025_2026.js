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

        // Create or Update 2025/2026 Genap
        let activePeriodId;
        const targetPeriodName = '2025/2026 Genap';
        const existingTarget = allPeriods.find(p => p.name === targetPeriodName);

        const periodData = {
            name: targetPeriodName,
            semester: 'genap',
            start_date: '2026-01-01 00:00:00',
            end_date: '2026-06-30 23:59:59',
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
        const teachers = await pb.collection('teachers').getFullList();
        const subjects = await pb.collection('subjects').getFullList();
        const classes = await pb.collection('classes').getFullList();

        console.log(`Found ${teachers.length} teachers, ${subjects.length} subjects, ${classes.length} classes.`);

        // --- 3. Seed Schedules for New Period ---
        console.log('\n--- 3. Seed Schedules ---');

        // Define standard time slots
        const timeSlots = [
            { start: '07:00', end: '08:30' },
            { start: '09:00', end: '10:30' },
            { start: '11:00', end: '12:30' },
            { start: '13:00', end: '14:30' }
        ];
        const days = ['senin', 'selasa', 'rabu', 'kamis', 'jumat'];
        const rooms = classes.map(c => `R. ${c.name}`); // Simple room mapping

        const createdSchedules = [];

        for (const teacher of teachers) {
            // Generate 3-5 schedules per teacher
            const numSchedules = Math.floor(Math.random() * 3) + 3;

            for (let i = 0; i < numSchedules; i++) {
                const day = days[Math.floor(Math.random() * days.length)];
                const slot = timeSlots[Math.floor(Math.random() * timeSlots.length)];
                const subject = subjects[Math.floor(Math.random() * subjects.length)];
                const cls = classes[Math.floor(Math.random() * classes.length)];
                const room = rooms[Math.floor(Math.random() * rooms.length)];

                // Check for existing schedule for this teacher at this time (simple duplication check)
                const isDuplicate = createdSchedules.some(s =>
                    s.teacher_id === teacher.id &&
                    s.day === day &&
                    s.start_time === slot.start
                );

                if (isDuplicate) continue;

                // Check existence in DB just in case we re-run
                const existing = await pb.collection('schedules').getList(1, 1, {
                    filter: `period_id="${activePeriodId}" && teacher_id="${teacher.id}" && day="${day}" && start_time="${slot.start}"`
                });

                if (existing.items.length > 0) {
                    createdSchedules.push(existing.items[0]);
                } else {
                    try {
                        const s = await pb.collection('schedules').create({
                            period_id: activePeriodId,
                            teacher_id: teacher.id,
                            subject_id: subject.id,
                            class_id: cls.id,
                            day: day,
                            start_time: slot.start,
                            end_time: slot.end,
                            room: room
                        });
                        createdSchedules.push(s);
                        // console.log(`Created Schedule: ${teacher.name} - ${day} ${slot.start}`);
                    } catch (e) {
                        console.error(`Failed to create schedule for ${teacher.name}: ${e.message}`);
                    }
                }
            }
        }
        console.log(`Total schedules tracked for seeding: ${createdSchedules.length}`);


        // --- 4. Seed Attendance History ---
        console.log('\n--- 4. Seed Attendance History ---');
        // Jan 2 2026 to Jan 14 2026
        const startDate = new Date('2026-01-02');
        const endDate = new Date('2026-01-14');
        const dayNames = ['minggu', 'senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu'];

        let attendanceCount = 0;

        for (let d = new Date(startDate); d <= endDate; d.setDate(d.getDate() + 1)) {
            const currentDayName = dayNames[d.getDay()];
            if (currentDayName === 'minggu') continue;

            const dateStr = d.toISOString().split('T')[0];

            // Get schedules for this day of week
            const dailySchedules = createdSchedules.filter(s => s.day === currentDayName);

            if (dailySchedules.length === 0) continue;

            for (const sched of dailySchedules) {
                // Check if attendance already exists
                const existingAtt = await pb.collection('attendances').getList(1, 1, {
                    filter: `schedule_id="${sched.id}" && date="${dateStr} 00:00:00"`
                });

                if (existingAtt.items.length > 0) continue;

                // Randomize Status
                const rand = Math.random();
                let status = 'hadir';
                let checkIn = null;
                let checkOut = null;
                let notes = '';

                if (rand < 0.75) {
                    // Hadir (On Time)
                    status = 'hadir';
                    checkIn = getRandomTime(sched.start_time, -10);
                    checkOut = getRandomTime(sched.end_time, 5);
                } else if (rand < 0.90) {
                    // Telat
                    status = 'telat';
                    checkIn = getRandomTime(sched.start_time, 30);
                    checkOut = getRandomTime(sched.end_time, 5);
                } else {
                    // Alpha
                    status = 'alpha';
                    checkIn = null;
                    checkOut = null;
                }

                if (status !== 'alpha') {
                    await pb.collection('attendances').create({
                        teacher_id: sched.teacher_id, // Ensure we use the teacher from schedule
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
                } else {
                    await pb.collection('attendances').create({
                        teacher_id: sched.teacher_id,
                        schedule_id: sched.id,
                        date: `${dateStr} 00:00:00`,
                        status: 'alpha',
                        type: 'class',
                        notes: 'Tanpa keterangan'
                    });
                }
                attendanceCount++;
            }
            console.log(`Generated attendance for ${dateStr}`);
        }
        console.log(`Generated ${attendanceCount} total attendance records.`);

        console.log('\n✅ Seeding Genap 2025/2026 Completed Successfully!');

    } catch (err) {
        console.error('Seeding error:', err);
    }
}

seed();
