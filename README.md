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
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.8.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_deployment.wedding](https://registry.terraform.io/providers/hashicorp/kubernetes/2.8.0/docs/resources/deployment) | resource |
| [kubernetes_namespace.wedding_app](https://registry.terraform.io/providers/hashicorp/kubernetes/2.8.0/docs/resources/namespace) | resource |
| [kubernetes_service.mongo](https://registry.terraform.io/providers/hashicorp/kubernetes/2.8.0/docs/resources/service) | resource |
| [kubernetes_service.wedding](https://registry.terraform.io/providers/hashicorp/kubernetes/2.8.0/docs/resources/service) | resource |
| [kubernetes_stateful_set.mongo](https://registry.terraform.io/providers/hashicorp/kubernetes/2.8.0/docs/resources/stateful_set) | resource |
| [digitalocean_kubernetes_cluster.this](https://registry.terraform.io/providers/digitalocean/digitalocean/2.17.0/docs/data-sources/kubernetes_cluster) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the kubernetes cluster to create | `string` | `"wedding-app"` | no |
| <a name="input_do_token"></a> [do\_token](#input\_do\_token) | Access Token for Digital Ocean | `string` | n/a | yes |
| <a name="input_mongo_initdb_database"></a> [mongo\_initdb\_database](#input\_mongo\_initdb\_database) | Mongo database Name | `string` | n/a | yes |
| <a name="input_mongo_initdb_password"></a> [mongo\_initdb\_password](#input\_mongo\_initdb\_password) | Mongo database password | `string` | n/a | yes |
| <a name="input_mongo_initdb_username"></a> [mongo\_initdb\_username](#input\_mongo\_initdb\_username) | Mongo database username | `string` | n/a | yes |
| <a name="input_mongodb_uri"></a> [mongodb\_uri](#input\_mongodb\_uri) | Mongo database URI | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
