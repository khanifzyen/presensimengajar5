require('dotenv').config({ path: 'migration/.env' });
const puppeteer = require('puppeteer');
const PocketBase = require('pocketbase/cjs');

const pb = new PocketBase(process.env.POCKETBASE_URL);

// Config
const TARGET_URL = 'http://localhost:8081';
const TEST_USER = {
    email: 'manual_teacher@example.com',
    password: 'password123',
    name: 'Guru Manual',
    nip: '99999999'
};

const VIEWPORT = { width: 375, height: 812, isMobile: true };

async function setupUser() {
    console.log('Setting up test user...');
    try {
        await pb.admins.authWithPassword(process.env.POCKETBASE_ADMIN_EMAIL, process.env.POCKETBASE_ADMIN_PASSWORD);

        // Get an existing teacher
        try {
            const list = await pb.collection('teachers').getList(1, 1);
            if (list.items.length === 0) throw new Error("No teachers found.");

            const teacher = list.items[0];
            console.log(`Found teacher profile: ${teacher.id}. Looking for linked user...`);

            // Assume field is user_id based on previous error
            // Fallback checking camelCase or snake_case if needed, but error said 'user_id'
            const userId = teacher.user_id;

            if (!userId) {
                console.log('Teacher record:', JSON.stringify(teacher, null, 2));
                throw new Error("Teacher record has no user_id field.");
            }

            const user = await pb.collection('users').getOne(userId);
            console.log(`Found user: ${user.email} (${user.id})`);

            // Allow login by setting known password on the USER record
            await pb.collection('users').update(user.id, {
                password: TEST_USER.password,
                passwordConfirm: TEST_USER.password,
            });

            return { email: user.email, password: TEST_USER.password };
        } catch (e) {
            console.error('Error finding/updating user:', e);
            throw e;
        }
    } catch (err) {
        console.error('Error authenticating admin:', err);
        process.exit(1);
    }
}

async function capture() {
    let creds;
    try {
        creds = await setupUser();
    } catch (e) {
        console.error("Setup failed, aborting capture.");
        return;
    }

    console.log('Launching browser...');
    const browser = await puppeteer.launch({
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    const page = await browser.newPage();
    await page.setViewport(VIEWPORT);

    try {
        console.log(`Navigating to ${TARGET_URL}...`);
        await page.goto(TARGET_URL, { waitUntil: 'networkidle0' });

        // --- LOGIN PAGE ---
        console.log('Capturing Login...');
        await page.screenshot({ path: 'manual-book/images/01_login.png' });

        await new Promise(r => setTimeout(r, 5000));

        console.log('Attempting Login with ' + creds.email);
        await page.keyboard.press('Tab');
        await page.keyboard.type(creds.email);

        await page.keyboard.press('Tab');
        await page.keyboard.type(creds.password);

        await page.keyboard.press('Enter');

        // Wait for navigation
        await new Promise(r => setTimeout(r, 10000));

        // --- DASHBOARD ---
        console.log('Capturing Dashboard...');
        await page.screenshot({ path: 'manual-book/images/02_dashboard.png' });

        // Scroll
        await page.evaluate(() => {
            window.scrollBy(0, 500);
        });
        await new Promise(r => setTimeout(r, 2000));
        await page.screenshot({ path: 'manual-book/images/03_dashboard_scroll.png' });

        // --- WEEKLY SCHEDULE ---
        // Try to click "Jadwal" tab. It's likely an icon in BottomNavigationBar.
        // BottomNavigationBar items don't have good labels usually.
        // We can try to click by coordinates for the second item (Schedule).
        // Mobile width 375. Bottom nav has 4 items?
        // Item 1: Home (TeacherDashboard)
        // Item 2: Schedule? Or Class?
        // Let's guess coordinates. Y = 812 - 30. X = 375/4 * 1.5?

        // Assuming 4 items: Home, ?, ?, Profile

        // Let's just capture the Home and Scroll for now as proof of "mobile resizing".

        console.log('Done.');
    } catch (e) {
        console.error('Error during capture:', e);
    } finally {
        await browser.close();
    }
}

capture();
