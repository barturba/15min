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
          primary: '#1e3a8a',
          secondary: '#0f172a',
          accent: '#2563eb',
          light: '#dbeafe',
          dark: '#0f172a',
        },
        timer: {
          work: '#1e3a8a',
          break: '#10b981',
          warning: '#f59e0b',
          danger: '#ef4444',
        }
      },
    },
  },
  plugins: [],
}
