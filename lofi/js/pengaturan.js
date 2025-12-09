// js/pengaturan.js
document.addEventListener('DOMContentLoaded', function () {
    // Initialize tab navigation
    initializeTabs();

    // Initialize radius settings
    initializeRadiusSettings();

    // Initialize tolerance settings
    initializeToleranceSettings();

    // Initialize schedule management
    initializeScheduleManagement();

    // Initialize curriculum management
    initializeCurriculumManagement();

    // Initialize modals
    initializeModals();
});

// Tab Navigation
function initializeTabs() {
    const tabButtons = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');

    tabButtons.forEach(button => {
        button.addEventListener('click', () => {
            const targetTab = button.getAttribute('data-tab');

            // Remove active class from all tabs and contents
            tabButtons.forEach(btn => btn.classList.remove('active'));
            tabContents.forEach(content => content.classList.remove('active'));

            // Add active class to clicked tab and corresponding content
            button.classList.add('active');
            document.getElementById(`${targetTab}-tab`).classList.add('active');
        });
    });
}

// Radius Settings
function initializeRadiusSettings() {
    const radiusInput = document.getElementById('radiusValue');
    const radiusPreview = document.getElementById('radiusPreview');
    const updateLocationBtn = document.getElementById('updateLocationBtn');

    // Update radius preview when input changes
    if (radiusInput) {
        radiusInput.addEventListener('input', () => {
            updateRadiusPreview();
        });
    }

    // Initialize radius preview
    updateRadiusPreview();

    // Handle update location button
    if (updateLocationBtn) {
        updateLocationBtn.addEventListener('click', () => {
            if (navigator.geolocation) {
                updateLocationBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Mendapatkan lokasi...';
                updateLocationBtn.disabled = true;

                navigator.geolocation.getCurrentPosition(
                    (position) => {
                        const { latitude, longitude } = position.coords;
                        document.getElementById('latitude').value = latitude.toFixed(6);
                        document.getElementById('longitude').value = longitude.toFixed(6);

                        updateLocationBtn.innerHTML = '<i class="fas fa-location-crosshairs"></i> Perbarui Lokasi';
                        updateLocationBtn.disabled = false;

                        showNotification('Lokasi berhasil diperbarui', 'success');
                    },
                    (error) => {
                        updateLocationBtn.innerHTML = '<i class="fas fa-location-crosshairs"></i> Perbarui Lokasi';
                        updateLocationBtn.disabled = false;

                        showNotification('Gagal mendapatkan lokasi: ' + error.message, 'error');
                    }
                );
            } else {
                showNotification('Geolocation tidak didukung browser ini', 'error');
            }
        });
    }
}

function updateRadiusPreview() {
    const radiusInput = document.getElementById('radiusValue');
    const radiusPreview = document.getElementById('radiusPreview');

    if (radiusInput && radiusPreview) {
        const radius = radiusInput.value;
        const scale = Math.min(radius / 100, 2); // Scale the circle based on radius
        radiusPreview.style.width = `${100 * scale}px`;
        radiusPreview.style.height = `${100 * scale}px`;
    }
}

// Tolerance Settings
function initializeToleranceSettings() {
    const jamMasuk = document.getElementById('jamMasuk');
    const jamPulang = document.getElementById('jamPulang');
    const toleransiValue = document.getElementById('toleransiValue');

    // Update preview when values change
    if (jamMasuk) jamMasuk.addEventListener('change', updateTolerancePreview);
    if (jamPulang) jamPulang.addEventListener('change', updateTolerancePreview);
    if (toleransiValue) toleransiValue.addEventListener('input', updateTolerancePreview);

    // Initialize preview
    updateTolerancePreview();
}

function updateTolerancePreview() {
    const jamMasuk = document.getElementById('jamMasuk');
    const jamPulang = document.getElementById('jamPulang');
    const toleransiValue = document.getElementById('toleransiValue');
    const previewMasuk = document.getElementById('previewMasuk');
    const previewToleransi = document.getElementById('previewToleransi');
    const previewPulang = document.getElementById('previewPulang');

    if (jamMasuk && previewMasuk) {
        previewMasuk.textContent = jamMasuk.value;
    }

    if (jamMasuk && toleransiValue && previewToleransi) {
        const masukTime = new Date(`2000-01-01T${jamMasuk.value}:00`);
        const toleransiMinutes = parseInt(toleransiValue.value) || 0;
        masukTime.setMinutes(masukTime.getMinutes() + toleransiMinutes);

        const hours = String(masukTime.getHours()).padStart(2, '0');
        const minutes = String(masukTime.getMinutes()).padStart(2, '0');
        previewToleransi.textContent = `${hours}:${minutes}`;
    }

    if (jamPulang && previewPulang) {
        previewPulang.textContent = jamPulang.value;
    }
}

// Schedule Management
function initializeScheduleManagement() {
    const addScheduleBtn = document.getElementById('addScheduleBtn');
    const scheduleForm = document.getElementById('scheduleForm');
    const filterPeriod = document.getElementById('filterPeriod');
    const filterTeacher = document.getElementById('filterTeacher');
    const filterDay = document.getElementById('filterDay');

    // Add schedule button
    if (addScheduleBtn) {
        addScheduleBtn.addEventListener('click', () => {
            openScheduleModal();
        });
    }

    // Schedule form submission
    if (scheduleForm) {
        scheduleForm.addEventListener('submit', (e) => {
            e.preventDefault();
            saveSchedule();
        });
    }

    // Filter functionality
    if (filterPeriod) {
        filterPeriod.addEventListener('change', filterSchedules);
    }

    if (filterTeacher) {
        filterTeacher.addEventListener('change', filterSchedules);
    }

    if (filterDay) {
        filterDay.addEventListener('change', filterSchedules);
    }

    // Initialize schedule items
    initializeScheduleItems();
}

function initializeScheduleItems() {
    const editButtons = document.querySelectorAll('.schedule-item .action-btn.edit');
    const deleteButtons = document.querySelectorAll('.schedule-item .action-btn.delete');

    editButtons.forEach(button => {
        button.addEventListener('click', () => {
            const scheduleItem = button.closest('.schedule-item');
            editSchedule(scheduleItem);
        });
    });

    deleteButtons.forEach(button => {
        button.addEventListener('click', () => {
            const scheduleItem = button.closest('.schedule-item');
            deleteSchedule(scheduleItem);
        });
    });
}

function openScheduleModal(scheduleData = null) {
    const modal = document.getElementById('scheduleModal');
    const modalTitle = document.getElementById('modalTitle');
    const scheduleForm = document.getElementById('scheduleForm');

    if (modal && modalTitle && scheduleForm) {
        modalTitle.textContent = scheduleData ? 'Edit Jadwal' : 'Tambah Jadwal';

        if (scheduleData) {
            // Populate form with schedule data
            document.getElementById('teacherSelect').value = scheduleData.teacherId;

            // Clear all checkboxes first
            const checkboxes = scheduleForm.querySelectorAll('input[name="hari"]');
            checkboxes.forEach(checkbox => {
                checkbox.checked = scheduleData.hari.includes(checkbox.value);
            });

            document.getElementById('jamMulai').value = scheduleData.jamMulai;
            document.getElementById('jamSelesai').value = scheduleData.jamSelesai;
            document.getElementById('kelas').value = scheduleData.kelas;
            document.getElementById('ruangan').value = scheduleData.ruangan || '';
        } else {
            // Reset form
            scheduleForm.reset();
        }

        modal.classList.add('show');
    }
}

function saveSchedule() {
    const scheduleForm = document.getElementById('scheduleForm');
    const formData = new FormData(scheduleForm);

    // Get selected days
    const selectedDays = [];
    const checkboxes = scheduleForm.querySelectorAll('input[name="hari"]:checked');
    checkboxes.forEach(checkbox => {
        selectedDays.push(checkbox.value);
    });

    if (selectedDays.length === 0) {
        showNotification('Pilih minimal satu hari mengajar', 'error');
        return;
    }

    const scheduleData = {
        teacherId: document.getElementById('teacherSelect').value,
        hari: selectedDays,
        jamMulai: document.getElementById('jamMulai').value,
        jamSelesai: document.getElementById('jamSelesai').value,
        kelas: document.getElementById('kelas').value,
        ruangan: document.getElementById('ruangan').value
    };

    // Simulate saving to server
    const submitBtn = scheduleForm.querySelector('button[type="submit"]');
    submitBtn.classList.add('loading');
    submitBtn.disabled = true;

    setTimeout(() => {
        submitBtn.classList.remove('loading');
        submitBtn.disabled = false;

        closeModal('scheduleModal');
        showNotification('Jadwal berhasil disimpan', 'success');

        // In a real application, you would refresh the schedule list here
        // For demo purposes, we'll just show a success message
    }, 1500);
}

function editSchedule(scheduleItem) {
    // Extract schedule data from the DOM element
    const teacherName = scheduleItem.querySelector('.schedule-teacher h4').textContent;
    const subject = scheduleItem.querySelector('.schedule-teacher p').textContent;
    const daysText = scheduleItem.querySelector('.schedule-day span').textContent;
    const timeText = scheduleItem.querySelector('.schedule-time span').textContent;
    const classText = scheduleItem.querySelector('.schedule-class span').textContent;

    // Parse the data
    const [jamMulai, jamSelesai] = timeText.split(' - ');
    const days = daysText.split(', ').map(day => {
        const dayMap = {
            'Senin': 'senin',
            'Selasa': 'selasa',
            'Rabu': 'rabu',
            'Kamis': 'kamis',
            'Jumat': 'jumat'
        };
        return dayMap[day] || day.toLowerCase();
    });

    // Find teacher ID based on name (in a real app, this would come from the data)
    const teacherSelect = document.getElementById('teacherSelect');
    let teacherId = '';
    for (let option of teacherSelect.options) {
        if (option.text.includes(teacherName)) {
            teacherId = option.value;
            break;
        }
    }

    const scheduleData = {
        teacherId,
        hari: days,
        jamMulai,
        jamSelesai,
        kelas: classText,
        ruangan: '' // Not displayed in the current UI
    };

    openScheduleModal(scheduleData);
}

function deleteSchedule(scheduleItem) {
    const teacherName = scheduleItem.querySelector('.schedule-teacher h4').textContent;
    const subject = scheduleItem.querySelector('.schedule-teacher p').textContent;
    const scheduleInfo = `${teacherName} - ${subject}`;

    const deleteModal = document.getElementById('deleteModal');
    const deleteScheduleInfo = document.getElementById('deleteScheduleInfo');
    const confirmDeleteBtn = document.getElementById('confirmDeleteBtn');

    if (deleteModal && deleteScheduleInfo && confirmDeleteBtn) {
        deleteScheduleInfo.textContent = scheduleInfo;
        deleteModal.classList.add('show');

        // Remove previous event listeners
        const newConfirmBtn = confirmDeleteBtn.cloneNode(true);
        confirmDeleteBtn.parentNode.replaceChild(newConfirmBtn, confirmDeleteBtn);

        // Add event listener to the new button
        newConfirmBtn.addEventListener('click', () => {
            // Simulate deletion
            newConfirmBtn.classList.add('loading');
            newConfirmBtn.disabled = true;

            setTimeout(() => {
                closeModal('deleteModal');
                showNotification('Jadwal berhasil dihapus', 'success');

                // In a real application, you would remove the item from the DOM
                // For demo purposes, we'll just show a success message
            }, 1500);
        });
    }
}

function filterSchedules() {
    const filterPeriod = document.getElementById('filterPeriod').value;
    const filterTeacher = document.getElementById('filterTeacher').value;
    const filterDay = document.getElementById('filterDay').value;
    const scheduleItems = document.querySelectorAll('.schedule-item');

    scheduleItems.forEach(item => {
        let showItem = true;

        // Filter by period
        if (filterPeriod) {
            // In a real app, you would check if the schedule belongs to the selected period
            // For demo purposes, we'll show all items for any period selection
            console.log(`Filtering by period: ${filterPeriod}`);
        }

        // Filter by teacher
        if (filterTeacher) {
            const teacherName = item.querySelector('.schedule-teacher h4').textContent;
            // In a real app, you would compare by ID
            // For demo purposes, we'll just show all items
        }

        // Filter by day
        if (filterDay) {
            const daysText = item.querySelector('.schedule-day span').textContent;
            const dayMap = {
                'senin': 'Senin',
                'selasa': 'Selasa',
                'rabu': 'Rabu',
                'kamis': 'Kamis',
                'jumat': 'Jumat'
            };

            if (!daysText.includes(dayMap[filterDay])) {
                showItem = false;
            }
        }

        item.style.display = showItem ? 'block' : 'none';
    });
}

// Modal Management
function initializeModals() {
    const closeButtons = document.querySelectorAll('.close-btn');
    const cancelButtons = document.querySelectorAll('.btn-outline');

    closeButtons.forEach(button => {
        button.addEventListener('click', () => {
            const modal = button.closest('.modal');
            if (modal) {
                closeModal(modal.id);
            }
        });
    });

    cancelButtons.forEach(button => {
        button.addEventListener('click', () => {
            const modal = button.closest('.modal');
            if (modal) {
                closeModal(modal.id);
            }
        });
    });

    // Close modal when clicking outside
    document.addEventListener('click', (e) => {
        if (e.target.classList.contains('modal')) {
            closeModal(e.target.id);
        }
    });
}

function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.remove('show');
    }
}

// Notification System
function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.innerHTML = `
        <div class="notification-content">
            <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-circle' : 'info-circle'}"></i>
            <span>${message}</span>
        </div>
        <button class="notification-close">
            <i class="fas fa-times"></i>
        </button>
    `;

    // Add styles
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'success' ? '#10b981' : type === 'error' ? '#ef4444' : '#3b82f6'};
        color: white;
        padding: 15px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        z-index: 9999;
        display: flex;
        align-items: center;
        justify-content: space-between;
        min-width: 300px;
        animation: slideInRight 0.3s ease;
    `;

    const content = notification.querySelector('.notification-content');
    content.style.cssText = `
        display: flex;
        align-items: center;
        gap: 10px;
    `;

    const closeBtn = notification.querySelector('.notification-close');
    closeBtn.style.cssText = `
        background: none;
        border: none;
        color: white;
        cursor: pointer;
        padding: 0;
        margin-left: 10px;
    `;

    // Add to document
    document.body.appendChild(notification);

    // Close button functionality
    closeBtn.addEventListener('click', () => {
        notification.remove();
    });

    // Auto remove after 3 seconds
    setTimeout(() => {
        if (notification.parentNode) {
            notification.style.animation = 'slideOutRight 0.3s ease';
            setTimeout(() => {
                notification.remove();
            }, 300);
        }
    }, 3000);
}

// Add CSS for animations
const style = document.createElement('style');
style.textContent = `
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
`;
document.head.appendChild(style);

// Curriculum Management
function initializeCurriculumManagement() {
    const newPeriodBtn = document.getElementById('newPeriodBtn');
    const copyScheduleBtn = document.getElementById('copyScheduleBtn');
    const copyFromPrevious = document.getElementById('copyFromPrevious');
    const copyOptions = document.getElementById('copyOptions');
    const newPeriodForm = document.getElementById('newPeriodForm');
    const copyScheduleForm = document.getElementById('copyScheduleForm');

    // New period button
    if (newPeriodBtn) {
        newPeriodBtn.addEventListener('click', () => {
            openNewPeriodModal();
        });
    }

    // Copy schedule button
    if (copyScheduleBtn) {
        copyScheduleBtn.addEventListener('click', () => {
            openCopyScheduleModal();
        });
    }

    // Copy from previous checkbox
    if (copyFromPrevious) {
        copyFromPrevious.addEventListener('change', () => {
            if (copyOptions) {
                copyOptions.style.display = copyFromPrevious.checked ? 'block' : 'none';
            }
        });
    }

    // New period form submission
    if (newPeriodForm) {
        newPeriodForm.addEventListener('submit', (e) => {
            e.preventDefault();
            saveNewPeriod();
        });
    }

    // Copy schedule form submission
    if (copyScheduleForm) {
        copyScheduleForm.addEventListener('submit', (e) => {
            e.preventDefault();
            copySchedule();
        });
    }

    // Initialize period item actions
    initializePeriodActions();
}

function openNewPeriodModal() {
    const modal = document.getElementById('newPeriodModal');
    if (modal) {
        modal.classList.add('show');
    }
}

function openCopyScheduleModal() {
    const modal = document.getElementById('copyScheduleModal');
    if (modal) {
        modal.classList.add('show');
    }
}

function saveNewPeriod() {
    const tahunAjaran = document.getElementById('tahunAjaran').value;
    const semester = document.getElementById('semester').value;
    const tanggalMulai = document.getElementById('tanggalMulai').value;
    const tanggalSelesai = document.getElementById('tanggalSelesai').value;
    const copyFromPrevious = document.getElementById('copyFromPrevious').checked;
    const selectPeriod = document.getElementById('selectPeriod').value;

    // Validate form
    if (!tahunAjaran || !semester || !tanggalMulai || !tanggalSelesai) {
        showNotification('Semua field wajib diisi', 'error');
        return;
    }

    if (copyFromPrevious && !selectPeriod) {
        showNotification('Pilih periode sumber untuk menyalin jadwal', 'error');
        return;
    }

    // Simulate saving
    const submitBtn = document.querySelector('#newPeriodForm button[type="submit"]');
    submitBtn.classList.add('loading');
    submitBtn.disabled = true;

    setTimeout(() => {
        submitBtn.classList.remove('loading');
        submitBtn.disabled = false;

        closeModal('newPeriodModal');
        showNotification('Tahun ajaran baru berhasil dibuat', 'success');

        // In a real application, you would refresh the period list here
    }, 1500);
}

function copySchedule() {
    const sourcePeriod = document.getElementById('sourcePeriod').value;
    const targetPeriod = document.getElementById('targetPeriod').value;
    const copyTeachers = document.getElementById('copyTeachers').checked;
    const copySchedule = document.getElementById('copySchedule').checked;
    const copyClasses = document.getElementById('copyClasses').checked;
    const copySubjects = document.getElementById('copySubjects').checked;
    const overwriteExisting = document.getElementById('overwriteExisting').checked;

    // Validate form
    if (!sourcePeriod || !targetPeriod) {
        showNotification('Pilih periode sumber dan target', 'error');
        return;
    }

    if (!copyTeachers && !copySchedule && !copyClasses && !copySubjects) {
        showNotification('Pilih minimal satu opsi penyalinan', 'error');
        return;
    }

    // Simulate copying
    const submitBtn = document.querySelector('#copyScheduleForm button[type="submit"]');
    submitBtn.classList.add('loading');
    submitBtn.disabled = true;

    setTimeout(() => {
        submitBtn.classList.remove('loading');
        submitBtn.disabled = false;

        closeModal('copyScheduleModal');
        showNotification('Jadwal berhasil disalin', 'success');

        // In a real application, you would refresh the schedule list here
    }, 2000);
}

function initializePeriodActions() {
    const viewButtons = document.querySelectorAll('.period-item .action-btn.view');
    const copyButtons = document.querySelectorAll('.period-item .action-btn.copy');

    viewButtons.forEach(button => {
        button.addEventListener('click', () => {
            const periodItem = button.closest('.period-item');
            viewPeriodSchedule(periodItem);
        });
    });

    copyButtons.forEach(button => {
        button.addEventListener('click', () => {
            const periodItem = button.closest('.period-item');
            copyFromPeriod(periodItem);
        });
    });
}

function viewPeriodSchedule(periodItem) {
    const periodName = periodItem.querySelector('.period-info h5').textContent;
    showNotification(`Melihat jadwal untuk ${periodName}`, 'info');

    // In a real application, you would navigate to the schedule view for this period
}

function copyFromPeriod(periodItem) {
    const periodName = periodItem.querySelector('.period-info h5').textContent;
    const periodId = periodItem.getAttribute('data-period-id') || '2023-2024-genap';

    // Open copy schedule modal with pre-selected source period
    openCopyScheduleModal();

    // Pre-select the source period
    setTimeout(() => {
        const sourcePeriodSelect = document.getElementById('sourcePeriod');
        if (sourcePeriodSelect) {
            sourcePeriodSelect.value = periodId;
        }
    }, 100);

    showNotification(`Menyiapkan penyalinan dari ${periodName}`, 'info');
}