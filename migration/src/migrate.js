require('dotenv').config();
const PocketBase = require('pocketbase/cjs');
const schema = require('./schema');

const pb = new PocketBase(process.env.POCKETBASE_URL);

// Helper to resolve collection names to IDs in schema options
function resolveSchemaIds(fields, collectionsMap) {
    return fields.map(field => {
        const newField = { ...field };
        // v0.23+: collectionId is at the top level for Relation fields
        if (newField.type === 'relation' && newField.collectionId) {
            const targetName = newField.collectionId;
            if (collectionsMap[targetName]) {
                newField.collectionId = collectionsMap[targetName];
            } else {
                // If it looks like an ID, keep it, otherwise warn
                if (targetName.length !== 15) {
                    console.warn(`Warning: Could not resolve collection ID for '${targetName}' in field '${newField.name}'.`);
                }
            }
        }
        return newField;
    });
}

async function verifyCollection(collectionId, collectionName, expectedFields) {
    try {
        const collection = await pb.collections.getOne(collectionId);
        // In v0.23+, schema is renamed to fields
        const existingFieldNames = (collection.fields || []).map(f => f.name);

        const missingFields = expectedFields.filter(f => !existingFieldNames.includes(f.name));

        if (missingFields.length === 0) {
            console.log(`✅ Verification PASSED for '${collectionName}'`);
            return true;
        } else {
            console.error(`❌ Verification FAILED for '${collectionName}'. Missing fields: ${missingFields.map(f => f.name).join(', ')}`);
            return false;
        }
    } catch (err) {
        console.error(`❌ Verification FAILED for '${collectionName}'. Collection not found (ID: ${collectionId}).`);
        return false;
    }
}

async function migrate() {
    try {
        console.log('Authenticating as admin...');
        await pb.collection('_superusers').authWithPassword(
            process.env.POCKETBASE_ADMIN_EMAIL,
            process.env.POCKETBASE_ADMIN_PASSWORD
        );
        console.log('Authentication successful.');

        // 1. Build initial map of existing collections
        let collections = await pb.collections.getFullList();
        let collectionsMap = {}; // Name -> ID
        collections.forEach(c => collectionsMap[c.name] = c.id);

        // 2. Ensure all collections exist (Create if missing)
        console.log('--- Phase 1: Ensuring collections exist ---');
        for (const collectionDef of schema) {
            if (!collectionsMap[collectionDef.name]) {
                console.log(`Creating collection '${collectionDef.name}'...`);
                try {
                    // Create with empty fields first to establish ID and avoid dependency issues
                    // v0.23+: use 'fields' instead of 'schema'
                    const created = await pb.collections.create({
                        name: collectionDef.name,
                        type: collectionDef.type,
                        fields: []
                    });
                    collectionsMap[collectionDef.name] = created.id;
                    console.log(`Created '${collectionDef.name}' with ID: ${created.id}`);
                } catch (err) {
                    console.error(`Failed to create '${collectionDef.name}':`, err.data || err.message);
                }
            } else {
                console.log(`Collection '${collectionDef.name}' already exists.`);
            }
        }

        // Refresh collections list to ensure map is up to date
        collections = await pb.collections.getFullList();
        collections.forEach(c => collectionsMap[c.name] = c.id);

        // 3. Merge Schema (Add missing fields)
        console.log('--- Phase 2: Merging schema ---');
        for (const collectionDef of schema) {
            const collectionId = collectionsMap[collectionDef.name];
            if (!collectionId) {
                console.error(`Skipping '${collectionDef.name}' because ID could not be found.`);
                continue;
            }

            console.log(`Checking schema for '${collectionDef.name}'...`);

            // Resolve relation IDs in the desired schema
            // Note: In schema.js we now use 'fields' property
            const resolvedDesiredSchema = resolveSchemaIds(collectionDef.fields, collectionsMap);

            try {
                // Fetch current collection state
                const existingCollection = collections.find(c => c.id === collectionId);
                // v0.23+: use 'fields' instead of 'schema'
                const existingFields = existingCollection.fields || [];
                const existingFieldNames = existingFields.map(f => f.name);

                // Start with existing fields
                const finalFields = [...existingFields];
                let hasChanges = false;

                // Add fields from desired schema if they don't exist
                for (const fieldDef of resolvedDesiredSchema) {
                    if (!existingFieldNames.includes(fieldDef.name)) {
                        console.log(`  + Adding missing field '${fieldDef.name}' to '${collectionDef.name}'`);
                        finalFields.push(fieldDef);
                        hasChanges = true;
                    }
                }

                if (hasChanges || (collectionDef.indexes && collectionDef.indexes.length > 0)) {
                    const payload = {
                        fields: finalFields
                    };

                    if (collectionDef.indexes) {
                        payload.indexes = collectionDef.indexes;
                    }

                    await pb.collections.update(collectionId, payload);
                    console.log(`Updated schema (fields & indexes) for '${collectionDef.name}'.`);
                } else {
                    console.log(`No new fields to add for '${collectionDef.name}'.`);
                }

            } catch (err) {
                console.error(`Failed to update schema for '${collectionDef.name}':`);
                console.error(JSON.stringify(err.data, null, 2));
            }
        }

        // 4. Verification
        console.log('--- Phase 3: Verification ---');
        let allPassed = true;
        for (const collectionDef of schema) {
            const collectionId = collectionsMap[collectionDef.name];
            // Pass ID for getOne
            // Note: In schema.js we now use 'fields' property
            const passed = await verifyCollection(collectionId, collectionDef.name, collectionDef.fields);
            if (!passed) allPassed = false;
        }

        if (allPassed) {
            console.log('🎉 Migration and Verification completed successfully!');
        } else {
            console.error('⚠️ Migration completed with verification errors.');
        }

    } catch (error) {
        console.error('Migration failed:', error);
    }
}

migrate();
