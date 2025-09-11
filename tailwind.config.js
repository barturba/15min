/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          primary: '#0d1f0d',
          secondary: '#1a4d1a',
          accent: '#00ff41',
          light: '#e8f5e8',
          dark: '#0d1f0d',
        },
        matrix: {
          deep: '#0d1f0d',
          medium: '#1a4d1a',
          bright: '#00ff41',
          electric: '#39ff14',
        },
        timer: {
          work: '#00ff41',
          break: '#10b981',
          warning: '#f59e0b',
          danger: '#ef4444',
        }
      },
    },
  },
  plugins: [],
}
