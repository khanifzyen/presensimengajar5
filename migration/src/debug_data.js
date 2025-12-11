const PocketBase = require('pocketbase/cjs');

const pb = new PocketBase('https://pb-presensi.pasarjepara.com');

async function debug() {
    try {
        console.log('Authenticating...');
        const authData = await pb.collection('users').authWithPassword(
            'siti.nurhaliza@smpn1.sch.id',
            'password123'
        );
        console.log('Auth successful.');
        console.log('User ID:', authData.record.id);
        console.log('User Email:', authData.record.email);

        console.log('\nFetching Teacher Profile...');
        try {
            const teacher = await pb.collection('teachers').getFirstListItem(`user_id="${authData.record.id}"`);
            console.log('Teacher Found:', teacher);

            console.log('\nFetching Schedules for Teacher ID:', teacher.id);
            const schedules = await pb.collection('schedules').getFullList({
                filter: `teacher_id="${teacher.id}"`,
                expand: 'subject_id,class_id'
            });
            console.log(`Found ${schedules.length} schedules.`);
            if (schedules.length > 0) {
                console.log('First Schedule:', schedules[0]);
            }

        } catch (e) {
            console.error('Error fetching teacher:', e.message);
            // Try to list all teachers to see if there's any mismatch
            console.log('\nListing all teachers to check user_id mapping...');
            const allTeachers = await pb.collection('teachers').getFullList();
            allTeachers.forEach(t => {
                console.log(`Teacher: ${t.name}, ID: ${t.id}, UserID: ${t.user_id}`);
            });
        }

    } catch (e) {
        console.error('Debug failed:', e);
    }
}

debug();
