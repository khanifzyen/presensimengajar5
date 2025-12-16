require('dotenv').config();
const PocketBase = require('pocketbase/cjs');

const pb = new PocketBase(process.env.POCKETBASE_URL);

async function debug() {
    try {
        await pb.collection('_superusers').authWithPassword(
            process.env.POCKETBASE_ADMIN_EMAIL,
            process.env.POCKETBASE_ADMIN_PASSWORD
        );

        console.log('\n--- Attendances Schema ---');
        const collection = await pb.collections.getOne('pbc_1822076064'); // ID from previous list
        console.log(JSON.stringify(collection, null, 2));

    } catch (err) {
        console.error('Error:', err);
    }
}

debug();
