import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'
import nexy from "./__nexy__/vite"

export default defineConfig({
  plugins: [
    nexy(), 
    tailwindcss(),
    react(),
    vue()
  ],
  customLogger: nexy.log(),
})