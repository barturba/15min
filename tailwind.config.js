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
          primary: '#2563eb',
          secondary: '#1e40af',
          accent: '#3b82f6',
          light: '#dbeafe',
          dark: '#1e3a8a',
        },
        timer: {
          work: '#2563eb',
          break: '#10b981',
          warning: '#f59e0b',
          danger: '#ef4444',
        }
      },
    },
  },
  plugins: [],
}
