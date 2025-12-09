// js/izin.js
document.addEventListener('DOMContentLoaded', function () {
    // Initialize date inputs with today's date
    const today = new Date().toISOString().split('T')[0];
    const dateInputs = document.querySelectorAll('input[type="date"]');
    dateInputs.forEach(input => {
        input.min = today;
        if (!input.value) {
            input.value = today;
        }
    });

    // Add smooth transitions for tab switching
    const tabBtns = document.querySelectorAll('.tab-btn');
    tabBtns.forEach(btn => {
        btn.addEventListener('click', function () {
            // Add ripple effect
            createRipple(this, event);
        });
    });

    // Validate form on input
    const form = document.getElementById('leaveForm');
    if (form) {
        const inputs = form.querySelectorAll('input, select, textarea');
        inputs.forEach(input => {
            input.addEventListener('blur', function () {
                validateField(this);
            });
        });
    }
});

// Fungsi Ganti Tab dengan animasi
function switchTab(tabName) {
    const btnForm = document.querySelectorAll('.tab-btn')[0];
    const btnHist = document.querySelectorAll('.tab-btn')[1];
    const contentForm = document.getElementById('content-form');
    const contentHist = document.getElementById('content-history');

    if (tabName === 'form') {
        btnForm.classList.add('active');
        btnHist.classList.remove('active');
        contentForm.classList.remove('hidden');
        contentHist.classList.add('hidden');
    } else {
        btnHist.classList.add('active');
        btnForm.classList.remove('active');
        contentHist.classList.remove('hidden');
        contentForm.classList.add('hidden');
    }

    // Scroll to top when switching tabs
    document.querySelector('.screen-content').scrollTop = 0;
}

// Update Nama File saat Upload dengan validasi
function updateFileName(input) {
    const fileNameDisplay = document.getElementById('fileName');
    const uploadArea = document.querySelector('.upload-area');

    if (input.files && input.files.length > 0) {
        const file = input.files[0];
        const fileSize = (file.size / 1024).toFixed(2); // in KB

        // Validate file type
        const allowedTypes = ['image/jpeg', 'image/jpg', 'application/pdf'];
        if (!allowedTypes.includes(file.type)) {
            alert('Hanya file JPG dan PDF yang diperbolehkan');
            input.value = '';
            return;
        }

        // Validate file size (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
            alert('Ukuran file maksimal 5MB');
            input.value = '';
            return;
        }

        fileNameDisplay.innerText = `${file.name} (${fileSize} KB)`;
        fileNameDisplay.style.color = '#1e3a8a';
        fileNameDisplay.style.fontWeight = 'bold';
        uploadArea.style.borderColor = '#10b981';
        uploadArea.style.background = '#f0fdf4';
    } else {
        fileNameDisplay.innerText = 'Ketuk untuk upload file (JPG/PDF)';
        fileNameDisplay.style.color = '';
        fileNameDisplay.style.fontWeight = '';
        uploadArea.style.borderColor = '';
        uploadArea.style.background = '';
    }
}

// Validasi field form
function validateField(field) {
    const formGroup = field.closest('.form-group');
    if (!formGroup) return;

    let isValid = true;

    if (field.hasAttribute('required') && !field.value.trim()) {
        isValid = false;
    }

    if (field.type === 'date') {
        const startDate = document.querySelector('input[type="date"]:first-of-type');
        const endDate = document.querySelector('input[type="date"]:last-of-type');

        if (startDate && endDate && startDate.value && endDate.value) {
            if (new Date(startDate.value) > new Date(endDate.value)) {
                isValid = false;
                if (field === endDate) {
                    alert('Tanggal selesai tidak boleh lebih awal dari tanggal mulai');
                }
            }
        }
    }

    // Visual feedback
    if (isValid) {
        field.style.borderColor = '#10b981';
        formGroup.querySelector('label')?.classList.add('valid');
    } else {
        field.style.borderColor = '#ef4444';
        formGroup.querySelector('label')?.classList.remove('valid');
    }

    return isValid;
}

// Submit Form dengan validasi
function submitIzin() {
    const form = document.getElementById('leaveForm');
    const requiredFields = form.querySelectorAll('[required]');
    let isValid = true;

    // Validate all required fields
    requiredFields.forEach(field => {
        if (!validateField(field)) {
            isValid = false;
        }
    });

    if (!isValid) {
        alert('Mohon lengkapi semua field yang diperlukan');
        return;
    }

    // Show success modal
    const modal = document.getElementById('modal-izin');
    if (modal) {
        modal.style.display = 'flex';
        modal.classList.remove('hidden');
    }
}

// Tutup Modal & Reset Form
function closeModal() {
    const modal = document.getElementById('modal-izin');
    if (modal) {
        modal.style.display = 'none';
        modal.classList.add('hidden');
    }

    // Pindah ke tab riwayat (Simulasi UX yang baik setelah submit)
    switchTab('history');

    // Reset form
    const form = document.getElementById('leaveForm');
    if (form) {
        form.reset();
    }

    const fileNameDisplay = document.getElementById('fileName');
    if (fileNameDisplay) {
        fileNameDisplay.innerText = 'Ketuk untuk upload file (JPG/PDF)';
        fileNameDisplay.style.color = '';
        fileNameDisplay.style.fontWeight = '';
    }

    // Reset upload area styling
    const uploadArea = document.querySelector('.upload-area');
    if (uploadArea) {
        uploadArea.style.borderColor = '';
        uploadArea.style.background = '';
    }
}

// Ripple effect untuk tombol
function createRipple(button, event) {
    const ripple = document.createElement('span');
    const rect = button.getBoundingClientRect();
    const size = Math.max(rect.width, rect.height);
    const x = event.clientX - rect.left - size / 2;
    const y = event.clientY - rect.top - size / 2;

    ripple.style.width = ripple.style.height = size + 'px';
    ripple.style.left = x + 'px';
    ripple.style.top = y + 'px';
    ripple.classList.add('ripple');

    button.appendChild(ripple);

    setTimeout(() => {
        ripple.remove();
    }, 600);
}