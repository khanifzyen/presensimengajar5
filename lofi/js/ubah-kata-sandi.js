// js/ubah-kata-sandi.js
document.addEventListener('DOMContentLoaded', function () {
    // Initialize password strength checker
    const newPasswordInput = document.getElementById('newPassword');
    const confirmPasswordInput = document.getElementById('confirmPassword');
    const currentPasswordInput = document.getElementById('currentPassword');

    if (newPasswordInput) {
        newPasswordInput.addEventListener('input', checkPasswordStrength);
        newPasswordInput.addEventListener('input', checkPasswordMatch);
    }

    if (confirmPasswordInput) {
        confirmPasswordInput.addEventListener('input', checkPasswordMatch);
    }

    // Ensure modal is hidden on page load
    const modal = document.getElementById('success-modal');
    if (modal) {
        modal.classList.add('hidden');
        modal.style.display = 'none';
    }
});

// Toggle password visibility
function togglePassword(inputId) {
    const input = document.getElementById(inputId);
    const button = input.nextElementSibling;
    const icon = button.querySelector('i');

    if (input.type === 'password') {
        input.type = 'text';
        icon.classList.remove('fa-eye');
        icon.classList.add('fa-eye-slash');
    } else {
        input.type = 'password';
        icon.classList.remove('fa-eye-slash');
        icon.classList.add('fa-eye');
    }
}

// Check password strength
function checkPasswordStrength() {
    const password = document.getElementById('newPassword').value;
    const strengthFill = document.querySelector('.strength-fill');
    const strengthText = document.querySelector('.strength-text');

    let strength = 0;
    let strengthLevel = '';

    // Check length
    if (password.length >= 8) {
        strength++;
        updateRequirement('length-check', true);
    } else {
        updateRequirement('length-check', false);
    }

    // Check uppercase
    if (/[A-Z]/.test(password)) {
        strength++;
        updateRequirement('uppercase-check', true);
    } else {
        updateRequirement('uppercase-check', false);
    }

    // Check lowercase
    if (/[a-z]/.test(password)) {
        strength++;
        updateRequirement('lowercase-check', true);
    } else {
        updateRequirement('lowercase-check', false);
    }

    // Check number
    if (/[0-9]/.test(password)) {
        strength++;
        updateRequirement('number-check', true);
    } else {
        updateRequirement('number-check', false);
    }

    // Update strength bar
    const strengthBar = document.querySelector('.strength-bar');
    strengthBar.className = 'strength-bar';

    if (strength <= 1) {
        strengthLevel = 'Lemah';
        strengthFill.style.width = '25%';
        strengthFill.style.backgroundColor = '#ef4444';
        strengthText.textContent = 'Kekuatan kata sandi: Lemah';
    } else if (strength <= 2) {
        strengthLevel = 'Sedang';
        strengthFill.style.width = '50%';
        strengthFill.style.backgroundColor = '#f59e0b';
        strengthText.textContent = 'Kekuatan kata sandi: Sedang';
    } else if (strength <= 3) {
        strengthLevel = 'Kuat';
        strengthFill.style.width = '75%';
        strengthFill.style.backgroundColor = '#eab308';
        strengthText.textContent = 'Kekuatan kata sandi: Kuat';
    } else {
        strengthLevel = 'Sangat Kuat';
        strengthFill.style.width = '100%';
        strengthFill.style.backgroundColor = '#10b981';
        strengthText.textContent = 'Kekuatan kata sandi: Sangat Kuat';
    }

    return strength;
}

// Update requirement indicator
function updateRequirement(id, isMet) {
    const element = document.getElementById(id);
    const icon = element.querySelector('i');

    if (isMet) {
        element.classList.add('met');
        icon.classList.remove('fa-circle');
        icon.classList.add('fa-check-circle');
    } else {
        element.classList.remove('met');
        icon.classList.remove('fa-check-circle');
        icon.classList.add('fa-circle');
    }
}

// Check password match
function checkPasswordMatch() {
    const newPassword = document.getElementById('newPassword').value;
    const confirmPassword = document.getElementById('confirmPassword').value;

    if (confirmPassword.length > 0) {
        if (newPassword === confirmPassword) {
            updateRequirement('match-check', true);
        } else {
            updateRequirement('match-check', false);
        }
    } else {
        updateRequirement('match-check', false);
    }
}

// Validate form
function validateForm() {
    const currentPassword = document.getElementById('currentPassword').value;
    const newPassword = document.getElementById('newPassword').value;
    const confirmPassword = document.getElementById('confirmPassword').value;

    // Check if all fields are filled
    if (!currentPassword || !newPassword || !confirmPassword) {
        alert('Semua field harus diisi');
        return false;
    }

    // Check password strength
    const strength = checkPasswordStrength();
    if (strength < 2) {
        alert('Kata sandi baru terlalu lemah. Gunakan kombinasi huruf besar, huruf kecil, dan angka.');
        return false;
    }

    // Check password match
    if (newPassword !== confirmPassword) {
        alert('Kata sandi baru dan konfirmasi tidak cocok');
        return false;
    }

    // Check if new password is same as current
    if (currentPassword === newPassword) {
        alert('Kata sandi baru tidak boleh sama dengan kata sandi saat ini');
        return false;
    }

    return true;
}

// Change password
function changePassword() {
    if (!validateForm()) {
        return;
    }

    // Show loading state
    const form = document.getElementById('changePasswordForm');
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

    // Reset form
    const form = document.getElementById('changePasswordForm');
    if (form) {
        form.reset();
    }

    // Reset strength indicators
    const requirements = document.querySelectorAll('.requirement');
    requirements.forEach(req => {
        req.classList.remove('met');
        const icon = req.querySelector('i');
        icon.classList.remove('fa-check-circle');
        icon.classList.add('fa-circle');
    });

    // Reset strength bar
    const strengthFill = document.querySelector('.strength-fill');
    const strengthText = document.querySelector('.strength-text');
    if (strengthFill) strengthFill.style.width = '0%';
    if (strengthText) strengthText.textContent = 'Kekuatan kata sandi';

    // Redirect to profile page after a short delay
    setTimeout(() => {
        window.location.href = 'profil.html';
    }, 300);
}