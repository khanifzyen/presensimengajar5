// js/laporan.js
document.addEventListener('DOMContentLoaded', function () {
    // Initialize the page
    initializePage();

    // Set current month and year as default
    setCurrentMonthYear();

    // Load initial data
    loadReportData();
});

// Initialize page
function initializePage() {
    // Add ripple effects to buttons
    addRippleEffects();

    // Initialize filter toggle
    initializeFilterToggle();
}

// Set current month and year as default
function setCurrentMonthYear() {
    const now = new Date();
    const currentMonth = now.getMonth() + 1; // JavaScript months are 0-indexed
    const currentYear = now.getFullYear();

    document.getElementById('monthFilter').value = currentMonth.toString();
    document.getElementById('yearFilter').value = currentYear.toString();
}

// Add ripple effects to buttons
function addRippleEffects() {
    const buttons = document.querySelectorAll('.btn, .export-option');

    buttons.forEach(button => {
        button.addEventListener('click', function (e) {
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

// Initialize filter toggle
function initializeFilterToggle() {
    const filterHeader = document.querySelector('.filter-header');
    const filterOptions = document.getElementById('filterOptions');
    const toggleBtn = document.querySelector('.toggle-filter');

    // Set initial state to collapsed
    filterOptions.classList.add('hidden');
    toggleBtn.classList.add('collapsed');

    filterHeader.addEventListener('click', function () {
        filterOptions.classList.toggle('hidden');
        toggleBtn.classList.toggle('collapsed');
    });
}

// Toggle filter options
function toggleFilterOptions() {
    const filterOptions = document.getElementById('filterOptions');
    const toggleBtn = document.querySelector('.toggle-filter');

    filterOptions.classList.toggle('hidden');
    toggleBtn.classList.toggle('collapsed');
}

// Apply filters
function applyFilters() {
    const month = document.getElementById('monthFilter').value;
    const year = document.getElementById('yearFilter').value;
    const teacher = document.getElementById('teacherFilter').value;
    const status = document.getElementById('statusFilter').value;
    const category = document.getElementById('categoryFilter').value;

    // Show loading state
    showLoading();

    // Simulate API call
    setTimeout(() => {
        loadReportData(month, year, teacher, status, category);
        hideLoading();
        showNotification('Filter berhasil diterapkan');
    }, 500);
}

// Reset filters
function resetFilters() {
    document.getElementById('monthFilter').value = '';
    document.getElementById('yearFilter').value = '';
    document.getElementById('teacherFilter').value = '';
    document.getElementById('statusFilter').value = '';
    document.getElementById('categoryFilter').value = '';

    // Reload data with default filters
    loadReportData();
    showNotification('Filter direset');
}

// Load report data
function loadReportData(month = '', year = '', teacher = '', status = '', category = '') {
    // Sample data - in real app, this would come from API
    const reportData = generateSampleData(month, year, teacher, status, category);

    // Update table
    updateReportTable(reportData);

    // Update summary
    updateSummary(reportData);
}

// Generate sample data (in real app, this would come from API)
function generateSampleData(month, year, teacher, status, category) {
    const sampleData = [
        {
            date: '01 Des 2025',
            day: 'Senin',
            teacher: 'Budi Santoso',
            category: 'office',
            categoryName: 'Kantor',
            subject: 'Presensi Kantor',
            checkIn: '07:00',
            checkOut: '15:30',
            status: 'hadir',
            note: '-'
        },
        {
            date: '01 Des 2025',
            day: 'Senin',
            teacher: 'Siti Aminah',
            category: 'class',
            categoryName: 'Mengajar',
            subject: 'Bahasa Indonesia - XII IPA 1',
            checkIn: '07:10',
            checkOut: '08:30',
            status: 'telat',
            note: 'Telat 10 menit'
        },
        {
            date: '01 Des 2025',
            day: 'Senin',
            teacher: 'Ahmad Dahlan',
            category: 'office',
            categoryName: 'Kantor',
            subject: 'Presensi Kantor',
            checkIn: '-',
            checkOut: '-',
            status: 'alpha',
            note: 'Tidak hadir tanpa keterangan'
        },
        {
            date: '02 Des 2025',
            day: 'Selasa',
            teacher: 'Dewi Sartika',
            category: 'class',
            categoryName: 'Mengajar',
            subject: 'Kimia - XII IPA 2',
            checkIn: '-',
            checkOut: '-',
            status: 'permit',
            note: 'Demam tinggi'
        },
        {
            date: '02 Des 2025',
            day: 'Selasa',
            teacher: 'Eko Prasetyo',
            category: 'class',
            categoryName: 'Mengajar',
            subject: 'Teknik Komputer - XII IPS 2',
            checkIn: '06:55',
            checkOut: '08:25',
            status: 'hadir',
            note: '-'
        }
    ];

    // Apply filters
    let filteredData = sampleData;

    if (month) {
        filteredData = filteredData.filter(item => {
            // Simple month filter based on sample data
            return item.date.includes(getMonthName(month));
        });
    }

    if (teacher) {
        filteredData = filteredData.filter(item => {
            const teacherNames = ['Budi Santoso', 'Siti Aminah', 'Ahmad Dahlan', 'Dewi Sartika', 'Eko Prasetyo'];
            return item.teacher === teacherNames[parseInt(teacher) - 1];
        });
    }

    if (status) {
        filteredData = filteredData.filter(item => item.status === status);
    }

    if (category) {
        filteredData = filteredData.filter(item => item.category === category);
    }

    return filteredData;
}

// Get month name in Indonesian
function getMonthName(monthNumber) {
    const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[parseInt(monthNumber)] || '';
}

// Update report table
function updateReportTable(data) {
    const tableBody = document.getElementById('reportTableBody');
    tableBody.innerHTML = '';

    data.forEach(item => {
        const row = document.createElement('tr');

        row.innerHTML = `
            <td>${item.date}</td>
            <td>${item.day}</td>
            <td>
                <div class="teacher-info">
                    <img src="https://placehold.co/30x30" alt="Guru">
                    <span>${item.teacher}</span>
                </div>
            </td>
            <td><span class="category-badge ${item.category}">${item.categoryName}</span></td>
            <td>${item.subject}</td>
            <td>${item.checkIn}</td>
            <td>${item.checkOut}</td>
            <td><span class="status-badge ${item.status}">${getStatusText(item.status)}</span></td>
            <td>${item.note}</td>
        `;

        tableBody.appendChild(row);
    });
}

// Get status text in Indonesian
function getStatusText(status) {
    const statusMap = {
        'hadir': 'Hadir',
        'telat': 'Telat',
        'permit': 'Izin/Sakit',
        'alpha': 'Alpha'
    };
    return statusMap[status] || status;
}

// Update summary cards
function updateSummary(data) {
    const totalDays = new Set(data.map(item => item.date)).size;
    const totalPresent = data.filter(item => item.status === 'hadir').length;
    const totalLate = data.filter(item => item.status === 'telat').length;
    const totalPermit = data.filter(item => item.status === 'permit').length;
    const totalAbsent = data.filter(item => item.status === 'alpha').length;

    document.getElementById('totalDays').textContent = totalDays;
    document.getElementById('totalPresent').textContent = totalPresent;
    document.getElementById('totalLate').textContent = totalLate;
    document.getElementById('totalPermit').textContent = totalPermit;
    document.getElementById('totalAbsent').textContent = totalAbsent;
}

// Export to Excel
function exportToExcel() {
    showLoading();

    // Simulate export process
    setTimeout(() => {
        hideLoading();
        showNotification('Data berhasil diekspor ke Excel');

        // In real app, this would generate and download an Excel file
        const data = getTableData();
        console.log('Export to Excel:', data);
    }, 1000);
}

// Export to PDF
function exportToPDF() {
    showLoading();

    // Simulate export process
    setTimeout(() => {
        hideLoading();
        showNotification('Data berhasil diekspor ke PDF');

        // In real app, this would generate and download a PDF file
        const data = getTableData();
        console.log('Export to PDF:', data);
    }, 1000);
}

// Print report
function printReport() {
    showNotification('Mempersiapkan halaman untuk dicetak...');

    // Get current month and year for header
    const month = document.getElementById('monthFilter').value;
    const year = document.getElementById('yearFilter').value;

    // Create print header
    const monthNames = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    const monthName = month ? monthNames[parseInt(month)] : 'Desember';
    const yearName = year || '2025';
    const headerText = `Laporan Presensi Bulan ${monthName} ${yearName}`;

    // Create a temporary header element for printing
    const printHeader = document.createElement('div');
    printHeader.className = 'print-header';
    printHeader.innerHTML = `
        <h1>${headerText}</h1>
        <p>Dicetak pada: ${new Date().toLocaleDateString('id-ID')}</p>
    `;

    // Get the report section
    const reportSection = document.querySelector('.report-section');

    // Clone the report section for printing
    const printContent = reportSection.cloneNode(true);

    // Create a new window for printing
    const printWindow = window.open('', '_blank');

    // Create the print document
    printWindow.document.write(`
        <!DOCTYPE html>
        <html lang="id">
        <head>
            <meta charset="UTF-8">
            <title>Cetak Laporan Presensi</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    margin: 20px;
                    color: #333;
                }
                .print-header {
                    text-align: center;
                    margin-bottom: 30px;
                    border-bottom: 2px solid #333;
                    padding-bottom: 10px;
                }
                .print-header h1 {
                    margin: 0;
                    font-size: 24px;
                }
                .print-header p {
                    margin: 5px 0 0;
                    font-size: 14px;
                    color: #666;
                }
                .section-title {
                    font-size: 18px;
                    font-weight: bold;
                    margin-bottom: 15px;
                }
                table {
                    width: 100%;
                    border-collapse: collapse;
                    margin-bottom: 20px;
                }
                th, td {
                    border: 1px solid #ddd;
                    padding: 8px;
                    text-align: left;
                }
                th {
                    background-color: #f2f2f2;
                    font-weight: bold;
                }
                .teacher-info {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                }
                .teacher-info img {
                    width: 30px;
                    height: 30px;
                    border-radius: 50%;
                }
                .status-badge {
                    padding: 4px 8px;
                    border-radius: 12px;
                    font-size: 11px;
                    font-weight: 600;
                    text-transform: uppercase;
                }
                .status-badge.present {
                    background: #dcfce7;
                    color: #166534;
                }
                .status-badge.late {
                    background: #fef3c7;
                    color: #d97706;
                }
                .status-badge.permit {
                    background: #dbeafe;
                    color: #1e40af;
                }
                .status-badge.alpha {
                    background: #fee2e2;
                    color: #b91c1c;
                }
                @media print {
                    body {
                        margin: 10px;
                    }
                    .print-header {
                        margin-bottom: 20px;
                    }
                }
            </style>
        </head>
        <body>
            <div class="print-header">
                <h1>${headerText}</h1>
                <p>Dicetak pada: ${new Date().toLocaleDateString('id-ID')}</p>
            </div>
            <div class="section-title">Detail Presensi</div>
            ${printContent.querySelector('.table-container').innerHTML}
        </body>
        </html>
    `);

    printWindow.document.close();

    // Wait for the content to load, then print
    setTimeout(() => {
        printWindow.print();
        printWindow.close();
    }, 500);
}

// Get table data for export
function getTableData() {
    const rows = document.querySelectorAll('#reportTableBody tr');
    const data = [];

    rows.forEach(row => {
        const cells = row.querySelectorAll('td');
        data.push({
            date: cells[0].textContent,
            day: cells[1].textContent,
            teacher: cells[2].querySelector('span').textContent,
            subject: cells[3].textContent,
            checkIn: cells[4].textContent,
            checkOut: cells[5].textContent,
            status: cells[6].textContent,
            note: cells[7].textContent
        });
    });

    return data;
}

// Show loading state
function showLoading() {
    const buttons = document.querySelectorAll('.btn');
    buttons.forEach(btn => {
        if (btn.textContent.includes('Export') || btn.textContent.includes('Cetak')) {
            btn.classList.add('loading');
        }
    });
}

// Hide loading state
function hideLoading() {
    const buttons = document.querySelectorAll('.btn');
    buttons.forEach(btn => {
        btn.classList.remove('loading');
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

// Close modal
function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    modal.classList.add('hidden');
}

// Add CSS for ripple and notification animations
const style = document.createElement('style');
style.textContent = `
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