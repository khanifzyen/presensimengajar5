// js/dashboard-admin.js
document.addEventListener('DOMContentLoaded', function () {
    // Initialize real-time clock
    updateClock();
    setInterval(updateClock, 1000);

    // Initialize live monitoring simulation
    initializeLiveMonitoring();

    // Add click handlers for navigation


    // Add alert functionality
    initializeAlerts();
});

// Update real-time clock
function updateClock() {
    const now = new Date();
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const seconds = String(now.getSeconds()).padStart(2, '0');

    // Update clock in header if exists
    const clockElements = document.querySelectorAll('.live-clock');
    clockElements.forEach(element => {
        element.textContent = `${hours}:${minutes}:${seconds}`;
    });
}

// Initialize live monitoring simulation
function initializeLiveMonitoring() {
    // Simulate real-time updates
    setInterval(() => {
        updateRandomTeacherStatus();
    }, 5000); // Update every 5 seconds
}

// Update random teacher status for demo
function updateRandomTeacherStatus() {
    const teachers = document.querySelectorAll('.teacher-row');
    if (teachers.length === 0) return;

    // Randomly update one teacher's status
    const randomIndex = Math.floor(Math.random() * teachers.length);
    const teacher = teachers[randomIndex];
    const statusPill = teacher.querySelector('.status-pill');

    if (statusPill) {
        const statuses = ['present', 'late', 'absent', 'permit'];
        const statusClasses = ['present', 'late', 'absent', 'permit'];
        const statusTexts = {
            'present': 'Hadir',
            'late': 'Telat',
            'absent': 'Alpha',
            'permit': 'Sakit'
        };

        // Random status change (30% chance)
        if (Math.random() > 0.7) {
            const newStatus = Math.floor(Math.random() * statuses.length);
            const newStatusClass = statusClasses[newStatus];

            // Remove all status classes
            statuses.forEach(status => statusPill.classList.remove(status));

            // Add new status class
            statusPill.classList.add(newStatusClass);
            statusPill.textContent = statusTexts[statuses[newStatus]];

            // Add animation
            statusPill.style.animation = 'pulse 0.5s ease-in-out';
        }
    }
}



// Initialize alerts
function initializeAlerts() {
    const alertBox = document.querySelector('.alert-box');
    const alertButton = alertBox?.querySelector('.btn-xs');

    if (alertButton) {
        alertButton.addEventListener('click', function () {
            // Simulate navigation to approval page
            console.log('Navigating to approval page');
            alert('Menuju halaman persetujuan izin');

            // Add loading state
            this.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Memuat...';
            this.disabled = true;

            setTimeout(() => {
                this.innerHTML = 'Lihat';
                this.disabled = false;
            }, 1500);
        });
    }
}



// Add CSS for live monitoring
const style = document.createElement('style');
style.textContent = `
    .status-pill {
        transition: all 0.3s ease;
    }
    
    @keyframes pulse {
        0% {
            transform: scale(1);
        }
        50% {
            transform: scale(1.05);
        }
        100% {
            transform: scale(1);
        }
    }
    
    .btn-xs:disabled {
        opacity: 0.6;
        cursor: not-allowed;
    }
`;
document.head.appendChild(style);

// Add live clock elements dynamically
function addLiveClocks() {
    const teacherRows = document.querySelectorAll('.teacher-info');
    teacherRows.forEach((row, index) => {
        if (index < 2) { // Only add to first 2 teachers for demo
            const clock = document.createElement('div');
            clock.className = 'live-clock';
            clock.style.cssText = `
                font-size: 10px;
                color: #64748b;
                margin-top: 5px;
                font-family: monospace;
            `;
            clock.textContent = new Date().toLocaleTimeString('id-ID', {
                hour: '2-digit',
                minute: '2-digit'
            });
            row.appendChild(clock);
        }
    });
}

// Call this after DOM is ready
setTimeout(addLiveClocks, 100);