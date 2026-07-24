terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config" # Sử dụng config mặc định của k3d
}

# Tạo Namespace
resource "kubernetes_namespace" "prod" {
  metadata {
    name = var.namespace
  }
}

# Tạo Secret chứa mật khẩu MongoDB
resource "kubernetes_secret" "mongo_auth" {
  metadata {
    name      = "mongodb-secret"
    namespace = kubernetes_namespace.prod.metadata[0].name
  }

  data = {
    MONGO_INITDB_ROOT_USERNAME = var.mongo_user
    MONGO_INITDB_ROOT_PASSWORD = var.mongo_password
    MONGO_URI                  = "mongodb://${var.mongo_user}:${var.mongo_password}@volunteerhub-mongodb:27017/admin"
  }

  type = "Opaque"
}