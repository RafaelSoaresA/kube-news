resource "digitalocean_kubernetes_cluster" "main" {
  name    = var.cluster_name
  region  = var.region
  version = var.k8s_version

  node_pool {
    name       = "pool-mgaxya0xq"
    size       = var.node_size
    node_count = var.node_count
  }
}
