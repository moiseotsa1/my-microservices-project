import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    host: true,
    proxy: {
      '/user-service': {
        target: 'http://api-gateway',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/user-service/, '/user-service')
      },
      '/product-service': {
        target: 'http://api-gateway', 
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/product-service/, '/product-service')
      },
      '/order-service': {
        target: 'http://api-gateway',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/order-service/, '/order-service')
      }
    }
  }
})
