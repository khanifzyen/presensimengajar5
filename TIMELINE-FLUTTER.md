# Timeline Implementation Plan - Presensi Mengajar (Flutter)

This document outlines the implementation plan for the Presensi Mengajar application using Flutter, adhering to the Repository Pattern and using `flutter_bloc` for state management. The backend is PocketBase.

## 1. Project Setup & Architecture

- [ ] **Initialize Flutter Project**
    - Create new Flutter project.
    - Configure `pubspec.yaml` with dependencies:
        - `flutter_bloc`
        - `equatable`
        - `pocketbase`
        - `get_it` (Dependency Injection)
        - `go_router` (Navigation)
        - `shared_preferences` (Local storage)
        - `geolocator` (GPS)
        - `camera` or `image_picker` (Photo)
        - `google_maps_flutter` or `flutter_map` (Maps)
        - `intl` (Date formatting)
- [ ] **Folder Structure Setup**
    - `lib/core`: Constants, Utils, Errors, Theme.
    - `lib/data`:
        - `models`: Data models (fromJson/toJson).
        - `datasources`: Remote (PocketBase) and Local data sources.
        - `repositories`: Implementation of repositories.
    - `lib/domain`:
        - `entities`: Domain entities (if strictly separating, otherwise use models).
        - `repositories`: Abstract repository definitions.
    - `lib/presentation`:
        - `blocs`: Global and feature-specific Blocs.
        - `pages`: Screens/Views.
        - `widgets`: Reusable widgets.
    - `lib/routes`: App routing configuration.

## 2. Data Layer Implementation (PocketBase Schema)

Based on `migration/src/schema.js`.

- [x] **Models Creation**
    - `UserModel` (users collection)
    - `TeacherModel` (teachers collection)
    - `SubjectModel` (subjects collection)
    - `ClassModel` (classes collection)
    - `AcademicPeriodModel` (academic_periods collection)
    - `ScheduleModel` (schedules collection)
    - `AttendanceModel` (attendances collection)
    - `LeaveRequestModel` (leave_requests collection)
    - `NotificationModel` (notifications collection)
    - `SettingModel` (settings collection)

- [x] **Repository Interfaces & Implementations**
    - `AuthRepository`: Login, Logout, Check Auth Status.
    - `TeacherRepository`: Get profile, update profile.
    - `ScheduleRepository`: Get daily/weekly schedules.
    - `AttendanceRepository`: Check-in, Check-out, Get History.
    - `LeaveRepository`: Request leave, Get leave history, Approve/Reject (Admin).
    - `MasterDataRepository`: Manage subjects, classes, periods (Admin).

## 3. State Management (Blocs)

- [x] **AuthBloc**: Manage authentication state (Authenticated, Unauthenticated, Loading).
- [x] **UserBloc**: Manage current user profile data.
- [x] **ScheduleBloc**: Fetch and filter schedules.
- [x] **AttendanceBloc**: Handle check-in/out logic, location validation.
- [x] **LeaveBloc**: Manage leave requests and status.
- [x] **NotificationBloc**: Fetch notifications.

## 4. Feature Implementation (Based on `lofi` prototypes)

### Phase 1: Authentication & Base UI
- [x] **Login Screen** (`login.html`)
    - UI Implementation.
    - Integrate `AuthBloc`.
- [x] **Main Layout & Navigation**
    - Bottom Navigation for Teachers (Home, Schedule, History, Profile).
    - Drawer/Sidebar for Admin.

### Phase 2: Dashboard & Profile
- [x] **Teacher Dashboard** (`dashboard-guru.html`)
    - Summary widgets (Attendance stats, Next class).
- [x] **Admin Dashboard** (`dashboard-admin.html`)
    - Overview stats.
- [x] **Profile & Settings** (`profil.html`, `edit-profil.html`, `ubah-kata-sandi.html`)
    - View and Edit Profile.
    - Change Password.

### Phase 3: Schedule & Teaching
- [ ] **Schedule View** (`jadwal-guru.html`)
    - List/Grid view of classes.
- [ ] **Teaching Dashboard** (`dashboard-guru-mengajar.html`)
    - Specific view for active class session.

### Phase 4: Attendance (Core Feature)
- [ ] **Attendance Screen** (`presensi.html`)
    - Geolocation check.
    - Camera integration for selfie.
    - Submit Check-in/Check-out.
- [ ] **Attendance History** (`riwayat.html`)
    - List of past attendance logs.
    - Filter by date/month.

### Phase 5: Leave Management (Izin)
- [ ] **Leave Request** (`izin.html`)
    - Form to request leave (Date, Reason, Attachment).
- [ ] **Leave Approval** (`approval-izin.html`)
    - Admin view to approve/reject requests.

### Phase 6: Admin Features & Reports
- [ ] **Teacher Management** (`manajemen-guru.html`)
    - CRUD Teachers.
- [ ] **Reports** (`laporan.html`)
    - Generate/View attendance reports.

### Phase 7: Polish & Info
- [ ] **Static Pages** (`panduan.html`, `tentang-aplikasi.html`)
- [ ] **Notifications**
    - Display in-app notifications.

## 5. Testing & Deployment
- [ ] Unit Tests for Blocs and Repositories.
- [ ] Widget Tests for critical screens.
- [ ] Integration Tests.
- [ ] Build for Android/iOS.
