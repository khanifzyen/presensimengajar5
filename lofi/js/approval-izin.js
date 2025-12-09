// js/approval-izin.js
document.addEventListener('DOMContentLoaded', function () {
    // Initialize the page
    initializePage();

    // Add ripple effects to buttons
    addRippleEffects();

    // Initialize search functionality
    initializeSearch();

    // Initialize filter functionality
    initializeFilters();
});

// Initialize page
function initializePage() {
    // Set current date for date filter
    const today = new Date().toISOString().split('T')[0];
    const filterDate = document.getElementById('filterDate');
    if (filterDate) {
        filterDate.value = today;
    }

    // Add smooth transitions
    const requestCards = document.querySelectorAll('.request-card');
    requestCards.forEach((card, index) => {
        card.style.animation = `fadeInUp 0.5s ease-out ${index * 0.1}s`;
        card.style.animationFillMode = 'both';
    });
}

// Add ripple effects to clickable elements
function addRippleEffects() {
    const clickableElements = document.querySelectorAll('.btn-action, .filter-tab, .filter-btn');

    clickableElements.forEach(element => {
        element.addEventListener('click', function (e) {
            createRipple(this, e);
        });
    });
}

// Create ripple effect
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

// Initialize search functionality
function initializeSearch() {
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.addEventListener('input', searchRequests);
    }
}

// Search requests
function searchRequests() {
    const searchInput = document.getElementById('searchInput');
    const searchTerm = searchInput.value.toLowerCase();
    const requestCards = document.querySelectorAll('.request-card');

    requestCards.forEach(card => {
        const teacherName = card.dataset.name.toLowerCase();
        const requestType = card.dataset.type.toLowerCase();
        const teacherInfo = card.querySelector('.teacher-info h4').textContent.toLowerCase();
        const teacherSubject = card.querySelector('.teacher-subject').textContent.toLowerCase();

        const matchesSearch = teacherName.includes(searchTerm) ||
            requestType.includes(searchTerm) ||
            teacherInfo.includes(searchTerm) ||
            teacherSubject.includes(searchTerm);

        if (matchesSearch) {
            card.style.display = 'block';
        } else {
            card.style.display = 'none';
        }
    });
}

// Initialize filter functionality
function initializeFilters() {
    const filterType = document.getElementById('filterType');
    const filterDate = document.getElementById('filterDate');

    if (filterType) {
        filterType.addEventListener('change', applyFilters);
    }

    if (filterDate) {
        filterDate.addEventListener('change', applyFilters);
    }
}

// Filter requests by status
function filterRequests(status) {
    const filterTabs = document.querySelectorAll('.filter-tab');
    const requestCards = document.querySelectorAll('.request-card');

    // Update active tab
    filterTabs.forEach(tab => {
        tab.classList.remove('active');
    });
    event.target.classList.add('active');

    // Filter cards
    requestCards.forEach(card => {
        if (status === 'all') {
            card.style.display = 'block';
        } else {
            const cardStatus = card.dataset.status;
            if (cardStatus === status) {
                card.style.display = 'block';
            } else {
                card.style.display = 'none';
            }
        }
    });
}

// Apply advanced filters
function applyFilters() {
    const filterType = document.getElementById('filterType').value;
    const filterDate = document.getElementById('filterDate').value;
    const requestCards = document.querySelectorAll('.request-card');

    requestCards.forEach(card => {
        let shouldShow = true;

        // Filter by type
        if (filterType && card.dataset.type !== filterType) {
            shouldShow = false;
        }

        // Filter by date (simplified - just checks if date contains the filter date)
        if (filterDate && shouldShow) {
            const cardDateText = card.querySelector('.detail-item:nth-child(2) span').textContent;
            if (!cardDateText.includes(filterDate.split('-')[2])) { // Check day match
                shouldShow = false;
            }
        }

        card.style.display = shouldShow ? 'block' : 'none';
    });
}

// Toggle advanced filter
function toggleAdvancedFilter() {
    const advancedFilter = document.getElementById('advancedFilter');
    const filterBtn = document.querySelector('.filter-btn');

    if (advancedFilter.classList.contains('hidden')) {
        advancedFilter.classList.remove('hidden');
        filterBtn.classList.add('active');
    } else {
        advancedFilter.classList.add('hidden');
        filterBtn.classList.remove('active');
    }
}

// Approve request
function approveRequest(button, teacherName) {
    const modal = document.getElementById('approvalModal');
    const teacherNameSpan = document.getElementById('teacherName');
    const confirmBtn = document.getElementById('confirmApprovalBtn');

    // Set teacher name
    teacherNameSpan.textContent = teacherName;

    // Set approval action
    document.getElementById('approvalAction').textContent = 'menyetujui';
    confirmBtn.innerHTML = '<i class="fas fa-check"></i> Ya, Setujui';
    confirmBtn.className = 'btn btn-primary';

    // Store the button reference for later use
    confirmBtn.dataset.targetButton = button.getAttribute('data-request-id') || '';
    confirmBtn.dataset.teacherName = teacherName;
    confirmBtn.dataset.action = 'approve';

    // Show modal
    showModal('approvalModal');
}

// Reject request
function rejectRequest(button, teacherName) {
    const modal = document.getElementById('rejectionModal');
    const teacherNameSpan = document.getElementById('rejectTeacherName');

    // Set teacher name
    teacherNameSpan.textContent = teacherName;

    // Store the button reference for later use
    const confirmBtn = document.getElementById('confirmRejectionBtn');
    confirmBtn.dataset.targetButton = button.getAttribute('data-request-id') || '';
    confirmBtn.dataset.teacherName = teacherName;
    confirmBtn.dataset.action = 'reject';

    // Clear previous rejection reason
    document.getElementById('rejectionReason').value = '';

    // Show modal
    modal.classList.remove('hidden');
    modal.style.display = 'flex';
}

// Confirm approval
function confirmApproval() {
    const confirmBtn = document.getElementById('confirmApprovalBtn');
    const teacherName = confirmBtn.dataset.teacherName;
    const note = document.getElementById('approvalNote').value;

    // Add loading state
    confirmBtn.classList.add('loading');

    // Simulate API call
    setTimeout(() => {
        // Find and update the request card
        const requestCard = findRequestCard(teacherName);
        if (requestCard) {
            updateRequestCard(requestCard, 'approved', note);
        }

        // Remove loading state
        confirmBtn.classList.remove('loading');

        // Close modal
        closeModal('approvalModal');

        // Show success message
        showSuccessModal('Pengajuan Disetujui', `Pengajuan izin dari ${teacherName} telah disetujui.`);
    }, 1000);
}

// Confirm rejection
function confirmRejection() {
    const confirmBtn = document.getElementById('confirmRejectionBtn');
    const teacherName = confirmBtn.dataset.teacherName;
    const reason = document.getElementById('rejectionReason').value;

    // Validate rejection reason
    if (!reason.trim()) {
        alert('Alasan penolakan harus diisi');
        return;
    }

    // Add loading state
    confirmBtn.classList.add('loading');

    // Simulate API call
    setTimeout(() => {
        // Find and update the request card
        const requestCard = findRequestCard(teacherName);
        if (requestCard) {
            updateRequestCard(requestCard, 'rejected', reason);
        }

        // Remove loading state
        confirmBtn.classList.remove('loading');

        // Close modal
        closeModal('rejectionModal');

        // Show success message
        showSuccessModal('Pengajuan Ditolak', `Pengajuan izin dari ${teacherName} telah ditolak.`);
    }, 1000);
}

// Find request card by teacher name
function findRequestCard(teacherName) {
    const requestCards = document.querySelectorAll('.request-card');
    for (const card of requestCards) {
        if (card.dataset.name === teacherName) {
            return card;
        }
    }
    return null;
}

// Update request card after approval/rejection
function updateRequestCard(card, status, note) {
    // Update dataset
    card.dataset.status = status;

    // Remove previous status classes
    card.classList.remove('pending', 'approved', 'rejected');

    // Add new status class
    card.classList.add(status);

    // Update status badge
    const statusBadge = card.querySelector('.status-badge');
    statusBadge.classList.remove('pending', 'approved', 'rejected');

    if (status === 'approved') {
        card.style.borderLeftColor = '#10b981';
        statusBadge.classList.add('approved');
        statusBadge.textContent = 'Disetujui';

        // Add approval info
        const cardContent = card.querySelector('.card-content');
        const approvalInfo = document.createElement('div');
        approvalInfo.className = 'approval-info';
        approvalInfo.innerHTML = `
            <i class="fas fa-check-circle"></i>
            <span>Disetujui oleh Admin pada ${getCurrentDate()}, ${getCurrentTime()}</span>
        `;

        // Remove existing approval/rejection info
        const existingInfo = cardContent.querySelector('.approval-info, .rejection-info');
        if (existingInfo) {
            existingInfo.remove();
        }

        cardContent.appendChild(approvalInfo);

        // Update action buttons
        const cardActions = card.querySelector('.card-actions');
        cardActions.innerHTML = `
            <button class="btn-action view" onclick="viewDetails('${card.dataset.name}')">
                <i class="fas fa-eye"></i> Lihat Detail
            </button>
        `;

    } else if (status === 'rejected') {
        card.style.borderLeftColor = '#ef4444';
        statusBadge.classList.add('rejected');
        statusBadge.textContent = 'Ditolak';

        // Add rejection info
        const cardContent = card.querySelector('.card-content');
        const rejectionInfo = document.createElement('div');
        rejectionInfo.className = 'rejection-info';
        rejectionInfo.innerHTML = `
            <i class="fas fa-times-circle"></i>
            <span>Ditolak: ${note}</span>
        `;

        // Remove existing approval/rejection info
        const existingInfo = cardContent.querySelector('.approval-info, .rejection-info');
        if (existingInfo) {
            existingInfo.remove();
        }

        cardContent.appendChild(rejectionInfo);

        // Update action buttons
        const cardActions = card.querySelector('.card-actions');
        cardActions.innerHTML = `
            <button class="btn-action view" onclick="viewDetails('${card.dataset.name}')">
                <i class="fas fa-eye"></i> Lihat Detail
            </button>
        `;
    }

    // Add animation
    card.style.animation = 'pulse 0.5s ease-out';
}

// View attachment
function viewAttachment(element) {
    // In a real app, this would open the file
    const fileName = element.querySelector('span:nth-child(2)').textContent;
    alert(`Membuka file: ${fileName}\n\nDalam aplikasi nyata, file akan dibuka di viewer atau diunduh.`);
}

// View details
function viewDetails(teacherName) {
    // In a real app, this would open a detailed view
    alert(`Melihat detail pengajuan dari ${teacherName}\n\nDalam aplikasi nyata, ini akan membuka halaman detail lengkap.`);
}

// Show modal
function showModal(modalId) {
    const modal = document.getElementById(modalId);
    modal.classList.remove('hidden');
    modal.style.display = 'flex';
}

// Close modal
function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    modal.classList.add('hidden');
    modal.style.display = 'none';

    // Clear form data if needed
    if (modalId === 'approvalModal') {
        document.getElementById('approvalNote').value = '';
    } else if (modalId === 'rejectionModal') {
        document.getElementById('rejectionReason').value = '';
    }
}

// Show success modal
function showSuccessModal(title, message) {
    const modal = document.getElementById('successModal');
    const titleElement = document.getElementById('successTitle');
    const messageElement = document.getElementById('successMessage');

    titleElement.textContent = title;
    messageElement.textContent = message;

    modal.classList.remove('hidden');
    modal.style.display = 'flex';

    // Auto close after 3 seconds
    setTimeout(() => {
        closeModal('successModal');
    }, 3000);
}

// Get current date in Indonesian format
function getCurrentDate() {
    const options = { day: 'numeric', month: 'short', year: 'numeric' };
    return new Date().toLocaleDateString('id-ID', options);
}

// Get current time
function getCurrentTime() {
    const now = new Date();
    return `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
}

// Add CSS animation for pulse effect
const style = document.createElement('style');
style.textContent = `
    @keyframes pulse {
        0% { transform: scale(1); }
        50% { transform: scale(1.02); }
        100% { transform: scale(1); }
    }
    
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(20px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    
    .ripple {
        position: absolute;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.5);
        transform: scale(0);
        animation: ripple-animation 0.6s ease-out;
        pointer-events: none;
    }
    
    @keyframes ripple-animation {
        to {
            transform: scale(4);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);