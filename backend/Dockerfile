# backend/Dockerfile

# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
# Chỉ copy package.json trước để tận dụng cache của Docker
COPY package*.json ./
RUN npm ci
# Copy toàn bộ code và build
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
# Chỉ cài các thư viện thật sự cần thiết chạy trên prod
RUN npm ci --only=production
# Copy thư mục dist đã build từ stage 1 sang
COPY --from=builder /app/dist ./dist

# Mở port (thường Node.js chạy port 3000, 5000 hoặc 8080 tùy bạn config)
EXPOSE 3000
CMD ["npm", "start"]