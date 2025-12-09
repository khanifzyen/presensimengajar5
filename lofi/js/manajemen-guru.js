// js/manajemen-guru.js
document.addEventListener('DOMContentLoaded', function () {
    // Initialize teacher management
    initializeTeacherManagement();

    // Initialize search functionality
    initializeSearch();

    // Initialize filter functionality
    initializeFilters();

    // Initialize modal functionality
    initializeModals();

    // Initialize action buttons
    initializeActionButtons();
});

// Teacher data storage (in real app, this would be from a database)
let teachers = [
    {
        id: 1,
        name: 'Budi Santoso, S.Pd',
        nip: '198506152008011001',
        subject: 'Matematika',
        email: 'budi.santoso@smpn1.sch.id',
        phone: '08123456789',
        status: 'active',
        joinDate: '2020-01-15',
        avatar: 'https://placehold.co/60x60'
    },
    {
        id: 2,
        name: 'Siti Aminah, S.Pd',
        nip: '198703122009022001',
        subject: 'Bahasa Indonesia',
        email: 'siti.aminah@smpn1.sch.id',
        phone: '08234567890',
        status: 'active',
        joinDate: '2015-03-20',
        avatar: 'https://placehold.co/60x60'
    },
    {
        id: 3,
        name: 'Ahmad Dahlan, S.Pd',
        nip: '198209101997031001',
        subject: 'Fisika',
        email: 'ahmad.dahlan@smpn1.sch.id',
        phone: '08345678901',
        status: 'inactive',
        joinDate: '2010-09-10',
        avatar: 'https://placehold.co/60x60'
    },
    {
        id: 4,
        name: 'Dewi Sartika, S.Pd',
        nip: '199012152019032001',
        subject: 'Kimia',
        email: 'dewi.sartika@smpn1.sch.id',
        phone: '08456789012',
        status: 'active',
        joinDate: '2019-12-15',
        avatar: 'https://placehold.co/60x60'
    },
    {
        id: 5,
        name: 'Eko Prasetyo, S.Kom',
        nip: '198805202010011001',
        subject: 'Teknik Komputer',
        email: 'eko.prasetyo@smpn1.sch.id',
        phone: '08567890123',
        status: 'active',
        joinDate: '2024-05-20',
        avatar: 'https://placehold.co/60x60'
    }
];

let currentEditId = null;
let currentFilter = 'all';

// Initialize teacher management
function initializeTeacherManagement() {
    updateStatistics();
    renderTeacherList();
}

// Update statistics
function updateStatistics() {
    const totalTeachers = teachers.length;
    const activeTeachers = teachers.filter(t => t.status === 'active').length;
    const newTeachers = teachers.filter(t => {
        const joinDate = new Date(t.joinDate);
        const threeMonthsAgo = new Date();
        threeMonthsAgo.setMonth(threeMonthsAgo.getMonth() - 3);
        return joinDate > threeMonthsAgo;
    }).length;
    const inactiveTeachers = teachers.filter(t => t.status === 'inactive').length;

    document.getElementById('totalTeachers').textContent = totalTeachers;
    document.getElementById('activeTeachers').textContent = activeTeachers;
    document.getElementById('newTeachers').textContent = newTeachers;
    document.getElementById('inactiveTeachers').textContent = inactiveTeachers;
}

// Render teacher list
function renderTeacherList(filteredTeachers = teachers) {
    const teacherList = document.getElementById('teacherList');
    teacherList.innerHTML = '';

    filteredTeachers.forEach(teacher => {
        const statusClass = teacher.status === 'active' ? 'active' : 'inactive';
        const statusText = teacher.status === 'active' ? 'Aktif' : 'Non-Aktif';

        // Check if teacher is new (joined in last 3 months)
        const joinDate = new Date(teacher.joinDate);
        const threeMonthsAgo = new Date();
        threeMonthsAgo.setMonth(threeMonthsAgo.getMonth() - 3);
        const isNew = joinDate > threeMonthsAgo;
        const statusBadgeClass = isNew ? 'new' : statusClass;
        const statusBadgeText = isNew ? 'Baru' : statusText;

        const teacherCard = document.createElement('div');
        teacherCard.className = 'teacher-card';
        teacherCard.dataset.status = teacher.status;
        teacherCard.dataset.id = teacher.id;

        teacherCard.innerHTML = `
            <div class="teacher-avatar">
                <img src="${teacher.avatar}" alt="${teacher.name}">
            </div>
            <div class="teacher-details">
                <h4>${teacher.name}</h4>
                <p class="teacher-nip">NIP: ${teacher.nip}</p>
                <p class="teacher-subject">${teacher.subject}</p>
                <div class="teacher-status">
                    <span class="status-badge ${statusBadgeClass}">${statusBadgeText}</span>
                    <span class="join-date">Bergabung: ${formatDate(teacher.joinDate)}</span>
                </div>
            </div>
            <div class="teacher-actions">
                <button class="action-btn edit" title="Edit" data-id="${teacher.id}">
                    <i class="fas fa-edit"></i>
                </button>
                <button class="action-btn schedule" title="Jadwal" data-id="${teacher.id}">
                    <i class="fas fa-calendar"></i>
                </button>
                <button class="action-btn delete" title="Hapus" data-id="${teacher.id}">
                    <i class="fas fa-trash"></i>
                </button>
            </div>
        `;

        teacherList.appendChild(teacherCard);
    });
}

// Format date
function formatDate(dateString) {
    const date = new Date(dateString);
    const options = { year: 'numeric', month: 'short' };
    return date.toLocaleDateString('id-ID', options);
}

// Initialize search functionality
function initializeSearch() {
    const searchInput = document.getElementById('searchInput');
    searchInput.addEventListener('input', function () {
        const searchTerm = this.value.toLowerCase();
        const filteredTeachers = teachers.filter(teacher =>
            teacher.name.toLowerCase().includes(searchTerm) ||
            teacher.nip.includes(searchTerm) ||
            teacher.subject.toLowerCase().includes(searchTerm)
        );
        renderTeacherList(applyFilters(filteredTeachers));
    });
}

// Initialize filter functionality
function initializeFilters() {
    const filterButtons = document.querySelectorAll('.filter-btn');

    filterButtons.forEach(button => {
        button.addEventListener('click', function () {
            // Remove active class from all buttons
            filterButtons.forEach(btn => btn.classList.remove('active'));

            // Add active class to clicked button
            this.classList.add('active');

            // Update current filter
            currentFilter = this.dataset.filter;

            // Apply filters and render
            renderTeacherList(applyFilters(teachers));
        });
    });
}

// Apply filters to teacher list
function applyFilters(teacherList) {
    let filtered = teacherList;

    if (currentFilter === 'active') {
        filtered = filtered.filter(t => t.status === 'active');
    } else if (currentFilter === 'inactive') {
        filtered = filtered.filter(t => t.status === 'inactive');
    }

    return filtered;
}

// Initialize modal functionality
function initializeModals() {
    const teacherModal = document.getElementById('teacherModal');
    const deleteModal = document.getElementById('deleteModal');
    const addTeacherBtn = document.getElementById('addTeacherBtn');
    const closeModal = document.getElementById('closeModal');
    const cancelBtn = document.getElementById('cancelBtn');
    const closeDeleteModal = document.getElementById('closeDeleteModal');
    const cancelDeleteBtn = document.getElementById('cancelDeleteBtn');
    const teacherForm = document.getElementById('teacherForm');
    const confirmDeleteBtn = document.getElementById('confirmDeleteBtn');

    // Open add teacher modal
    addTeacherBtn.addEventListener('click', function () {
        currentEditId = null;
        document.getElementById('modalTitle').textContent = 'Tambah Guru Baru';
        teacherForm.reset();

        // For add mode, make password required
        const passwordField = document.getElementById('teacherPassword');
        passwordField.placeholder = 'Masukkan password untuk login';
        passwordField.required = true;

        teacherModal.classList.add('active');
    });

    // Close modals
    closeModal.addEventListener('click', function () {
        teacherModal.classList.remove('active');
    });

    cancelBtn.addEventListener('click', function () {
        teacherModal.classList.remove('active');
    });

    closeDeleteModal.addEventListener('click', function () {
        deleteModal.classList.remove('active');
    });

    cancelDeleteBtn.addEventListener('click', function () {
        deleteModal.classList.remove('active');
    });

    // Handle teacher form submission
    teacherForm.addEventListener('submit', function (e) {
        e.preventDefault();

        const formData = {
            name: document.getElementById('teacherName').value,
            nip: document.getElementById('teacherNIP').value,
            subject: document.getElementById('teacherSubject').value,
            email: document.getElementById('teacherEmail').value,
            phone: document.getElementById('teacherPhone').value,
            status: document.getElementById('teacherStatus').value,
            joinDate: document.getElementById('teacherJoinDate').value,
            password: document.getElementById('teacherPassword').value,
            avatar: `https://placehold.co/60x60`
        };

        if (currentEditId) {
            // Update existing teacher
            const index = teachers.findIndex(t => t.id === currentEditId);
            if (index !== -1) {
                teachers[index] = { ...teachers[index], ...formData };
            }
        } else {
            // Add new teacher
            const newTeacher = {
                id: Math.max(...teachers.map(t => t.id)) + 1,
                ...formData
            };
            teachers.push(newTeacher);
        }

        updateStatistics();
        renderTeacherList(applyFilters(teachers));
        teacherModal.classList.remove('active');

        // Show success message
        showNotification(currentEditId ? 'Data guru berhasil diperbarui' : 'Guru baru berhasil ditambahkan');
    });

    // Handle delete confirmation
    confirmDeleteBtn.addEventListener('click', function () {
        if (currentEditId) {
            teachers = teachers.filter(t => t.id !== currentEditId);
            updateStatistics();
            renderTeacherList(applyFilters(teachers));
            deleteModal.classList.remove('active');

            // Show success message
            showNotification('Data guru berhasil dihapus');
        }
    });

    // Close modal when clicking outside
    window.addEventListener('click', function (e) {
        if (e.target === teacherModal) {
            teacherModal.classList.remove('active');
        }
        if (e.target === deleteModal) {
            deleteModal.classList.remove('active');
        }
    });
}

// Initialize action buttons
function initializeActionButtons() {
    // Use event delegation for dynamically created buttons
    document.addEventListener('click', function (e) {
        const target = e.target.closest('.action-btn');
        if (!target) return;

        const teacherId = parseInt(target.dataset.id);
        const teacher = teachers.find(t => t.id === teacherId);

        if (target.classList.contains('edit')) {
            // Open edit modal
            currentEditId = teacherId;
            document.getElementById('modalTitle').textContent = 'Edit Data Guru';
            document.getElementById('teacherName').value = teacher.name;
            document.getElementById('teacherNIP').value = teacher.nip;
            document.getElementById('teacherSubject').value = teacher.subject;
            document.getElementById('teacherEmail').value = teacher.email;
            document.getElementById('teacherPhone').value = teacher.phone;
            document.getElementById('teacherStatus').value = teacher.status;
            document.getElementById('teacherJoinDate').value = teacher.joinDate;

            // For edit mode, clear password field and make it optional
            const passwordField = document.getElementById('teacherPassword');
            passwordField.value = '';
            passwordField.placeholder = 'Kosongkan jika tidak mengubah password';
            passwordField.required = false;

            document.getElementById('teacherModal').classList.add('active');
        } else if (target.classList.contains('schedule')) {
            // Navigate to schedule page
            window.location.href = `jadwal-guru.html?teacher=${teacherId}`;
        } else if (target.classList.contains('delete')) {
            // Open delete confirmation modal
            currentEditId = teacherId;
            document.getElementById('deleteTeacherName').textContent = teacher.name;
            document.getElementById('deleteModal').classList.add('active');
        }
    });
}

// Show notification
function showNotification(message) {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = 'notification';
    notification.textContent = message;
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: var(--success);
        color: white;
        padding: 12px 20px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        z-index: 2000;
        animation: slideInRight 0.3s ease;
    `;

    // Add to document
    document.body.appendChild(notification);

    // Remove after 3 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.3s ease';
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}

// Add CSS for notification animations
const notificationStyles = document.createElement('style');
notificationStyles.textContent = `
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
document.head.appendChild(notificationStyles);