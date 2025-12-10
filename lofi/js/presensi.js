// js/presensi.js

// Get URL parameters to determine attendance type
const urlParams = new URLSearchParams(window.location.search);
const attendanceType = urlParams.get('type') || 'class'; // 'office' or 'class'
const attendanceAction = urlParams.get('action') || 'checkin'; // 'checkin' or 'checkout'

// Initialize attendance page
document.addEventListener('DOMContentLoaded', function () {
    initializeAttendancePage();

    // Simulate location detection after 2.5 seconds
    setTimeout(() => {
        validateLocation();
    }, 2500);
});

// Initialize attendance page based on type
function initializeAttendancePage() {
    const presensiTitle = document.getElementById('presensiTitle');
    const officeBadge = document.getElementById('officeBadge');
    const classBadge = document.getElementById('classBadge');
    const submitButtonText = document.getElementById('submitButtonText');
    const successMessage = document.getElementById('successMessage');

    if (attendanceType === 'office') {
        // Office attendance mode
        if (presensiTitle) presensiTitle.textContent = attendanceAction === 'checkout' ? 'Check-Out Kantor' : 'Check-In Kantor';
        if (officeBadge) officeBadge.style.display = 'flex';
        if (classBadge) classBadge.style.display = 'none';
        if (submitButtonText) submitButtonText.textContent = attendanceAction === 'checkout' ? 'KIRIM CHECK-OUT' : 'KIRIM CHECK-IN';
        if (successMessage) successMessage.textContent = attendanceAction === 'checkout' ? 'Check-out kantor berhasil!' : 'Check-in kantor berhasil!';
    } else {
        // Class attendance mode
        if (presensiTitle) presensiTitle.textContent = 'Presensi Mengajar';
        if (officeBadge) officeBadge.style.display = 'none';
        if (classBadge) classBadge.style.display = 'flex';
        if (submitButtonText) submitButtonText.textContent = 'KIRIM PRESENSI';
        if (successMessage) successMessage.textContent = 'Presensi mengajar berhasil!';
    }
}

// Validate location and time
function validateLocation() {
    const icon = document.getElementById('status-icon');
    const title = document.getElementById('status-title');
    const desc = document.getElementById('status-desc');
    const btn = document.getElementById('btn-submit');

    // Validate time based on attendance type
    const now = new Date();
    const currentHour = now.getHours();
    const currentMinute = now.getMinutes();
    const totalMinutes = currentHour * 60 + currentMinute;

    let timeValid = true;
    let timeMessage = '';

    if (attendanceType === 'office') {
        if (attendanceAction === 'checkin') {
            // Check-in valid: 06:30 - 07:30
            const minTime = 6 * 60 + 30; // 06:30
            const maxTime = 7 * 60 + 30; // 07:30

            if (totalMinutes < minTime || totalMinutes > maxTime) {
                timeValid = false;
                timeMessage = 'Check-in kantor hanya dapat dilakukan antara pukul 06:30 - 07:30';
            }
        } else {
            // Check-out valid: 14:30 - 16:00
            const minTime = 14 * 60 + 30; // 14:30
            const maxTime = 16 * 60; // 16:00

            if (totalMinutes < minTime || totalMinutes > maxTime) {
                timeValid = false;
                timeMessage = 'Check-out kantor hanya dapat dilakukan antara pukul 14:30 - 16:00';
            }
        }
    } else {
        // Class attendance - validate 15 minutes before/after class time
        // In real app, this would check against actual schedule
        // For demo, we'll allow all times
        timeValid = true;
    }

    if (!timeValid) {
        // Time validation failed
        icon.classList.remove('loading');
        icon.classList.add('error');
        icon.innerHTML = '<i class="fas fa-exclamation-triangle"></i>';

        title.innerText = 'Waktu Tidak Valid';
        title.style.color = 'var(--danger)';
        desc.innerText = timeMessage;

        // Keep button disabled
        btn.disabled = true;
        btn.classList.add('btn-disabled');
        btn.classList.remove('btn-primary');
    } else {
        // Location and time validation successful
        icon.classList.remove('loading');
        icon.classList.add('success');
        icon.innerHTML = '<i class="fas fa-check"></i>';

        title.innerText = 'Anda di dalam Radius';
        title.style.color = 'var(--success)';
        desc.innerText = 'Jarak: 5 meter. Akurasi Tinggi.';

        btn.disabled = false;
        btn.classList.remove('btn-disabled');
        btn.classList.add('btn-primary');
    }
}

// Submit attendance
function submitPresensi() {
    const modal = document.getElementById('success-modal');
    const successTimestamp = document.getElementById('successTimestamp');

    // Update timestamp
    const now = new Date();
    const timeString = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}:${String(now.getSeconds()).padStart(2, '0')}`;
    if (successTimestamp) successTimestamp.textContent = timeString;

    // Show success modal
    modal.classList.remove('hidden');

    // In real app, this would send data to server
    console.log(`Attendance submitted: Type=${attendanceType}, Action=${attendanceAction}, Time=${timeString}`);
}