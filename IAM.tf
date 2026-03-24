############################################
# EKS Control Plane IAM Role
############################################
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "eks-cluster-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

############################################
# EKS Worker Node IAM Role
############################################
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

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

  tags = {
    Name = "eks-node-role"
  }
}


resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2-ssm-role-${var.env}"

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

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "ssm_logging_policy" {
  name = "ssm-session-logging-policy-${var.env}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "${aws_cloudwatch_log_group.ssm_sessions.arn}:*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_logging_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = aws_iam_policy.ssm_logging_policy.arn
}

resource "aws_iam_role_policy_attachment" "eks_ssm" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

#####################################
# IAM for ALB to access S3 for logging 
#####################################

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket_policy" "alb_logs_policy" {
  bucket = aws_s3_bucket.alb_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowALBWrite"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_elb_service_account.main.arn
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/alb/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}


#######################
# IAM for Jenkins
#######################

############################################
# Jenkins IAM Role
############################################

resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com" # change if using something else
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

############################################
# Jenkins Policy (Terraform + EKS)
############################################

resource "aws_iam_policy" "jenkins_policy" {
  name = "jenkins-eks-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      {
        Sid    = "EC2AndNetworking"
        Effect = "Allow"
        Action = [
          "ec2:*",
          "elasticloadbalancing:*",
          "autoscaling:*"
        ]
        Resource = "*"
      },

      {
        Sid    = "IAMPermissions"
        Effect = "Allow"
        Action = [
          "iam:PassRole",
          "iam:GetRole",
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy",
          "iam:ListRoles",
          "iam:ListAttachedRolePolicies"
        ]
        Resource = "*"
      },

      {
        Sid    = "EKSAccess"
        Effect = "Allow"
        Action = [
          "eks:*"
        ]
        Resource = "*"
      },

      {
        Sid    = "ECRAccess"
        Effect = "Allow"
        Action = [
          "ecr:*"
        ]
        Resource = "*"
      },

      {
        Sid    = "S3StateAccess"
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = "*"
      },

      {
        Sid    = "CloudWatchAccess"
        Effect = "Allow"
        Action = [
          "logs:*",
          "cloudwatch:*"
        ]
        Resource = "*"
      }
    ]
  })
}

############################################
# Attach Policy to Role
############################################

resource "aws_iam_role_policy_attachment" "jenkins_attach" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_policy.arn
}

############################################
# Instance Profile (for EC2 Jenkins)
############################################

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.jenkins_role.name
}

############################################
# Output
############################################

output "jenkins_role_arn" {
  value = aws_iam_role.jenkins_role.arn
}