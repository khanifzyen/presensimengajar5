require('dotenv').config();
const PocketBase = require('pocketbase/cjs');
const schema = require('./schema');

const pb = new PocketBase(process.env.POCKETBASE_URL);

async function migrate() {
    try {
        console.log('Authenticating as admin...');
        await pb.admins.authWithPassword(
            process.env.POCKETBASE_ADMIN_EMAIL,
            process.env.POCKETBASE_ADMIN_PASSWORD
        );
        console.log('Authentication successful.');

        // Get existing collections
        const collections = await pb.collections.getFullList();
        const existingCollectionNames = collections.map(c => c.name);

        for (const collectionDef of schema) {
            if (existingCollectionNames.includes(collectionDef.name)) {
                console.log(`Collection ${collectionDef.name} already exists. Skipping creation (Update logic can be added here).`);
                // In a real migration, we might want to diff and update the schema
                // For now, we assume if it exists, it's fine, or we could update it
                // const existing = collections.find(c => c.name === collectionDef.name);
                // await pb.collections.update(existing.id, collectionDef);
            } else {
                console.log(`Creating collection ${collectionDef.name}...`);
                try {
                    await pb.collections.create(collectionDef);
                    console.log(`Collection ${collectionDef.name} created successfully.`);
                } catch (err) {
                    console.error(`Failed to create collection ${collectionDef.name}:`, err.data || err.message);
                    // If relation dependency fails (e.g. teachers needs users), we might need to order them correctly
                    // schema.js is ordered, so it should be fine if dependencies come first
                }
            }
        }

        console.log('Migration completed.');
    } catch (error) {
        console.error('Migration failed:', error);
    }
}

migrate();
