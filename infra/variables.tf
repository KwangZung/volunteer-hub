variable "namespace" {
  type    = string
  default = "volunteerhub-prod"
}

variable "mongo_user" {
  type    = string
  default = "admin"
}

variable "mongo_password" {
  type      = string
  sensitive = true
}