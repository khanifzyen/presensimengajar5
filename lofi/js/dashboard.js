// js/dashboard.js
document.addEventListener('DOMContentLoaded', function () {
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

    // Handle check-in/check-out buttons
    const checkButtons = document.querySelectorAll('.btn-sm, .btn-danger-outline');
    checkButtons.forEach(button => {
        button.addEventListener('click', function () {
            const buttonText = this.textContent.trim();

            if (buttonText.includes('Check-In')) {
                // Simulate check-in process
                this.textContent = 'Memproses...';
                this.disabled = true;

                setTimeout(() => {
                    // Redirect to presensi page
                    window.location.href = 'presensi.html';
                }, 1000);
            } else if (buttonText.includes('CHECK-OUT')) {
                // Simulate check-out process
                this.textContent = 'Memproses...';
                this.disabled = true;

                setTimeout(() => {
                    // Update UI to show completed
                    this.textContent = 'Selesai';
                    this.classList.remove('btn-danger-outline');
                    this.classList.add('btn-success');

                    // Update status hint
                    const statusHint = document.querySelector('.status-hint');
                    if (statusHint) {
                        statusHint.textContent = 'Kelas selesai';
                        statusHint.style.color = 'var(--success)';
                    }
                }, 1000);
            }
        });
    });
});