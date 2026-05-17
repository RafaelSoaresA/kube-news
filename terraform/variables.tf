variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "Nome do cluster DOKS"
  type        = string
  default     = "k8s-aula"
}

variable "region" {
  description = "Região DigitalOcean"
  type        = string
  default     = "nyc1"
}

variable "node_size" {
  description = "Slug do tamanho dos nós (doctl compute size list)"
  type        = string
  default     = "s-2vcpu-2gb"
}

variable "node_count" {
  description = "Número de nós no node pool"
  type        = number
  default     = 2
}

variable "k8s_version" {
  description = "Versão Kubernetes exata (doctl kubernetes options versions)"
  type        = string
  default     = "1.35.1-do.6"
}
