variable "do_token" {
  type        = string
  description = "Access Token for Digital Ocean"
  sensitive   = true
}

variable "cluster_name" {
  type        = string
  description = "The name of the kubernetes cluster to create"
  default     = "wedding-app"
}

# variable "hostname" {
#   type        = string
#   description = "Hostname of website"
#   default     = "charrington.xyz"
# }

# variable "mongodb_uri" {
#   type        = string
#   description = "Mongo database URI"
#   sensitive   = true
# }
