// js/navigation.js
document.addEventListener('DOMContentLoaded', function () {
    // Add smooth scrolling to all internal links
    const internalLinks = document.querySelectorAll('a[href^="#"], a[href$=".html"]');

    internalLinks.forEach(link => {
        link.addEventListener('click', function (e) {
            // Skip if it's an external link or has target="_blank"
            if (this.getAttribute('target') === '_blank' || this.hostname !== window.location.hostname) {
                return;
            }

            // Add page transition class to body
            document.body.classList.add('page-transitioning');

            // Remove the class after a short delay to allow for smooth transition
            setTimeout(() => {
                document.body.classList.remove('page-transitioning');
            }, 300);
        });
    });

    // Handle bottom navigation active states
    const currentPage = window.location.pathname.split('/').pop();
    const navLinks = document.querySelectorAll('.bottom-nav a');

    navLinks.forEach(link => {
        const href = link.getAttribute('href');
        if (href === currentPage || (currentPage === '' && href === 'index.html')) {
            link.classList.add('active');
        } else {
            link.classList.remove('active');
        }
    });

    // Add touch feedback for mobile
    const touchElements = document.querySelectorAll('.btn, .bottom-nav a, .menu-item');

    touchElements.forEach(element => {
        element.addEventListener('touchstart', function () {
            this.style.transform = 'scale(0.95)';
        });

        element.addEventListener('touchend', function () {
            this.style.transform = 'scale(1)';
        });
    });

    // Optimize scrolling performance
    let ticking = false;

    function updateScrollEffects() {
        // Add any scroll-based effects here
        ticking = false;
    }

    document.querySelector('.screen-content').addEventListener('scroll', function () {
        if (!ticking) {
            window.requestAnimationFrame(updateScrollEffects);
            ticking = true;
        }
    });
});

// Add CSS for page transitions
const style = document.createElement('style');
style.textContent = `
    .page-transitioning {
        opacity: 0.8;
        transition: opacity 0.3s ease;
    }
    
    .screen-content {
        -webkit-overflow-scrolling: touch;
        scroll-behavior: smooth;
    }
    
    /* Prevent momentum scrolling from bouncing on iOS */
    @media screen and (max-width: 767px) {
        .screen-content {
            overscroll-behavior: contain;
        }
    }
`;
document.head.appendChild(style);