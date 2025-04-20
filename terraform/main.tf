resource "kubernetes_deployment" "t8d-webapp" {
    metadata {
        name      = "t8d-webapp"
        namespace = "default"
    },
    spec {
        replicas = 3
        selector {
            match_labels = {
                app = "t8d-webapp"
            }
        }
        template {
            metadata {
                labels = {
                    app = "t8d-webapp"
                }
            }
            spec {
                container {
                    name  = "t8d-webapp"
                    image = "t8d-webapp-image:latest"
                    port {
                        container_port = 80
                    }
                }
            }
        }
    }
}