variable "project_name" {
  description   = "Project Name — used in resource names and subnet tags"
  type          = string
  default       = "nt-infra"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"
}

variable "eks_cluster_name" {
  description = "EKS cluster name — used in all resource names and tags"
  type        = string
}