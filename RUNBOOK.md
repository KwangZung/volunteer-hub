# Cẩm nang xử lý sự cố (Runbook) - VolunteerHub

## 1. Hệ thống sập (Downtime toàn phần)
- **Triệu chứng:** Truy cập `https://volunteerhub.local` báo lỗi 502/503 hoặc timeout.
- **Cách xử lý:**
  1. Kiểm tra trạng thái K8s cluster: `kubectl get nodes` (Cluster/k3d có đang bật không?)
  2. Kiểm tra Ingress có hoạt động bình thường và đúng IP hay không: `kubectl get ingress -n volunteerhub-prod`.
  3. Kiểm tra trạng thái Pods: `kubectl get pods -n volunteerhub-prod`. Nếu Pod bị `CrashLoopBackOff`, dùng `kubectl logs <pod-name> -n volunteerhub-prod` để xem log lỗi chi tiết bên trong.

## 2. Lỗi kết nối Database (MongoDB)
- **Triệu chứng:** Giao diện tải được tĩnh nhưng báo lỗi API fetch hoặc Backend log báo `MongoTimeoutError`.
- **Cách xử lý:**
  1. Kiểm tra StatefulSet: `kubectl get statefulset -n volunteerhub-prod` xem đã Ready `1/1` chưa.
  2. Kiểm tra kết nối mạng nội bộ của Cluster: Dùng 1 pod tạm để ping thử: `kubectl run -it --rm --image=busybox dns-test -- sh` -> gõ `ping volunteerhub-mongodb.volunteerhub-prod.svc.cluster.local`.
  3. Kiểm tra Secret Password có bị sai thông tin so với app hay không: `kubectl get secret mongodb-secret -n volunteerhub-prod -o yaml`.