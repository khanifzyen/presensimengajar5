require('dotenv').config();
const PocketBase = require('pocketbase/cjs');

const pb = new PocketBase(process.env.POCKETBASE_URL);

async function seedAdmin() {
    try {
        console.log('Authenticating as admin...');
        await pb.collection('_superusers').authWithPassword(
            process.env.POCKETBASE_ADMIN_EMAIL,
            process.env.POCKETBASE_ADMIN_PASSWORD
        );
        console.log('Authentication successful.');

        console.log('Seeding Admin/TU User...');

        const adminData = {
            email: 'admin.tu@smpn1.sch.id',
            password: 'password123',
            name: 'Admin Tata Usaha',
            role: 'admin'
        };

        try {
            // Check if user exists
            const existingUser = await pb.collection('users').getFirstListItem(`email="${adminData.email}"`).catch(() => null);

            if (existingUser) {
                console.log(`Admin user '${adminData.email}' already exists.`);
            } else {
                // Create User
                const userRecord = await pb.collection('users').create({
                    email: adminData.email,
                    emailVisibility: true,
                    password: adminData.password,
                    passwordConfirm: adminData.password,
                    role: adminData.role,
                    verified: true
                });
                console.log(`Created Admin User: ${adminData.email} (ID: ${userRecord.id})`);
            }

        } catch (err) {
            console.error(`Error creating admin user:`, err.message);
        }

        console.log('Admin seeding completed.');

    } catch (error) {
        console.error('Seeding failed:', error);
    }
}

seedAdmin();
