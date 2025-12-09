// js/panduan.js
document.addEventListener('DOMContentLoaded', function () {
    // Auto-expand first category on load
    const firstCategory = document.querySelector('.category-content');
    if (firstCategory) {
        firstCategory.classList.remove('hidden');
        document.querySelector('.category-header').classList.add('active');
    }

    // Initialize search functionality
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.addEventListener('input', debounce(searchGuide, 300));
    }
});

// Toggle category expansion
function toggleCategory(categoryId) {
    const categoryContent = document.getElementById(categoryId);
    const categoryHeader = categoryContent.previousElementSibling;
    const arrow = categoryHeader.querySelector('.category-arrow');

    // Close all other categories
    const allCategories = document.querySelectorAll('.category-content');
    const allHeaders = document.querySelectorAll('.category-header');
    const allArrows = document.querySelectorAll('.category-arrow');

    allCategories.forEach(cat => {
        if (cat.id !== categoryId) {
            cat.classList.add('hidden');
        }
    });

    allHeaders.forEach(header => {
        if (header !== categoryHeader) {
            header.classList.remove('active');
        }
    });

    allArrows.forEach(arr => {
        if (arr !== arrow) {
            arr.style.transform = 'rotate(0deg)';
        }
    });

    // Toggle current category
    if (categoryContent.classList.contains('hidden')) {
        categoryContent.classList.remove('hidden');
        categoryHeader.classList.add('active');
        arrow.style.transform = 'rotate(180deg)';
    } else {
        categoryContent.classList.add('hidden');
        categoryHeader.classList.remove('active');
        arrow.style.transform = 'rotate(0deg)';
    }
}

// Search guide content
function searchGuide() {
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();
    const guideItems = document.querySelectorAll('.guide-item');
    const categories = document.querySelectorAll('.guide-category');

    if (searchTerm === '') {
        // Reset all items
        guideItems.forEach(item => {
            item.innerHTML = item.innerHTML.replace(/<span class="search-highlight">(.*?)<\/span>/g, '$1');
            item.style.display = 'block';
        });

        // Show all categories
        categories.forEach(cat => {
            cat.style.display = 'block';
        });

        return;
    }

    let hasResults = false;

    // Search through guide items
    guideItems.forEach(item => {
        const text = item.textContent.toLowerCase();
        const title = item.querySelector('h4')?.textContent.toLowerCase() || '';
        const description = item.querySelector('p')?.textContent.toLowerCase() || '';

        // Remove previous highlights
        item.innerHTML = item.innerHTML.replace(/<span class="search-highlight">(.*?)<\/span>/g, '$1');

        if (title.includes(searchTerm) || description.includes(searchTerm)) {
            // Highlight matching text
            if (title.includes(searchTerm)) {
                const h4 = item.querySelector('h4');
                h4.innerHTML = h4.textContent.replace(
                    new RegExp(searchTerm, 'gi'),
                    match => `<span class="search-highlight">${match}</span>`
                );
            }

            if (description.includes(searchTerm)) {
                const p = item.querySelector('p');
                p.innerHTML = p.textContent.replace(
                    new RegExp(searchTerm, 'gi'),
                    match => `<span class="search-highlight">${match}</span>`
                );
            }

            item.style.display = 'block';
            hasResults = true;

            // Expand parent category
            const category = item.closest('.guide-category');
            if (category) {
                category.style.display = 'block';
                const categoryContent = item.closest('.category-content');
                if (categoryContent) {
                    categoryContent.classList.remove('hidden');
                    const categoryHeader = categoryContent.previousElementSibling;
                    const arrow = categoryHeader.querySelector('.category-arrow');
                    categoryHeader.classList.add('active');
                    arrow.style.transform = 'rotate(180deg)';
                }
            }
        } else {
            item.style.display = 'none';
        }
    });

    // Hide categories with no results
    categories.forEach(cat => {
        const visibleItems = cat.querySelectorAll('.guide-item[style="display: block;"], .guide-item:not([style*="display: none"])');
        if (visibleItems.length === 0) {
            cat.style.display = 'none';
        }
    });

    // Show no results message
    if (!hasResults) {
        showNoResults();
    } else {
        hideNoResults();
    }
}

// Show no results message
function showNoResults() {
    const container = document.querySelector('.guide-container');

    // Remove existing message
    const existingMessage = container.querySelector('.no-results');
    if (existingMessage) {
        existingMessage.remove();
    }

    // Add no results message
    const noResultsDiv = document.createElement('div');
    noResultsDiv.className = 'no-results';
    noResultsDiv.innerHTML = `
        <div style="text-align: center; padding: 40px 20px; background: white; border-radius: 12px; margin: 20px 0;">
            <i class="fas fa-search" style="font-size: 48px; color: #d1d5db; margin-bottom: 15px;"></i>
            <h3 style="color: var(--text-main); margin-bottom: 10px;">Tidak Ada Hasil</h3>
            <p style="color: var(--grey-dark); font-size: 14px;">Tidak ada panduan yang cocok dengan pencarian Anda.</p>
        </div>
    `;
    container.appendChild(noResultsDiv);
}

// Hide no results message
function hideNoResults() {
    const noResults = document.querySelector('.no-results');
    if (noResults) {
        noResults.remove();
    }
}

// Debounce function for search
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Add CSS for search highlights and no results
const style = document.createElement('style');
style.textContent = `
    .no-results {
        animation: fadeIn 0.3s ease-out;
    }
    
    .guide-item {
        transition: all 0.3s ease;
    }
    
    .guide-category {
        transition: all 0.3s ease;
    }
`;
document.head.appendChild(style);