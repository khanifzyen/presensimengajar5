// js/jadwal-guru.js
document.addEventListener('DOMContentLoaded', function () {
    // Initialize schedule management
    initializeScheduleManagement();

    // Initialize teacher selector
    initializeTeacherSelector();

    // Initialize week navigation
    initializeWeekNavigation();

    // Initialize modal functionality
    initializeScheduleModals();

    // Initialize action buttons
    initializeScheduleActions();

    // Initialize quick actions
    initializeQuickActions();
});

// Schedule data storage (in real app, this would be from a database)
let schedules = [
    {
        id: 1,
        teacherId: 1,
        day: 'senin',
        startTime: '07:00',
        endTime: '08:30',
        subject: 'Matematika',
        classRoom: 'XII IPA 1',
        room: 'Ruang 201'
    },
    {
        id: 2,
        teacherId: 1,
        day: 'senin',
        startTime: '09:00',
        endTime: '10:30',
        subject: 'Matematika',
        classRoom: 'XI IPA 2',
        room: 'Ruang 202'
    },
    {
        id: 3,
        teacherId: 1,
        day: 'selasa',
        startTime: '07:00',
        endTime: '08:30',
        subject: 'Matematika',
        classRoom: 'XII IPS 1',
        room: 'Ruang 203'
    },
    {
        id: 4,
        teacherId: 1,
        day: 'selasa',
        startTime: '13:00',
        endTime: '14:30',
        subject: 'Matematika',
        classRoom: 'X IPA 3',
        room: 'Ruang 204'
    },
    {
        id: 5,
        teacherId: 1,
        day: 'rabu',
        startTime: '08:00',
        endTime: '09:30',
        subject: 'Matematika',
        classRoom: 'XI IPS 2',
        room: 'Ruang 205'
    },
    {
        id: 6,
        teacherId: 1,
        day: 'kamis',
        startTime: '07:00',
        endTime: '08:30',
        subject: 'Matematika',
        classRoom: 'XII IPA 2',
        room: 'Ruang 206'
    },
    {
        id: 7,
        teacherId: 1,
        day: 'kamis',
        startTime: '10:00',
        endTime: '11:30',
        subject: 'Matematika',
        classRoom: 'X IPS 1',
        room: 'Ruang 207'
    },
    {
        id: 8,
        teacherId: 1,
        day: 'jumat',
        startTime: '07:00',
        endTime: '08:30',
        subject: 'Matematika',
        classRoom: 'XI IPA 1',
        room: 'Ruang 208'
    },
    {
        id: 9,
        teacherId: 1,
        day: 'jumat',
        startTime: '13:00',
        endTime: '14:30',
        subject: 'Matematika',
        classRoom: 'XII IPS 2',
        room: 'Ruang 209'
    }
];

// Teacher data
const teachers = [
    { id: 1, name: 'Budi Santoso, S.Pd', subject: 'Matematika' },
    { id: 2, name: 'Siti Aminah, S.Pd', subject: 'Bahasa Indonesia' },
    { id: 3, name: 'Dewi Sartika, S.Pd', subject: 'Kimia' },
    { id: 4, name: 'Eko Prasetyo, S.Kom', subject: 'Teknik Komputer' },
    { id: 5, name: 'Ahmad Fauzi, S.Pd', subject: 'Fisika' }
];

let currentTeacherId = 1;
let currentWeekOffset = 0;
let currentEditId = null;
let currentEditDay = null;

// Initialize schedule management
function initializeScheduleManagement() {
    // Get teacher ID from URL parameter if available
    const urlParams = new URLSearchParams(window.location.search);
    const teacherId = urlParams.get('teacher');
    if (teacherId) {
        currentTeacherId = parseInt(teacherId);
        document.getElementById('selectTeacher').value = teacherId;
    }

    updateScheduleDisplay();
}

// Initialize teacher selector
function initializeTeacherSelector() {
    const teacherSelect = document.getElementById('selectTeacher');

    // Populate teacher options
    teachers.forEach(teacher => {
        const option = document.createElement('option');
        option.value = teacher.id;
        option.textContent = `${teacher.name} - ${teacher.subject}`;
        teacherSelect.appendChild(option);
    });

    // Handle teacher selection change
    teacherSelect.addEventListener('change', function () {
        currentTeacherId = parseInt(this.value) || 1;
        updateScheduleDisplay();
    });
}

// Initialize week navigation
function initializeWeekNavigation() {
    const prevWeek = document.getElementById('prevWeek');
    const nextWeek = document.getElementById('nextWeek');

    prevWeek.addEventListener('click', function () {
        currentWeekOffset--;
        updateWeekDisplay();
        updateScheduleDisplay();
    });

    nextWeek.addEventListener('click', function () {
        currentWeekOffset++;
        updateWeekDisplay();
        updateScheduleDisplay();
    });

    // Initialize week display
    updateWeekDisplay();
}

// Update week display
function updateWeekDisplay() {
    const weekRange = document.getElementById('weekRange');
    const today = new Date();
    const currentDay = today.getDay();

    // Calculate start of current week (Monday)
    const startOfWeek = new Date(today);
    startOfWeek.setDate(today.getDate() - currentDay + 1 + (currentWeekOffset * 7));

    // Calculate end of current week (Saturday)
    const endOfWeek = new Date(startOfWeek);
    endOfWeek.setDate(startOfWeek.getDate() + 5);

    const options = { weekday: 'long', day: 'numeric', month: 'short' };
    const startStr = startOfWeek.toLocaleDateString('id-ID', options);
    const endStr = endOfWeek.toLocaleDateString('id-ID', options);

    weekRange.textContent = `${startStr} - ${endStr} ${startOfWeek.getFullYear()}`;
}

// Update schedule display
function updateScheduleDisplay() {
    const teacherSchedules = schedules.filter(s => s.teacherId === currentTeacherId);

    // Update statistics
    updateScheduleStatistics(teacherSchedules);

    // Update schedule display for each day
    const days = ['senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu'];

    days.forEach(day => {
        updateDaySchedule(day, teacherSchedules);
    });
}

// Update schedule statistics
function updateScheduleStatistics(teacherSchedules) {
    const totalHours = teacherSchedules.reduce((total, schedule) => {
        const start = new Date(`2000-01-01T${schedule.startTime}`);
        const end = new Date(`2000-01-01T${schedule.endTime}`);
        return total + (end - start) / (1000 * 60 * 60); // Convert to hours
    }, 0);

    const totalClasses = teacherSchedules.length;
    const uniqueDays = [...new Set(teacherSchedules.map(s => s.day))].length;

    document.getElementById('totalHours').textContent = totalHours.toFixed(1);
    document.getElementById('totalClasses').textContent = totalClasses;
    document.getElementById('totalDays').textContent = uniqueDays;
}

// Update day schedule
function updateDaySchedule(day, teacherSchedules) {
    const daySchedules = teacherSchedules.filter(s => s.day === day);
    const scheduleDay = document.querySelector(`.schedule-day:has(.day-name:contains("${getDayName(day)}"))`);

    // Find the schedule day container
    const dayContainers = document.querySelectorAll('.schedule-day');
    let dayContainer = null;

    dayContainers.forEach(container => {
        const dayNameElement = container.querySelector('.day-name');
        if (dayNameElement && dayNameElement.textContent.toLowerCase() === getDayName(day).toLowerCase()) {
            dayContainer = container;
        }
    });

    if (!dayContainer) return;

    // Remove existing schedule rows (except add button)
    const existingRows = dayContainer.querySelectorAll('.schedule-row');
    existingRows.forEach(row => row.remove());

    // Remove no schedule message if exists
    const noSchedule = dayContainer.querySelector('.no-schedule');
    if (noSchedule) {
        noSchedule.remove();
    }

    if (daySchedules.length === 0) {
        // Add no schedule message
        const noScheduleDiv = document.createElement('div');
        noScheduleDiv.className = 'no-schedule';
        noScheduleDiv.innerHTML = `
            <i class="fas fa-calendar-times"></i>
            <p>Belum ada jadwal</p>
        `;

        const addButton = dayContainer.querySelector('.add-schedule-row');
        dayContainer.insertBefore(noScheduleDiv, addButton);
    } else {
        // Add schedule rows
        daySchedules.sort((a, b) => a.startTime.localeCompare(b.startTime));

        daySchedules.forEach(schedule => {
            const scheduleRow = document.createElement('div');
            scheduleRow.className = 'schedule-row';
            scheduleRow.dataset.id = schedule.id;

            scheduleRow.innerHTML = `
                <div class="time-slot">${schedule.startTime} - ${schedule.endTime}</div>
                <div class="class-info">
                    <span class="class-name">${schedule.subject}</span>
                    <span class="class-room">${schedule.classRoom}</span>
                </div>
                <div class="schedule-actions">
                    <button class="action-btn edit" title="Edit" data-id="${schedule.id}" data-day="${day}">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="action-btn delete" title="Hapus" data-id="${schedule.id}" data-day="${day}">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            `;

            const addButton = dayContainer.querySelector('.add-schedule-row');
            dayContainer.insertBefore(scheduleRow, addButton);
        });
    }
}

// Get day name in Indonesian
function getDayName(day) {
    const dayNames = {
        'senin': 'Senin',
        'selasa': 'Selasa',
        'rabu': 'Rabu',
        'kamis': 'Kamis',
        'jumat': 'Jumat',
        'sabtu': 'Sabtu'
    };
    return dayNames[day] || day;
}

// Initialize schedule modals
function initializeScheduleModals() {
    const scheduleModal = document.getElementById('scheduleModal');
    const copyModal = document.getElementById('copyModal');
    const closeModal = document.getElementById('closeModal');
    const cancelBtn = document.getElementById('cancelBtn');
    const closeCopyModal = document.getElementById('closeCopyModal');
    const cancelCopyBtn = document.getElementById('cancelCopyBtn');
    const scheduleForm = document.getElementById('scheduleForm');
    const confirmCopyBtn = document.getElementById('confirmCopyBtn');

    // Handle add schedule buttons
    document.addEventListener('click', function (e) {
        if (e.target.closest('.add-schedule-btn')) {
            currentEditId = null;
            currentEditDay = e.target.closest('.add-schedule-btn').dataset.day;
            document.getElementById('modalTitle').textContent = 'Tambah Jadwal';
            document.getElementById('scheduleDay').value = currentEditDay;
            scheduleForm.reset();
            scheduleModal.classList.add('active');
        }
    });

    // Close modals
    closeModal.addEventListener('click', function () {
        scheduleModal.classList.remove('active');
    });

    cancelBtn.addEventListener('click', function () {
        scheduleModal.classList.remove('active');
    });

    closeCopyModal.addEventListener('click', function () {
        copyModal.classList.remove('active');
    });

    cancelCopyBtn.addEventListener('click', function () {
        copyModal.classList.remove('active');
    });

    // Handle schedule form submission
    scheduleForm.addEventListener('submit', function (e) {
        e.preventDefault();

        const formData = {
            teacherId: currentTeacherId,
            day: document.getElementById('scheduleDay').value,
            startTime: document.getElementById('startTime').value,
            endTime: document.getElementById('endTime').value,
            subject: document.getElementById('subject').value,
            classRoom: document.getElementById('classRoom').value,
            room: document.getElementById('room').value
        };

        if (currentEditId) {
            // Update existing schedule
            const index = schedules.findIndex(s => s.id === currentEditId);
            if (index !== -1) {
                schedules[index] = { ...schedules[index], ...formData };
            }
        } else {
            // Add new schedule
            const newSchedule = {
                id: Math.max(...schedules.map(s => s.id)) + 1,
                ...formData
            };
            schedules.push(newSchedule);
        }

        updateScheduleDisplay();
        scheduleModal.classList.remove('active');

        // Show success message
        showNotification(currentEditId ? 'Jadwal berhasil diperbarui' : 'Jadwal berhasil ditambahkan');
    });

    // Handle copy schedule
    confirmCopyBtn.addEventListener('click', function () {
        const targetTeacherId = parseInt(document.getElementById('copyTeacherSelect').value);
        const overwriteExisting = document.getElementById('overwriteExisting').checked;

        if (targetTeacherId) {
            const teacherSchedules = schedules.filter(s => s.teacherId === currentTeacherId);

            // Remove existing schedules for target teacher if overwrite is checked
            if (overwriteExisting) {
                schedules = schedules.filter(s => s.teacherId !== targetTeacherId);
            }

            // Copy schedules to target teacher
            teacherSchedules.forEach(schedule => {
                const newSchedule = {
                    ...schedule,
                    id: Math.max(...schedules.map(s => s.id)) + 1,
                    teacherId: targetTeacherId
                };
                schedules.push(newSchedule);
            });

            copyModal.classList.remove('active');
            showNotification('Jadwal berhasil disalin');
        }
    });

    // Close modal when clicking outside
    window.addEventListener('click', function (e) {
        if (e.target === scheduleModal) {
            scheduleModal.classList.remove('active');
        }
        if (e.target === copyModal) {
            copyModal.classList.remove('active');
        }
    });
}

// Initialize schedule actions
function initializeScheduleActions() {
    // Use event delegation for dynamically created buttons
    document.addEventListener('click', function (e) {
        const target = e.target.closest('.action-btn');
        if (!target) return;

        if (target.classList.contains('edit')) {
            const scheduleId = parseInt(target.dataset.id);
            const schedule = schedules.find(s => s.id === scheduleId);

            if (schedule) {
                currentEditId = scheduleId;
                currentEditDay = schedule.day;
                document.getElementById('modalTitle').textContent = 'Edit Jadwal';
                document.getElementById('scheduleDay').value = schedule.day;
                document.getElementById('startTime').value = schedule.startTime;
                document.getElementById('endTime').value = schedule.endTime;
                document.getElementById('subject').value = schedule.subject;
                document.getElementById('classRoom').value = schedule.classRoom;
                document.getElementById('room').value = schedule.room || '';
                document.getElementById('scheduleModal').classList.add('active');
            }
        } else if (target.classList.contains('delete')) {
            const scheduleId = parseInt(target.dataset.id);

            if (confirm('Apakah Anda yakin ingin menghapus jadwal ini?')) {
                schedules = schedules.filter(s => s.id !== scheduleId);
                updateScheduleDisplay();
                showNotification('Jadwal berhasil dihapus');
            }
        }
    });
}

// Initialize quick actions
function initializeQuickActions() {
    const copyScheduleBtn = document.getElementById('copyScheduleBtn');
    const printScheduleBtn = document.getElementById('printScheduleBtn');
    const exportScheduleBtn = document.getElementById('exportScheduleBtn');

    copyScheduleBtn.addEventListener('click', function () {
        document.getElementById('copyModal').classList.add('active');
    });

    printScheduleBtn.addEventListener('click', function () {
        window.print();
        showNotification('Mempersiapkan pencetakan...');
    });

    exportScheduleBtn.addEventListener('click', function () {
        exportScheduleToCSV();
        showNotification('Jadwal berhasil diekspor');
    });
}

// Export schedule to CSV
function exportScheduleToCSV() {
    const teacherSchedules = schedules.filter(s => s.teacherId === currentTeacherId);
    const teacher = teachers.find(t => t.id === currentTeacherId);

    let csv = 'Hari,Waktu Mulai,Waktu Selesai,Mata Pelajaran,Kelas,Ruangan\n';

    teacherSchedules.sort((a, b) => {
        const dayOrder = ['senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu'];
        return dayOrder.indexOf(a.day) - dayOrder.indexOf(b.day) || a.startTime.localeCompare(b.startTime);
    });

    teacherSchedules.forEach(schedule => {
        csv += `${getDayName(schedule.day)},${schedule.startTime},${schedule.endTime},${schedule.subject},${schedule.classRoom},${schedule.room || ''}\n`;
    });

    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `jadwal_${teacher.name.replace(/[^a-zA-Z0-9]/g, '_')}.csv`;
    a.click();
    window.URL.revokeObjectURL(url);
}

// Show notification
function showNotification(message) {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = 'notification';
    notification.textContent = message;
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: var(--success);
        color: white;
        padding: 12px 20px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        z-index: 2000;
        animation: slideInRight 0.3s ease;
    `;

    // Add to document
    document.body.appendChild(notification);

    // Remove after 3 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.3s ease';
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}

// Add CSS for notification animations
const notificationStyles = document.createElement('style');
notificationStyles.textContent = `
    @keyframes slideInRight {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOutRight {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
    
    @media print {
        .bottom-nav, .quick-actions, .teacher-selector, .week-selector, .schedule-actions, .add-schedule-row {
            display: none !important;
        }
        
        .schedule-container {
            padding: 0;
        }
        
        .schedule-day {
            break-inside: avoid;
        }
    }
`;
document.head.appendChild(notificationStyles);