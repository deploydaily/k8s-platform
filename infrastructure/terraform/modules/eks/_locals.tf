locals {
  common_tags = {
    Project     = "k8s-platform"
    Environment = var.environment
    ManagedBy   = "terraform"
    Cluster     = var.eks_cluster_name
  }
}