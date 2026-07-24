# backend/Dockerfile
FROM node:20-alpine
WORKDIR /app

# Copy file cấu hình và cài đặt TẤT CẢ thư viện (bao gồm cả tsx)
COPY package*.json ./
RUN npm install

# Copy toàn bộ mã nguồn
COPY . .

EXPOSE 3000

# Chạy trực tiếp bằng tsx thay vì node thuần
CMD ["npx", "tsx", "server.ts"]