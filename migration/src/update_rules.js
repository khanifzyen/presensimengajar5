require('dotenv').config();
const PocketBase = require('pocketbase/cjs');

const pb = new PocketBase(process.env.POCKETBASE_URL);

async function updateRules() {
    try {
        console.log('Authenticating as admin...');
        await pb.collection('_superusers').authWithPassword(
            process.env.POCKETBASE_ADMIN_EMAIL,
            process.env.POCKETBASE_ADMIN_PASSWORD
        );
        console.log('Authentication successful.');

        const rules = {
            teachers: {
                listRule: '@request.auth.id != ""', // Allow all auth users to list (needed for admin too, and simpler for now)
                viewRule: '@request.auth.id != ""',
                updateRule: 'user_id = @request.auth.id',
            },
            schedules: {
                listRule: '@request.auth.id != ""',
                viewRule: '@request.auth.id != ""',
            },
            subjects: {
                listRule: '@request.auth.id != ""',
                viewRule: '@request.auth.id != ""',
            },
            classes: {
                listRule: '@request.auth.id != ""',
                viewRule: '@request.auth.id != ""',
            },
            academic_periods: {
                listRule: '@request.auth.id != ""',
                viewRule: '@request.auth.id != ""',
            },
            attendances: {
                listRule: 'teacher_id.user_id = @request.auth.id',
                viewRule: 'teacher_id.user_id = @request.auth.id',
                createRule: '@request.auth.id != ""',
                updateRule: 'teacher_id.user_id = @request.auth.id',
            },
            leave_requests: {
                listRule: 'teacher_id.user_id = @request.auth.id',
                viewRule: 'teacher_id.user_id = @request.auth.id',
                createRule: '@request.auth.id != ""',
                updateRule: 'teacher_id.user_id = @request.auth.id',
            },
            notifications: {
                listRule: 'user_id = @request.auth.id',
                viewRule: 'user_id = @request.auth.id',
                updateRule: 'user_id = @request.auth.id',
            },
            settings: {
                listRule: '@request.auth.id != ""',
                viewRule: '@request.auth.id != ""',
            }
        };

        for (const [collectionName, collectionRules] of Object.entries(rules)) {
            try {
                const collection = await pb.collections.getFirstListItem(`name="${collectionName}"`);
                await pb.collections.update(collection.id, collectionRules);
                console.log(`Updated rules for '${collectionName}'`);
            } catch (e) {
                console.error(`Failed to update rules for '${collectionName}':`, e.message);
            }
        }

    } catch (e) {
        console.error('Update rules failed:', e);
    }
}

updateRules();
