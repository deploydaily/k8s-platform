output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL — needed for IRSA roles"
  value       = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

output "node_role_arn" {
  value = aws_iam_role.eks_nodes_role.arn
}

output "cluster_security_group_id" {
  value = aws_security_group.eks_cluster_sg.id
}

output "node_security_group_id" {
  value = aws_security_group.eks_nodes_sg.id
}