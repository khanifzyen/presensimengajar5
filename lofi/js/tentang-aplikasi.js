// js/tentang-aplikasi.js
document.addEventListener('DOMContentLoaded', function () {
    // Add some interactive elements
    animateElements();

    // Add version info dynamically
    updateVersionInfo();
});

// Animate elements on page load
function animateElements() {
    const elements = document.querySelectorAll('.feature-item, .tech-item, .version-card');
    elements.forEach((element, index) => {
        element.style.opacity = '0';
        element.style.transform = 'translateY(20px)';

        setTimeout(() => {
            element.style.transition = 'all 0.5s ease-out';
            element.style.opacity = '1';
            element.style.transform = 'translateY(0)';
        }, index * 100); // Stagger animation
    });
}

// Update version info dynamically
function updateVersionInfo() {
    const versionElement = document.querySelector('.version-number');
    const releaseDateElement = document.querySelector('.release-date');

    if (versionElement) {
        // You could fetch this from an API or config file
        const currentVersion = 'v1.0.0';
        const buildDate = new Date('2025-12-01');

        versionElement.textContent = currentVersion;

        if (releaseDateElement) {
            const options = { year: 'numeric', month: 'long', day: 'numeric' };
            releaseDateElement.textContent = `Dirilis: ${buildDate.toLocaleDateString('id-ID', options)}`;
        }
    }
}

// Add click interactions for feature items
document.addEventListener('click', function (e) {
    const featureItem = e.target.closest('.feature-item');
    if (featureItem) {
        // Add ripple effect
        createRipple(featureItem, e);

        // Show feature details (optional enhancement)
        const featureName = featureItem.querySelector('h4')?.textContent;
        console.log(`Feature clicked: ${featureName}`);
    }
});

// Create ripple effect
function createRipple(element, event) {
    const ripple = document.createElement('span');
    const rect = element.getBoundingClientRect();
    const size = Math.max(rect.width, rect.height);
    const x = event.clientX - rect.left - size / 2;
    const y = event.clientY - rect.top - size / 2;

    ripple.style.width = ripple.style.height = size + 'px';
    ripple.style.left = x + 'px';
    ripple.style.top = y + 'px';
    ripple.classList.add('ripple');

    // Add ripple styles if not already added
    if (!document.querySelector('#ripple-styles')) {
        const style = document.createElement('style');
        style.id = 'ripple-styles';
        style.textContent = `
            .feature-item {
                position: relative;
                overflow: hidden;
            }
            
            .ripple {
                position: absolute;
                border-radius: 50%;
                background: rgba(30, 58, 138, 0.1);
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
    }

    element.appendChild(ripple);

    setTimeout(() => {
        ripple.remove();
    }, 600);
}

// Add some additional interactivity
document.addEventListener('DOMContentLoaded', function () {
    // Add hover effects for developer buttons
    const buttons = document.querySelectorAll('.developer-actions button');
    buttons.forEach(button => {
        button.addEventListener('mouseenter', function () {
            this.style.transform = 'translateY(-2px)';
            this.style.boxShadow = '0 4px 8px rgba(0, 0, 0, 0.1)';
        });

        button.addEventListener('mouseleave', function () {
            this.style.transform = 'translateY(0)';
            this.style.boxShadow = 'none';
        });
    });

    // Add click feedback
    buttons.forEach(button => {
        button.addEventListener('click', function () {
            // Add haptic feedback simulation
            if (navigator.vibrate) {
                navigator.vibrate(50);
            }

            // Visual feedback
            this.style.transform = 'scale(0.95)';
            setTimeout(() => {
                this.style.transform = 'scale(1)';
            }, 150);
        });
    });
});