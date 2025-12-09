// js/presensi.js

// Simulasi deteksi lokasi
setTimeout(() => {
    const icon = document.getElementById('status-icon');
    const title = document.getElementById('status-title');
    const desc = document.getElementById('status-desc');
    const btn = document.getElementById('btn-submit');

    icon.classList.remove('loading');
    icon.classList.add('success');
    icon.innerHTML = '<i class="fas fa-check"></i>';

    title.innerText = 'Anda di dalam Radius';
    title.style.color = 'var(--success)';
    desc.innerText = 'Jarak: 5 meter. Akurasi Tinggi.';

    btn.disabled = false;
    btn.classList.remove('btn-disabled');
    btn.classList.add('btn-primary');
}, 2500); // 2.5 detik pura-pura loading

function submitPresensi() {
    const modal = document.getElementById('success-modal');
    modal.classList.remove('hidden');
}