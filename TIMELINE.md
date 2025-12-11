# Project Timeline & Sprint Plan

This document outlines the development timeline for the **Presensi Mengajar App**, translating the `lofi` prototypes into a fully functional React Native Expo application integrated with PocketBase.

## Phase 1: Foundation & Authentication (Sprint 1)
**Goal:** Establish the project structure, navigation, and secure authentication flow.

- [ ] **Project Configuration**
    - [ ] Install dependencies: `nativewind`, `expo-router`, `pocketbase`, `lucide-react-native`, `expo-location`, `expo-camera`.
    - [ ] Configure TailwindCSS (NativeWind).
    - [ ] Setup absolute imports and path aliases.
- [ ] **Authentication**
    - [ ] Implement `AuthContext` for global state management.
    - [ ] **Login Screen** (`login.html`): UI implementation + PocketBase integration.
    - [ ] **Onboarding** (`onboarding.js`): Intro slides for first-time users.
    - [ ] **Splash Screen**: Loading state logic.
- [ ] **Navigation Structure**
    - [ ] Setup File-based routing (Expo Router).
    - [ ] Create Tab Layout (Home, Schedule, History, Profile).
    - [ ] Create Stack Layout for Auth and Detail screens.

## Phase 2: Core Teacher Features (Sprint 2)
**Goal:** Enable teachers to view schedules and perform attendance (the core value proposition).

- [ ] **Teacher Dashboard** (`dashboard-guru.html`, `dashboard-guru-mengajar.html`)
    - [ ] Header with User Info & Notification Icon.
    - [ ] Summary Cards (Total Hours, Attendance Status).
    - [ ] "Teaching Now" / Active Schedule Card.
    - [ ] Recent Activity / Schedule List.
- [ ] **Schedule Management** (`jadwal-guru.html`)
    - [ ] Weekly Calendar View.
    - [ ] Daily Schedule List.
    - [ ] Detail Modal/Screen for Schedule Items.
- [ ] **Attendance Action** (`presensi.html`)
    - [ ] **Location Check**: Integrate `expo-location` to verify radius.
    - [ ] **Face Verification**: Integrate `expo-camera` for photo capture.
    - [ ] **Check-In/Check-Out Logic**: API calls to `attendances` collection.
    - [ ] Success/Failure Feedback UI.

## Phase 3: History, Leaves & Profile (Sprint 3)
**Goal:** Complete the teacher's self-service capabilities.

- [ ] **Attendance History** (`riwayat.html`)
    - [ ] List view of past attendance.
    - [ ] Filtering by Month/Year.
    - [ ] Status indicators (Present, Late, Alpha, etc.).
- [ ] **Leave Management** (`izin.html`)
    - [ ] **Leave Request Form**: Date picker, Type selection, Reason, File Upload (Attachment).
    - [ ] **Leave History**: Tab view for "Form" and "History".
- [ ] **Profile & Settings**
    - [ ] **Profile View** (`profil.html`): Display user details.
    - [ ] **Edit Profile** (`edit-profil.html`): Update phone, address, photo.
    - [ ] **Change Password** (`ubah-kata-sandi.html`).
    - [ ] **Static Pages**: Guide (`panduan.html`), About (`tentang-aplikasi.html`).

## Phase 4: Admin Features (Sprint 4)
**Goal:** Implement administrative control and reporting.

- [ ] **Admin Dashboard** (`dashboard-admin.html`)
    - [ ] Overview stats (Total Teachers, Attendance Rates).
    - [ ] Quick Actions.
- [ ] **Teacher Management** (`manajemen-guru.html`)
    - [ ] List of teachers with search/filter.
    - [ ] Add/Edit Teacher Forms.
    - [ ] Delete Teacher functionality.
- [ ] **Leave Approval** (`approval-izin.html`)
    - [ ] List of pending requests.
    - [ ] Approve/Reject actions with notes.
- [ ] **Reports** (`laporan.html`)
    - [ ] Monthly Attendance Report.
    - [ ] Export options (PDF/Excel - *Mock/Implementation TBD*).
- [ ] **System Settings** (`pengaturan.html`)
    - [ ] Radius & Location Configuration.
    - [ ] Work Hours & Tolerance Settings.
    - [ ] Academic Period Management.

## Phase 5: Polish & Optimization (Sprint 5)
**Goal:** Ensure a smooth, bug-free experience.

- [ ] **UI/UX Polish**
    - [ ] Add loading skeletons/spinners.
    - [ ] Implement pull-to-refresh.
    - [ ] Improve error messages and toast notifications.
- [ ] **Offline Support** (Optional/Basic)
    - [ ] Cache essential data (Schedule, Profile).
- [ ] **Testing**
    - [ ] Manual testing of all flows.
    - [ ] Edge case handling (No location, Camera permission denied).

## Technical Stack & Libraries
- **Framework**: React Native (Expo SDK 50+)
- **Routing**: Expo Router v3
- **Styling**: NativeWind (TailwindCSS)
- **Backend**: PocketBase v0.23+
- **Icons**: Lucide React Native
- **Maps/Location**: `expo-location`
- **Camera**: `expo-camera`
- **Date Handling**: `date-fns`
- **Storage**: `AsyncStorage` (for auth token persistence)
