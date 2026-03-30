variable "eks_cluster_name" {
  description = "EKS cluster name — used in all resource names and tags"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"
}

variable "vpc_id" {
  description = "VPC ID — passed from VPC module output"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs — control plane ENIs and nodes go here"
  type        = list(string)
}

variable "eks_node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "eks_node_desired" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "eks_node_min" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "eks_node_max" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  type    = string
  default = "us-east-1"
}