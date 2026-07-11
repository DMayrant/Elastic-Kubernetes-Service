
resource "aws_eks_cluster" "main" {
  name     = "eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.29"

  vpc_config {
    subnet_ids = aws_subnet.private_subnet[*].id

    security_group_ids = [
      aws_security_group.eks_cluster_sg.id
    ]

    endpoint_private_access = true
    endpoint_public_access  = true # production Env this must be set to false 

     public_access_cidrs = ["71.105.19.72/32"] # only allow /32 cidr to give One public IP address access to Kubernetes API  
    # curl ifconfig.me
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name = "EKS"
  }
}

