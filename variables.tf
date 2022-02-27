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

# variable "letsencrypt_email" {
#   type        = string
#   description = "Email for letsencrypt"
#   default     = "starlightromero@protonmail.com"
# }

# variable "hostname" {
#   type        = string
#   description = "Hostname of website"
#   default     = "charrington.xyz"
# }

variable "mongodb_uri" {
  type        = string
  description = "Mongo database URI"
  sensitive   = true
}

variable "mongo_initdb_database" {
  type        = string
  description = "Mongo database Name"
  sensitive   = true
}

variable "mongo_initdb_username" {
  type        = string
  description = "Mongo database username"
  sensitive   = true
}

variable "mongo_initdb_password" {
  type        = string
  description = "Mongo database password"
  sensitive   = true
}
