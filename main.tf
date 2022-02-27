data "digitalocean_loadbalancer" "this" {
  name = "${var.cluster_name}-lb"
}

resource "kubernetes_namespace" "wedding_app" {
  metadata {
    name = var.cluster_name
  }
}

# resource "helm_release" "cert_manager" {
#   name       = "cert-manager"
#   repository = "https://charts.jetstack.io"
#   chart      = "cert-manager"
#   version    = "v1.7.1"
#   namespace  = "kube-system"
#   set {
#     name  = "createCustomResource"
#     value = "true"
#   }
#   set {
#     name  = "installCRDs"
#     value = "true"
#   }
# }

# resource "kubernetes_manifest" "cluster_issuer" {
#   depends_on = [
#     helm_release.cert_manager,
#   ]

#   manifest = {
#     "apiVersion" = "cert-manager.io/v1"
#     "kind"       = "ClusterIssuer"
#     "metadata" = {
#       "name" = "letsencrypt-production"
#     }
#     spec = {
#       acme = {
#         email  = "starlightromero@protonmail.com"
#         server = "https://acme-v02.api.letsencrypt.org/directory"
#         privateKeySecretRef = {
#           name = "letsencrypt-production"
#         }
#         solvers = [
#           {
#             http01 = {
#               ingress = {
#                 class = "nginx"
#               }
#             }
#           }
#         ]
#       }
#     }
#   }
# }

resource "helm_release" "nginx_ingress_chart" {
  name       = "nginx-ingress-controller"
  namespace  = var.cluster_name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "service.annotations.kubernetes\\.digitalocean\\.com/load-balancer-id"
    value = data.digitalocean_loadbalancer.this.id
  }
}

resource "kubernetes_ingress" "ingress" {
  depends_on = [
    helm_release.nginx_ingress_chart,
  ]
  metadata {
    name      = "${var.cluster_name}-ingress"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/ingress.class"          = "nginx"
      "ingress.kubernetes.io/rewrite-target" = "/"
      # "cert-manager.io/cluster-issuer"       = "letsencrypt-production"
    }
  }
  spec {
    rule {
      host = var.hostname
      http {
        path {
          backend {
            service_name = kubernetes_service.wedding.metadata[0].name
            service_port = 80
          }
          path = "/"
        }
      }
    }
    # tls {
    #   secret_name = "letsencrypt-production"
    #   hosts       = [var.hostname]
    # }
  }
}

resource "kubernetes_ingress" "ingress_admin" {
  depends_on = [
    helm_release.nginx_ingress_chart,
  ]
  metadata {
    name      = "${var.cluster_name}-ingress-admin"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/ingress.class"          = "nginx"
      "ingress.kubernetes.io/rewrite-target" = "/"
      # "cert-manager.io/cluster-issuer"                     = "letsencrypt-production"
      "nginx.ingress.kubernetes.io/whitelist-source-range" = "75.128.58.244/32"
    }
  }
  spec {
    rule {
      host = var.hostname
      http {
        path {
          backend {
            service_name = kubernetes_service.wedding.metadata[0].name
            service_port = 80
          }
          path = "/rsvp"
        }
      }
    }
    # tls {
    #   secret_name = "letsencrypt-production"
    #   hosts       = [var.hostname]
    # }
  }
}

resource "kubernetes_service" "wedding" {
  metadata {
    name      = "wedding"
    namespace = var.cluster_name
  }

  spec {
    selector = {
      app = kubernetes_deployment.wedding.metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 8080
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "wedding" {
  metadata {
    name      = "wedding"
    namespace = var.cluster_name
    labels = {
      app = "wedding"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "wedding"
      }
    }

    template {
      metadata {
        labels = {
          app = "wedding"
        }
      }

      spec {
        container {
          image             = "starlightromero/wedding-app"
          name              = "wedding-app"
          image_pull_policy = "Always"

          port {
            container_port = 8080
          }

          env {
            name  = "MONGODB_URI"
            value = var.mongodb_uri
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8080
            }

            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }
      }
    }
  }
}
