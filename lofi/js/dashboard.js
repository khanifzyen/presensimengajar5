// js/dashboard.js
document.addEventListener('DOMContentLoaded', function () {
    // Get current teacher data (in real app, this would be from session/storage)
    // For demo purposes, we'll use the first teacher
    const currentTeacher = {
        id: 1,
        name: 'Budi Santoso, S.Pd',
        attendanceCategory: 'tetap' // 'tetap' or 'jadwal'
    };

    // Initialize dashboard based on teacher category
    initializeDashboard(currentTeacher);

    // Update clock every second
    function updateClock() {
        const now = new Date();
        const hours = String(now.getHours()).padStart(2, '0');
        const minutes = String(now.getMinutes()).padStart(2, '0');
        const seconds = String(now.getSeconds()).padStart(2, '0');

        const clockElement = document.getElementById('clock');
        if (clockElement) {
            clockElement.textContent = `${hours}:${minutes}:${seconds}`;
        }

        // Update date
        const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
        const dateElement = document.querySelector('.date');
        if (dateElement) {
            dateElement.textContent = now.toLocaleDateString('id-ID', options);
        }
    }

    // Update clock immediately and then every second
    updateClock();
    setInterval(updateClock, 1000);

    // Handle notification click
    const notifIcon = document.querySelector('.notif-icon');
    if (notifIcon) {
        notifIcon.addEventListener('click', function () {
            // Remove notification dot
            const dotRed = this.querySelector('.dot-red');
            if (dotRed) {
                dotRed.style.display = 'none';
            }

            // Show notification modal or redirect
            alert('Tidak ada notifikasi baru');
        });
    }
});

// Initialize dashboard based on teacher category
function initializeDashboard(teacher) {
    const dashboardTetap = document.getElementById('dashboardTetap');
    const dashboardJadwal = document.getElementById('dashboardJadwal');
    const timeLabel = document.getElementById('timeLabel');
    const timeValue = document.getElementById('timeValue');

    if (teacher.attendanceCategory === 'tetap') {
        // Show office dashboard
        dashboardTetap.style.display = 'block';
        dashboardJadwal.style.display = 'none';

        // Update time card for office
        if (timeLabel) timeLabel.textContent = 'Jam Kerja';
        if (timeValue) timeValue.textContent = '08:00';

        // Initialize office attendance
        initializeOfficeAttendance();
    } else {
        // Show schedule dashboard
        dashboardTetap.style.display = 'none';
        dashboardJadwal.style.display = 'block';

        // Update time card for teaching
        if (timeLabel) timeLabel.textContent = 'Jam Ajar';
        if (timeValue) timeValue.textContent = '05:30';

        // Initialize schedule dashboard
        initializeScheduleDashboard();
    }
}

// Initialize office attendance for guru tetap
function initializeOfficeAttendance() {
    const checkInOffice = document.getElementById('checkInOffice');
    const checkOutOffice = document.getElementById('checkOutOffice');
    const officeStatusHint = document.getElementById('officeStatusHint');
    const attendanceStatus = document.getElementById('attendanceStatus');

    // Check if already checked in (in real app, check from database)
    let isCheckedIn = false;
    let isCheckedOut = false;

    // Handle check-in
    if (checkInOffice) {
        checkInOffice.addEventListener('click', function () {
            const now = new Date();
            const currentTime = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;

            // Validate check-in time (06:30 - 07:30)
            const checkInHour = now.getHours();
            const checkInMinute = now.getMinutes();
            const totalMinutes = checkInHour * 60 + checkInMinute;
            const minTime = 6 * 60 + 30; // 06:30
            const maxTime = 7 * 60 + 30; // 07:30

            if (totalMinutes < minTime || totalMinutes > maxTime) {
                alert('Check-in kantor hanya dapat dilakukan antara pukul 06:30 - 07:30');
                return;
            }

            this.textContent = 'Memproses...';
            this.disabled = true;

            setTimeout(() => {
                isCheckedIn = true;
                checkInOffice.style.display = 'none';
                checkOutOffice.style.display = 'block';
                officeStatusHint.textContent = `Check-in: ${currentTime}`;
                officeStatusHint.style.color = 'var(--success)';

                if (attendanceStatus) {
                    if (totalMinutes <= 7 * 60) { // Before 07:00
                        attendanceStatus.textContent = 'Tepat Waktu';
                        attendanceStatus.className = 'text-success';
                    } else {
                        attendanceStatus.textContent = 'Terlambat';
                        attendanceStatus.className = 'text-warning';
                    }
                }

                // Redirect to presensi page for face verification
                window.location.href = 'presensi.html?type=office';
            }, 1000);
        });
    }

    // Handle check-out
    if (checkOutOffice) {
        checkOutOffice.addEventListener('click', function () {
            const now = new Date();
            const currentTime = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;

            // Validate check-out time (14:30 - 16:00)
            const checkOutHour = now.getHours();
            const checkOutMinute = now.getMinutes();
            const totalMinutes = checkOutHour * 60 + checkOutMinute;
            const minTime = 14 * 60 + 30; // 14:30
            const maxTime = 16 * 60; // 16:00

            if (totalMinutes < minTime || totalMinutes > maxTime) {
                alert('Check-out kantor hanya dapat dilakukan antara pukul 14:30 - 16:00');
                return;
            }

            this.textContent = 'Memproses...';
            this.disabled = true;

            setTimeout(() => {
                isCheckedOut = true;
                checkOutOffice.style.display = 'none';
                officeStatusHint.textContent = `Check-out: ${currentTime}`;
                officeStatusHint.style.color = 'var(--success)';

                if (attendanceStatus) {
                    attendanceStatus.textContent = 'Selesai';
                    attendanceStatus.className = 'text-success';
                }

                // Redirect to presensi page for face verification
                window.location.href = 'presensi.html?type=office&action=checkout';
            }, 1000);
        });
    }
}

// Initialize schedule dashboard for guru jadwal
function initializeScheduleDashboard() {
    const scheduleTimeline = document.getElementById('scheduleTimeline');

    // Sample schedule data (in real app, this would be from database)
    const todaySchedule = [
        {
            time: '07:00',
            className: 'Matematika - XII IPA 1',
            status: 'done',
            checkInTime: '07:05'
        },
        {
            time: '09:00',
            className: 'Fisika - X RPL 2',
            status: 'upcoming',
            checkInTime: null
        },
        {
            time: '13:00',
            className: 'Piket Perpustakaan',
            status: 'upcoming',
            checkInTime: null
        }
    ];

    if (scheduleTimeline) {
        scheduleTimeline.innerHTML = '';

        todaySchedule.forEach((schedule, index) => {
            const timelineItem = document.createElement('div');
            timelineItem.className = `timeline-item ${schedule.status}`;

            let statusBadge = '';
            let actionButton = '';

            if (schedule.status === 'done') {
                statusBadge = `<span class="badge success">Hadir (${schedule.checkInTime})</span>`;
            } else if (schedule.status === 'upcoming') {
                statusBadge = '<span class="badge gray">Menunggu</span>';
                actionButton = '<button class="btn-sm" onclick="checkInClass(this)">Check-In</button>';
            }

            timelineItem.innerHTML = `
                <div class="time">${schedule.time}</div>
                <div class="details">
                    <h4>${schedule.className}</h4>
                    ${statusBadge}
                </div>
                ${actionButton}
            `;

            scheduleTimeline.appendChild(timelineItem);
        });
    }
}

// Handle class check-in
function checkInClass(button) {
    button.textContent = 'Memproses...';
    button.disabled = true;

    setTimeout(() => {
        // Redirect to presensi page for face verification
        window.location.href = 'presensi.html?type=class';
    }, 1000);
}