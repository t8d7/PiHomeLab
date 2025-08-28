output "deployment_name" {
  description = "Name of the Kubernetes deployment"
  value       = kubernetes_deployment.webapp.metadata[0].name
}

output "service_name" {
  description = "Name of the Kubernetes service"
  value       = kubernetes_service.webapp.metadata[0].name
}

output "service_type" {
  description = "Type of the Kubernetes service"
  value       = kubernetes_service.webapp.spec[0].type
}

output "node_port" {
  description = "NodePort for external access"
  value       = var.service_type == "NodePort" ? kubernetes_service.webapp.spec[0].port[0].node_port : null
}

output "cluster_ip" {
  description = "Cluster IP of the service"
  value       = kubernetes_service.webapp.spec[0].cluster_ip
}

output "namespace" {
  description = "Kubernetes namespace"
  value       = var.k8s_namespace
}
