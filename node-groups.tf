
resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "eks-ng-default"
  node_role_arn  = aws_iam_role.eks_node_role.arn
  subnet_ids     = aws_subnet.private_subnet[*].id

  ami_type       = "AL2_x86_64"
  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.small"]

  scaling_config {
    desired_size = 3
    min_size     = 2
    max_size     = 15
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "worker"
  }

  tags = {
    Name = "eks-node-group-default"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node,
    aws_iam_role_policy_attachment.eks_cni,
    aws_iam_role_policy_attachment.eks_ecr
  ]
}
