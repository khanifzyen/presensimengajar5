/** @type {import('tailwindcss').Config} */
export default {
    content: ["./app/**/*.{js,jsx,ts,tsx}", "./components/**/*.{js,jsx,ts,tsx}", "./src/**/*.{js,jsx,ts,tsx}"],
    theme: {
        extend: {
            colors: {
                primary: '#1e3a8a',
                secondary: '#3b82f6',
                success: '#10b981',
                warning: '#f59e0b',
                danger: '#ef4444',
                info: '#3b82f6',
                light: '#f3f4f6',
                dark: '#1f2937',
                background: '#ffffff',
                surface: '#f8fafc',
                border: '#e5e7eb',
                text: {
                    primary: '#1f2937',
                    secondary: '#6b7280',
                    light: '#9ca3af'
                }
            }
        }
    },
    plugins: [],
};