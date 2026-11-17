/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        game: {
          bg: '#0a0d14',
          card: '#121722',
          border: '#232b3e',
          accent: '#e6a23c',
          gold: '#ffd04b',
          hero: '#ff4d4f',
          legend: '#9b59b6',
          cyber: '#00d2ff',
          text: '#e1e7f0',
          muted: '#7d8a9e',
        }
      },
      boxShadow: {
        'glow-gold': '0 0 15px rgba(255, 208, 75, 0.4)',
        'glow-hero': '0 0 15px rgba(255, 77, 79, 0.4)',
        'glow-cyan': '0 0 15px rgba(0, 210, 255, 0.35)',
      }
    },
  },
  plugins: [],
}
