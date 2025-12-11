const PocketBase = require('pocketbase/cjs');

const pb = new PocketBase('https://pb-presensi.pasarjepara.com');

async function checkSchedules() {
    try {
        console.log('Authenticating...');
        const authData = await pb.collection('users').authWithPassword(
            'siti.nurhaliza@smpn1.sch.id',
            'password123'
        );
        console.log('Auth successful.');
        console.log('User ID:', authData.record.id);

        console.log('\nFetching Teacher Profile...');
        const teacher = await pb.collection('teachers').getFirstListItem(`user_id="${authData.record.id}"`);
        console.log('Teacher ID:', teacher.id);
        console.log('Teacher Name:', teacher.name);

        console.log('\n=== Fetching ALL Schedules ===');
        const allSchedules = await pb.collection('schedules').getFullList({
            filter: `teacher_id="${teacher.id}"`,
            expand: 'subject_id,class_id',
            sort: 'day,start_time'
        });

        console.log(`Total schedules: ${allSchedules.length}`);

        // Group by day
        const byDay = {};
        allSchedules.forEach(s => {
            if (!byDay[s.day]) byDay[s.day] = [];
            byDay[s.day].push(s);
        });

        console.log('\n=== Schedules by Day ===');
        Object.keys(byDay).sort().forEach(day => {
            console.log(`\n${day.toUpperCase()}: ${byDay[day].length} schedules`);
            byDay[day].forEach(s => {
                const subject = s.expand?.subject_id?.name || s.subject_id;
                const className = s.expand?.class_id?.name || s.class_id;
                console.log(`  ${s.start_time} - ${s.end_time}: ${subject} - ${className} (${s.room})`);
            });
        });

    } catch (e) {
        console.error('Error:', e);
    }
}

checkSchedules();
