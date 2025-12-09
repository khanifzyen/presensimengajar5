// js/onboarding.js
document.addEventListener("DOMContentLoaded", () => {
    // 1. Splash Screen Logic (2 detik)
    setTimeout(() => {
        const splash = document.getElementById('splash-screen');
        const onboarding = document.getElementById('onboarding-screen');

        splash.style.opacity = '0';

        setTimeout(() => {
            splash.style.display = 'none';
            onboarding.classList.remove('hidden');
            // Trigger reflow agar transisi opacity jalan
            void onboarding.offsetWidth;
            onboarding.classList.add('visible');
        }, 500); // Waktu untuk animasi fade out splash
    }, 2000);
});

// 2. Slider Logic
let currentSlide = 0;
const slides = document.querySelectorAll('.slide');
const dots = document.querySelectorAll('.dot');
const nextBtn = document.getElementById('nextBtn');

function showSlide(index) {
    slides.forEach((slide, i) => {
        slide.classList.remove('active');
        dots[i].classList.remove('active');
    });
    slides[index].classList.add('active');
    dots[index].classList.add('active');

    // Ubah tombol jika slide terakhir
    if (index === slides.length - 1) {
        nextBtn.innerHTML = 'MULAI SEKARANG';
    } else {
        nextBtn.innerHTML = 'Lanjut <i class="fas fa-arrow-right"></i>';
    }
}

function nextSlide() {
    if (currentSlide < slides.length - 1) {
        currentSlide++;
        showSlide(currentSlide);
    } else {
        goToLogin();
    }
}

function goToLogin() {
    window.location.href = 'login.html';
}