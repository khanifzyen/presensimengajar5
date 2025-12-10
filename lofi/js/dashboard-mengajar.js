// js/dashboard-mengajar.js
document.addEventListener('DOMContentLoaded', function () {
    // Get current teacher data (in real app, this would be from session/storage)
    // For demo purposes, we'll use the first teacher
    const currentTeacher = {
        id: 2,
        name: 'Siti Nurhaliza, S.Pd',
        attendanceCategory: 'jadwal' // 'tetap' or 'jadwal'
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

    // Initialize tab functionality
    initializeTabs();
});

// Initialize dashboard based on teacher category
function initializeDashboard(teacher) {
    // Show schedule dashboard
    if (teacher.attendanceCategory === 'jadwal') {
        // Update time card for teaching
        const timeLabel = document.getElementById('timeLabel');
        const timeValue = document.getElementById('timeValue');

        if (timeLabel) timeLabel.textContent = 'Jam Ajar';
        if (timeValue) timeValue.textContent = '05:30';

        // Initialize schedule dashboard
        initializeScheduleDashboard();
        initializeCurrentClass();
    }
}

// Initialize current class status
function initializeCurrentClass() {
    const checkOutClass = document.getElementById('checkOutClass');
    const classStatusHint = document.getElementById('classStatusHint');
    const attendanceStatus = document.getElementById('attendanceStatus');

    // Handle check-out from class
    if (checkOutClass) {
        checkOutClass.addEventListener('click', function () {
            const now = new Date();
            const currentTime = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;

            this.textContent = 'Memproses...';
            this.disabled = true;

            setTimeout(() => {
                checkOutClass.style.display = 'none';
                classStatusHint.textContent = `Check-out: ${currentTime}`;
                classStatusHint.style.color = 'var(--success)';

                if (attendanceStatus) {
                    attendanceStatus.textContent = 'Selesai';
                    attendanceStatus.className = 'text-success';
                }

                // Redirect to presensi page for face verification
                window.location.href = 'presensi.html?type=class&action=checkout';
            }, 1000);
        });
    }
}

// Initialize schedule dashboard
function initializeScheduleDashboard() {
    // This function is called to initialize schedule dashboard
    // The actual tab initialization is done in initializeTabs()
}

// Initialize tab functionality
function initializeTabs() {
    const scheduleTabs = document.querySelector('.schedule-tabs');
    const scheduleTimeline = document.getElementById('scheduleTimeline');

    // Clear existing tabs
    scheduleTabs.innerHTML = '';

    // Get days with schedules
    const daysWithSchedule = Object.keys(scheduleData).filter(day =>
        scheduleData[day] && scheduleData[day].length > 0
    );

    // Create tabs dynamically
    daysWithSchedule.forEach((day, index) => {
        const tabButton = document.createElement('button');
        tabButton.className = 'tab-btn';
        if (index === 0) tabButton.classList.add('active');
        tabButton.setAttribute('data-day', day);
        tabButton.textContent = day.charAt(0).toUpperCase() + day.slice(1);

        tabButton.addEventListener('click', function () {
            // Remove active class from all tabs
            document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));

            // Add active class to clicked tab
            this.classList.add('active');

            // Get the day data
            const selectedDay = this.getAttribute('data-day');

            // Load schedule for selected day
            loadScheduleForDay(selectedDay, scheduleTimeline);
        });

        scheduleTabs.appendChild(tabButton);
    });

    // Load schedule for the first day by default
    if (daysWithSchedule.length > 0) {
        loadScheduleForDay(daysWithSchedule[0], scheduleTimeline);
    }
}

// Sample schedule data for each day (in real app, this would be from database)
const scheduleData = {
    senin: [
        {
            startTime: '07:00',
            endTime: '08:30',
            className: 'Matematika Wajib - XII IPA 1',
            status: 'done',
            checkInTime: '06:55',
            checkOutTime: '08:30',
            room: 'Lab Matematika'
        },
        {
            startTime: '09:00',
            endTime: '10:30',
            className: 'Matematika Wajib - XII IPA 2',
            status: 'done',
            checkInTime: '08:55',
            checkOutTime: '10:30',
            room: 'Ruang 12'
        },
        {
            startTime: '11:00',
            endTime: '12:30',
            className: 'Kalkulus - XI IPA 1',
            status: 'upcoming',
            checkInTime: null,
            checkOutTime: null,
            room: 'Ruang 8'
        },
        {
            startTime: '13:00',
            endTime: '14:30',
            className: 'Piket Guru',
            status: 'upcoming',
            checkInTime: null,
            checkOutTime: null,
            room: 'Ruang Guru'
        }
    ],
    selasa: [
        {
            startTime: '07:00',
            endTime: '08:30',
            className: 'Matematika Wajib - XII IPS 1',
            status: 'upcoming',
            checkInTime: null,
            checkOutTime: null,
            room: 'Ruang 15'
        },
        {
            startTime: '09:00',
            endTime: '10:30',
            className: 'Matematika Wajib - XII IPS 2',
            status: 'upcoming',
            checkInTime: null,
            checkOutTime: null,
            room: 'Ruang 16'
        },
        {
            startTime: '11:00',
            endTime: '12:30',
            className: 'Aljabar Linear - XI IPA 2',
            status: 'upcoming',
            checkInTime: null,
            checkOutTime: null,
            room: 'Lab Komputer'
        }
    ],
    rabu: [
        {
            startTime: '07:00',
            endTime: '08:30',
            className: 'Matematika Wajib - X IPA 1',
            status: 'upcoming',
            checkInTime: null,
            checkOutTime: null,
            room: 'Ruang 3'
        },
        {
            startTime: '09:00',
            endTime: '10:30',
            className: 'Matematika Wajib - X IPA 2',
            status: 'upcoming',
            checkInTime: null,
            checkOutTime: null,
            room: 'Ruang 4'
        },
        {
            startTime: '11:00',
            endTime: '12:30',
            className: 'Statistika - XII IPA 1',
            status: 'upcoming',
            checkInTime: null,
            checkOutTime: null,
            room: 'Lab Matematika'
        },
        {
            startTime: '13:00',
            endTime: '14:30',
            className: 'Bimbingan Konseling',
            status: 'upcoming',
            checkInTime: null,
            checkOutTime: null,
            room: 'Ruang BK'
        }
    ],
    kamis: [
        {
            startTime: '07:00',
            endTime: '08:30',
            className: 'Matematika Wajib - X IPS 1',
            status: 'upcoming',
            checkInTime: null,
            checkOutTime: null,
            room: 'Ruang 5'
        },
        {
            startTime: '09:00',
            endTime: '10:30',
            className: 'Matematika Wajib - X IPS 2',
            status: 'upcoming',
            checkInTime: null,
            checkOutTime: null,
            room: 'Ruang 6'
        },
        {
            startTime: '11:00',
            endTime: '12:30',
            className: 'Geometri - XI IPA 1',
            status: 'upcoming',
            checkInTime: null,
            checkOutTime: null,
            room: 'Ruang 9'
        }
    ],
    jumat: [
        {
            startTime: '07:00',
            endTime: '08:30',
            className: 'Matematika Wajib - XI IPS 1',
            status: 'upcoming',
            checkInTime: null,
            checkOutTime: null,
            room: 'Ruang 13'
        },
        {
            startTime: '09:00',
            endTime: '10:30',
            className: 'Matematika Wajib - XI IPS 2',
            status: 'upcoming',
            checkInTime: null,
            checkOutTime: null,
            room: 'Ruang 14'
        },
        {
            startTime: '11:00',
            endTime: '12:30',
            className: 'Trigonometri - XII IPA 2',
            status: 'upcoming',
            checkInTime: null,
            checkOutTime: null,
            room: 'Lab Matematika'
        },
        {
            startTime: '13:00',
            endTime: '14:30',
            className: 'Rapat Guru',
            status: 'upcoming',
            checkInTime: null,
            checkOutTime: null,
            room: 'Aula'
        }
    ],
    // Example of a day with no schedule (won't be displayed as a tab)
    sabtu: []
};

// Load schedule for specific day
function loadScheduleForDay(day, scheduleTimeline) {
    if (scheduleTimeline && scheduleData[day]) {
        scheduleTimeline.innerHTML = '';

        scheduleData[day].forEach((schedule, index) => {
            const timelineItem = document.createElement('div');
            timelineItem.className = `timeline-item ${schedule.status}`;

            let statusBadge = '';
            let actionButton = '';
            let roomInfo = schedule.room ? `<p class="room-info"><i class="fas fa-map-marker-alt"></i> ${schedule.room}</p>` : '';
            let timeInfo = '';

            if (schedule.status === 'done') {
                statusBadge = `<span class="badge success">Hadir (${schedule.checkInTime} - ${schedule.checkOutTime})</span>`;
            } else if (schedule.status === 'ongoing') {
                statusBadge = `<span class="badge warning">Sedang Berlangsung</span>`;
                timeInfo = `<p class="time-info"><i class="fas fa-clock"></i> Masuk: ${schedule.checkInTime}</p>`;
                actionButton = '<button class="btn-sm" onclick="checkOutClass(this)">Check-Out</button>';
            } else if (schedule.status === 'upcoming') {
                statusBadge = '<span class="badge gray">Menunggu</span>';
                actionButton = '<button class="btn-sm" onclick="checkInClass(this)">Check-In</button>';
            }

            // Create time range display
            let timeRange = '';
            if (schedule.startTime && schedule.endTime) {
                timeRange = `
                    <div class="time">
                        <div class="time-start">${schedule.startTime}</div>
                        <div class="time-separator">-</div>
                        <div class="time-end">${schedule.endTime}</div>
                    </div>
                `;
            } else {
                timeRange = `<div class="time">${schedule.time}</div>`;
            }

            timelineItem.innerHTML = `
                ${timeRange}
                <div class="details">
                    <h4>${schedule.className}</h4>
                    ${roomInfo}
                    ${timeInfo}
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

// Handle class check-out
function checkOutClass(button) {
    button.textContent = 'Memproses...';
    button.disabled = true;

    setTimeout(() => {
        // Redirect to presensi page for face verification
        window.location.href = 'presensi.html?type=class&action=checkout';
    }, 1000);
}