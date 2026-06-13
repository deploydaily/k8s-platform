# -----------------------------------------------
# EKS Access Entry — grant deploying user cluster admin
# -----------------------------------------------
# TEMPORARY for sandbox: uses caller identity to auto-detect
# the IAM principal running Terraform and grants admin access.
#
# In sk8s, this is NOT needed because:
# - Cluster access is managed via RBAC (rbac-*.tf, 7 files)
# - aws-auth ConfigMap maps ADFS roles → K8s groups
# - Jenkins/ArgoCD have dedicated IAM roles with access entries
# - Developers get access via ADFS group membership, not direct IAM
# - No single user is hardcoded — access is role-based
# -----------------------------------------------
data "aws_caller_identity" "current" {}

resource "aws_eks_access_entry" "deployer" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = data.aws_caller_identity.current.arn
  type          = "STANDARD"

  tags = local.common_tags
}

resource "aws_eks_access_policy_association" "deployer_admin" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = data.aws_caller_identity.current.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.deployer]
}
