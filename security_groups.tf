############################################
# EKS Cluster Security Group
############################################
resource "aws_security_group" "eks_cluster_sg" {
  name        = "eks-cluster-sg"
  description = "Security group for EKS control plane"
  vpc_id      = aws_vpc.main_vpc.id

  tags = {
    Name = "eks-cluster-sg"
  }
}

# Allow worker nodes to talk to control plane
resource "aws_security_group_rule" "cluster_ingress_nodes" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  description              = "Worker nodes to EKS API server"
}

# Allow control plane outbound
resource "aws_security_group_rule" "cluster_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_cluster_sg.id
}

############################################
# EKS Worker Nodes Security Group
############################################
resource "aws_security_group" "eks_nodes_sg" {
  name        = "eks-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.main_vpc.id

  tags = {
    Name = "eks-nodes-sg"
  }
}

# Node-to-node communication (required for Kubernetes)
resource "aws_security_group_rule" "nodes_ingress_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.eks_nodes_sg.id
  description       = "Allow node-to-node communication"
}

# Allow control plane to reach kubelet & pods
resource "aws_security_group_rule" "nodes_ingress_cluster" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes_sg.id
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  description              = "EKS control plane to worker nodes"
}

# Worker nodes outbound access
resource "aws_security_group_rule" "nodes_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes_sg.id
}




resource "aws_security_group" "aurora_sg" {
  name        = "postgres-db-sg"
  description = "Aurora PostgreSQL security group"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description     = "Postgres from application tier"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster_sg.id]
  }

  egress {
    description = "Outbound (patching, monitoring)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "postgres-db-sg"
  }
}

resource "aws_security_group" "ssm_endpoints_sg" {
  name   = "ssm-endpoints-sg"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    description = "Allow EC2 in VPC to access SSM endpoints"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssm-endpoints-sg"
  }
}



