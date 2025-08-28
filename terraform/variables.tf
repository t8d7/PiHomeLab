variable "k8s_namespace" {
  description = "Kubernetes namespace for deployments"
  type        = string
  default     = "default"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "t8d-webapp"
}

variable "app_image" {
  description = "Container image for the application"
  type        = string
  default     = "t8d-webapp-image:latest"
}

variable "app_replicas" {
  description = "Number of application replicas"
  type        = number
  default     = 3
}

variable "app_port" {
  description = "Application container port"
  type        = number
  default     = 3000
}

variable "service_type" {
  description = "Kubernetes service type"
  type        = string
  default     = "NodePort"
  validation {
    condition     = contains(["ClusterIP", "NodePort", "LoadBalancer"], var.service_type)
    error_message = "Service type must be ClusterIP, NodePort, or LoadBalancer."
  }
}

variable "node_port" {
  description = "NodePort for external access (30000-32767)"
  type        = number
  default     = 30080
  validation {
    condition     = var.node_port >= 30000 && var.node_port <= 32767
    error_message = "NodePort must be between 30000 and 32767."
  }
}
