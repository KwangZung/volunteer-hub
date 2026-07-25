# frontend/Dockerfile

# Stage 1: Build source Vite
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Serve bằng Nginx cực nhẹ
FROM nginx:alpine
# Xóa thư mục html mặc định của nginx
RUN rm -rf /usr/share/nginx/html/*
# Copy custom Nginx config hỗ trợ SPA Routing
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Copy source đã build (thường Vite build ra folder dist) sang Nginx
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]