data "digitalocean_loadbalancer" "this" {
  name = "${var.cluster_name}-lb"
}

resource "kubernetes_namespace" "wedding_app" {
  metadata {
    name = "wedding-app"
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.6.1"
  namespace  = "kube-system"
  timeout    = 120
  set {
    name  = "createCustomResource"
    value = "true"
  }
  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "cluster_issuer" {
  name      = "cluster-issuer"
  chart     = "./helm_charts/cluster-issuer"
  namespace = "kube-system"
  depends_on = [
    helm_release.cert_manager,
  ]
  set {
    name  = "letsencrypt_email"
    value = var.letsencrypt_email
  }
}

resource "helm_release" "nginx_ingress_chart" {
  name       = "nginx-ingress-controller"
  namespace  = "wedding-app"
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
    namespace = "wedding-app"
    annotations = {
      "kubernetes.io/ingress.class"          = "nginx"
      "ingress.kubernetes.io/rewrite-target" = "/"
      "cert-manager.io/cluster-issuer"       = "letsencrypt-production"
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
    tls {
      secret_name = "letsencrypt-production"
      hosts       = [var.hostname]
    }
  }
}

resource "kubernetes_ingress" "ingress_admin" {
  depends_on = [
    helm_release.nginx_ingress_chart,
  ]
  metadata {
    name      = "${var.cluster_name}-ingress-admin"
    namespace = "wedding-app"
    annotations = {
      "kubernetes.io/ingress.class"                        = "nginx"
      "ingress.kubernetes.io/rewrite-target"               = "/"
      "cert-manager.io/cluster-issuer"                     = "letsencrypt-production"
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
    tls {
      secret_name = "letsencrypt-production"
      hosts       = [var.hostname]
    }
  }
}

resource "kubernetes_service" "wedding" {
  metadata {
    name      = "wedding"
    namespace = "wedding-app"
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
    namespace = "wedding-app"
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
          image = "starlightromero/wedding-app"
          name  = "wedding-app"
          port {
            container_port = 8080
          }
          image_pull_policy = "Always"

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

resource "kubernetes_service" "mongo" {
  metadata {
    name      = "mongo"
    namespace = "wedding-app"
  }

  spec {
    selector = {
      app = kubernetes_stateful_set.mongo.metadata[0].labels.app
    }
    port {
      port        = 27017
      target_port = 27017
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_stateful_set" "mongo" {
  metadata {
    name      = "mongo"
    namespace = "wedding-app"
    labels = {
      app = "mongo"
    }
  }

  spec {
    pod_management_policy = "Parallel"
    replicas              = 3

    selector {
      match_labels = {
        name = "mongo"
      }
    }

    service_name = "mongo"

    template {
      metadata {
        labels = {
          name = "mongo"
        }

        annotations = {}
      }

      spec {
        service_account_name             = "mongo"
        termination_grace_period_seconds = 300

        container {
          name              = "mongo"
          image             = "mongo"
          image_pull_policy = "IfNotPresent"

          args = [
            "mongo",
            "--bind_ip",
            "0.0.0.0",
            "--replSet",
            "MainRepSet"
          ]

          port {
            container_port = 27017
          }

          volume_mount {
            name       = "mongo-persistent-storage-claim"
            mount_path = "/data/db"
          }

          resources {
            limits = {
              cpu    = "0.2"
              memory = "200Mi"
            }

            requests = {
              cpu    = "0.2"
              memory = "200Mi"
            }
          }
        }

        volume {
          name = "mongo"

          config_map {
            name = "mongo"
          }
        }
      }
    }

    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 1
      }
    }

    volume_claim_template {
      metadata {
        name = "mongo-persistent-storage-claim"

        annotations = {
          "volume.beta.kubernetes.io/storage-class" = "standard"
        }
      }

      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "standard"

        resources {
          requests = {
            storage = "1Gi"
          }
        }
      }
    }
  }
}