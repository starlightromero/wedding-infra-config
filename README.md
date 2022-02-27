# Wedding Infra

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.1.6 |
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | 2.17.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.4.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.8.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | 2.17.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.4.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.8.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.cert_manager](https://registry.terraform.io/providers/hashicorp/helm/2.4.1/docs/resources/release) | resource |
| [helm_release.nginx_ingress_chart](https://registry.terraform.io/providers/hashicorp/helm/2.4.1/docs/resources/release) | resource |
| [kubernetes_deployment.wedding](https://registry.terraform.io/providers/hashicorp/kubernetes/2.8.0/docs/resources/deployment) | resource |
| [kubernetes_ingress.ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/2.8.0/docs/resources/ingress) | resource |
| [kubernetes_ingress.ingress_admin](https://registry.terraform.io/providers/hashicorp/kubernetes/2.8.0/docs/resources/ingress) | resource |
| [kubernetes_manifest.cluster_issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/2.8.0/docs/resources/manifest) | resource |
| [kubernetes_namespace.wedding_app](https://registry.terraform.io/providers/hashicorp/kubernetes/2.8.0/docs/resources/namespace) | resource |
| [kubernetes_service.wedding](https://registry.terraform.io/providers/hashicorp/kubernetes/2.8.0/docs/resources/service) | resource |
| [digitalocean_kubernetes_cluster.this](https://registry.terraform.io/providers/digitalocean/digitalocean/2.17.0/docs/data-sources/kubernetes_cluster) | data source |
| [digitalocean_loadbalancer.this](https://registry.terraform.io/providers/digitalocean/digitalocean/2.17.0/docs/data-sources/loadbalancer) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the kubernetes cluster to create | `string` | `"wedding-app"` | no |
| <a name="input_do_token"></a> [do\_token](#input\_do\_token) | Access Token for Digital Ocean | `string` | n/a | yes |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | Hostname of website | `string` | `"charrington.xyz"` | no |
| <a name="input_mongodb_uri"></a> [mongodb\_uri](#input\_mongodb\_uri) | Mongo database URI | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
