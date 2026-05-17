output "cluster_id" {
  description = "ID do cluster DOKS"
  value       = digitalocean_kubernetes_cluster.main.id
}

output "cluster_endpoint" {
  description = "Endpoint da API do cluster"
  value       = digitalocean_kubernetes_cluster.main.endpoint
}

output "cluster_version" {
  description = "Versão Kubernetes em uso"
  value       = digitalocean_kubernetes_cluster.main.version
}

output "kubeconfig" {
  description = "Kubeconfig para acesso ao cluster (use: terraform output -raw kubeconfig > kubeconfig.yaml)"
  value       = digitalocean_kubernetes_cluster.main.kube_config[0].raw_config
  sensitive   = true
}
