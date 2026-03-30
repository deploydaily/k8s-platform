# -----------------------------------------------
# EKS Cluster
# -----------------------------------------------
resource "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  vpc_config {
    subnet_ids = var.public_subnet_ids
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}
# -----------------------------------------------
# Cluster IAM Role
# -----------------------------------------------
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-ntinfra"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      },
    ]
  })
}
# -----------------------------------------------
# Attach EKSClusterPolicy to EKS cluster role
# -----------------------------------------------
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}
# -----------------------------------------------
# Cluster Security Group
# -----------------------------------------------
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.eks_cluster_name}-cluster-sg"
  description = "EKS control plane security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# -----------------------------------------------
# Allow nodes to reach control plane on 443
# -----------------------------------------------
resource "aws_security_group_rule" "eks_cluster_ingress_nodes" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  description              = "Nodes to control plane"
}