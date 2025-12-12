/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#22C55E',
          dark: '#16A34A',
          light: '#4ADE80',
        },
        sidebar: {
          DEFAULT: '#1F2937',
          light: '#374151',
        }
      },
    },
  },
  plugins: [],
}
