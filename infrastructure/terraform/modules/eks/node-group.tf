resource "aws_eks_node_group" "eks_node_group" {
  cluster_name      = var.eks_cluster.name
  node_group_name   = "${var.eks_cluster_name}-node-group"
  node_role_arn     = aws_iam_role.eks_nodes_role.arn
  subnet_ids        = var.public_subnet_ids

  instance_types    = [var.eks_node_instance_type]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_nodes_cni_policy,
    aws_iam_role_policy_attachment.eks_nodes_worker_policy,
    aws_iam_role_policy_attachment.eks_nodes_ecr_policy,
  ]
}
# -----------------------------------------------
# Launch Template
# -----------------------------------------------
resource "aws_launch_template" "eks_nodes_lt" {
  name = "${var.eks_cluster_name}-nodes-lt"

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name = "${var.eks_cluster_name}-node"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(local.common_tags, {
      Name = "${var.eks_cluster_name}-node-volume"
    })
  }
}
# -----------------------------------------------
# Node IAM Role
# -----------------------------------------------
resource "aws_iam_role" "eks_nodes_role" {
  name = "${var.eks_cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "eks_nodes_worker_policy" {
  role       = aws_iam_role.eks_nodes_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_nodes_cni_policy" {
  role       = aws_iam_role.eks_nodes_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_nodes_ecr_policy" {
  role       = aws_iam_role.eks_nodes_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
# -----------------------------------------------
# Node Security Group
# -----------------------------------------------
resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.eks_cluster_name}-nodes-sg"
  description = "EKS worker nodes security group"
  vpc_id      = var.vpc_id

  # Nodes talk to each other freely
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # Control plane reaches nodes on kubelet + NodePort range
  ingress {
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster_sg.id]
    description     = "Control plane to nodes"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}