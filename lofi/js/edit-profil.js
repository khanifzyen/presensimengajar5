// js/edit-profil.js
document.addEventListener('DOMContentLoaded', function () {
    // Initialize form validation
    const form = document.getElementById('editProfileForm');
    if (form) {
        const inputs = form.querySelectorAll('input, textarea, select');
        inputs.forEach(input => {
            input.addEventListener('blur', function () {
                validateField(this);
            });
        });
    }

    // Ensure modal is hidden on page load
    const modal = document.getElementById('success-modal');
    if (modal) {
        modal.classList.add('hidden');
        modal.style.display = 'none';
    }
});

// Update profile picture
function updateProfilePic(input) {
    if (input.files && input.files[0]) {
        const file = input.files[0];

        // Validate file type
        if (!file.type.startsWith('image/')) {
            alert('Hanya file gambar yang diperbolehkan');
            input.value = '';
            return;
        }

        // Validate file size (max 2MB)
        if (file.size > 2 * 1024 * 1024) {
            alert('Ukuran file maksimal 2MB');
            input.value = '';
            return;
        }

        // Preview the image
        const reader = new FileReader();
        reader.onload = function (e) {
            const profilePic = document.querySelector('.profile-pic-edit');
            if (profilePic) {
                profilePic.src = e.target.result;
            }
        };
        reader.readAsDataURL(file);
    }
}

// Validate field
function validateField(field) {
    const formGroup = field.closest('.form-group');
    if (!formGroup) return;

    let isValid = true;
    let errorMessage = '';

    if (field.hasAttribute('required') && !field.value.trim()) {
        isValid = false;
        errorMessage = 'Field ini wajib diisi';
    }

    // Email validation
    if (field.type === 'email' && field.value) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(field.value)) {
            isValid = false;
            errorMessage = 'Format email tidak valid';
        }
    }

    // Phone validation
    if (field.type === 'tel' && field.value) {
        const phoneRegex = /^[0-9\-\s\+]+$/;
        if (!phoneRegex.test(field.value) || field.value.replace(/\D/g, '').length < 10) {
            isValid = false;
            errorMessage = 'Nomor telepon tidak valid';
        }
    }

    // Visual feedback
    if (isValid) {
        field.style.borderColor = '#10b981';
        field.style.backgroundColor = '#f0fdf4';
        removeErrorMessage(formGroup);
    } else {
        field.style.borderColor = '#ef4444';
        field.style.backgroundColor = '#fef2f2';
        showErrorMessage(formGroup, errorMessage);
    }

    return isValid;
}

// Show error message
function showErrorMessage(formGroup, message) {
    removeErrorMessage(formGroup);

    const errorDiv = document.createElement('div');
    errorDiv.className = 'error-message';
    errorDiv.textContent = message;
    errorDiv.style.color = '#ef4444';
    errorDiv.style.fontSize = '12px';
    errorDiv.style.marginTop = '5px';

    formGroup.appendChild(errorDiv);
}

// Remove error message
function removeErrorMessage(formGroup) {
    const existingError = formGroup.querySelector('.error-message');
    if (existingError) {
        existingError.remove();
    }
}

// Save profile
function saveProfile() {
    const form = document.getElementById('editProfileForm');
    const requiredFields = form.querySelectorAll('[required]');
    let isValid = true;

    // Validate all required fields
    requiredFields.forEach(field => {
        if (!validateField(field)) {
            isValid = false;
        }
    });

    if (!isValid) {
        alert('Mohon perbaiki kesalahan pada form');
        return;
    }

    // Show loading state
    const submitBtn = form.querySelector('button[type="submit"]');
    const originalText = submitBtn.textContent;
    submitBtn.classList.add('loading');
    submitBtn.disabled = true;

    // Simulate API call
    setTimeout(() => {
        // Remove loading state
        submitBtn.classList.remove('loading');
        submitBtn.disabled = false;
        submitBtn.textContent = originalText;

        // Show success modal
        const modal = document.getElementById('success-modal');
        if (modal) {
            modal.style.display = 'flex';
            modal.classList.remove('hidden');
        }
    }, 1500);
}

// Close modal
function closeModal() {
    const modal = document.getElementById('success-modal');
    if (modal) {
        modal.style.display = 'none';
        modal.classList.add('hidden');
    }

    // Redirect to profile page after a short delay
    setTimeout(() => {
        window.location.href = 'profil.html';
    }, 300);
}

// Add CSS for error messages
const style = document.createElement('style');
style.textContent = `
    .error-message {
        animation: slideIn 0.3s ease-out;
    }
    
    @keyframes slideIn {
        from {
            opacity: 0;
            transform: translateY(-10px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
`;
document.head.appendChild(style);