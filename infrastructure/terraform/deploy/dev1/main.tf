module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
}

module "eks" {
  source = "../../modules/eks"

  eks_cluster_name    = var.eks_cluster_name
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  kubernetes_version  = var.kubernetes_version
}