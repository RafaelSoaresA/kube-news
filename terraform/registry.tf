resource "digitalocean_container_registry" "main" {
  name                   = "kube-news-rafael"
  subscription_tier_slug = "starter"
  region                 = "nyc3"
}
