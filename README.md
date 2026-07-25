# VolunteerHub

VolunteerHub là một ứng dụng web kết nối tình nguyện viên với các hoạt động xã hội. Hệ thống bao gồm Frontend (React/Vite), Backend (Node.js) và Database (MongoDB).

**Video chạy thử nghiệm (Demo):**

[Demo Video](./demo-video.mkv)

## Kiến trúc Hệ thống

Dự án hiện tại được thiết kế theo hướng Cloud-Native và vận hành hoàn toàn trên Kubernetes Cluster thông qua quy trình CI/CD hiện đại:

- **Frontend & Backend**: Giao tiếp thông qua đường dẫn tương đối (ví dụ: `/api/...`) thay vì hardcode tên miền.
- **Ingress Controller**: Sử dụng Traefik (tích hợp trong k3d) để phân luồng request. Các request có tiền tố `/api` sẽ được chuyển hướng tới Backend Pod, các request còn lại được xử lý bởi Frontend Pod.
- **Infrastructure as Code**: Terraform được sử dụng để khởi tạo Namespace và bảo mật Secret cho cơ sở dữ liệu.
- **Đóng gói ứng dụng**: Toàn bộ cấu hình hệ thống được quản lý và triển khai qua Helm Chart.
- **Continuous Integration**: GitHub Actions tự động hóa quá trình Build Docker Image, quét lỗ hổng (Trivy), tạo SBOM (Syft), ký số Image (Cosign) và đẩy lên GitHub Container Registry (GHCR).
- **Continuous Deployment**: ArgoCD triển khai mô hình GitOps, giám sát folder chứa cấu hình trên repo nhánh `main` và đồng bộ (Sync) tự động xuống Kubernetes Cluster.

---

## Hướng dẫn Triển khai (Môi trường Local với k3d)

### 1. Yêu cầu hệ thống

Trước khi bắt đầu, ta cần cài đặt các công cụ sau trên máy:
- Docker & k3d (để tạo Kubernetes Cluster cục bộ).
- kubectl (để tương tác với Cluster).
- Terraform (để triển khai IaC).
- Helm (quản lý package Kubernetes).
- ArgoCD (cài đặt sẵn trên Cluster).

### 2. Khởi tạo hạ tầng bằng Terraform

Sử dụng Terraform để cấp phát Namespace và inject các thông tin nhạy cảm (Secret) vào hệ thống.
Từ thư mục gốc của dự án, đi vào folder `infra` và chạy lệnh:

```bash
cd infra/
terraform init
terraform apply --auto-approve
```
Lệnh này sẽ tạo ra Namespace `volunteerhub-prod` và các Secret bảo mật chứa thông tin kết nối MongoDB.

### 3. Vận hành luồng CI/CD (GitHub Actions)

Mọi thay đổi trên mã nguồn Frontend hoặc Backend cần được đẩy lên GitHub để tự động hóa quy trình xây dựng:

```bash
git add .
git commit -m "feat: add new features"
git push
```
Mở tab Actions trên GitHub để theo dõi tiến trình Build, Scan lỗ hổng, Sign (ký điện tử) và Push Image mới lên GHCR.

### 4. Triển khai ứng dụng qua ArgoCD (GitOps)

- Hệ thống ArgoCD trong Cluster đã được cấu hình sẵn để theo dõi folder `charts/volunteerhub`.
- Ngay khi có thay đổi trên nhánh `main`, ArgoCD sẽ tự động áp dụng (Sync) Helm Chart xuống Kubernetes.
- Lưu ý: Vì Kubernetes sử dụng `imagePullPolicy: Always` cùng với tag `:latest`, nếu cấu trúc Helm không thay đổi mà chỉ có Image mới được đẩy lên, ta có thể chủ động ra lệnh cho Kubernetes kéo Image mới nhất bằng cách chạy:

```bash
kubectl rollout restart deployment volunteerhub-backend -n volunteerhub-prod
kubectl rollout restart deployment volunteerhub-frontend -n volunteerhub-prod
```

### 5. Truy cập Ứng dụng

Mở trình duyệt và truy cập vào địa chỉ Ingress đã được ánh xạ tới cổng của Host:

👉 `http://localhost:8081`

- Mọi lời gọi API từ Frontend tới Backend sẽ được Ingress tự động định tuyến thông qua `/api/...`.
- Tính năng đăng nhập (như Google Auth) sẽ hoạt động bình thường, không bị lỗi CORS do mọi request đều đi qua cùng một cổng Ingress.

### 6. Dọn dẹp tài nguyên (Cleanup)

Sau khi hoàn thành thử nghiệm và muốn giải phóng tài nguyên trên máy, ta có thể xóa các thành phần đã tạo thông qua Terraform và Helm:

```bash
# Xóa ArgoCD Application trước để nó không tự động phục hồi tài nguyên
kubectl delete -f argocd-app.yaml

# Di chuyển vào thư mục hạ tầng
cd infra/

# Ra lệnh cho Terraform hủy toàn bộ Namespace và Secret
terraform destroy --auto-approve

# Xóa toàn bộ phần mềm ArgoCD khỏi K8s Cluster (Tùy chọn nếu muốn gỡ sạch)
kubectl delete namespace argocd
```

*(Việc dùng `terraform destroy` sẽ xóa đi toàn bộ Namespace `volunteerhub-prod`, kéo theo tất cả các Pod, Service, Ingress và PVC bên trong nó bị dọn dẹp sạch sẽ)*
