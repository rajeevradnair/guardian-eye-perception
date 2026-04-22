# 1. Create the EKS Cluster (Auto Mode)
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0" # Using the latest 2026 standard

  name    = "guardian-perception-cluster"
  kubernetes_version = "1.35"

  endpoint_public_access = true
  endpoint_private_access = true

  # The "Auto Mode" Magic: AWS manages nodes like Karpenter
  compute_config = {
    enabled    = true
    node_pools = ["general-purpose", "system"] 
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Enables your current IAM user to be the Cluster Admin
  enable_cluster_creator_admin_permissions = true
  
  # Crucial for 2026: Simplifies IAM for your AI pods
  enable_irsa = true 
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

# 2. The K8s Registry (ECR)
resource "aws_ecr_repository" "guardian_perception" {
  name                 = "guardian-perception"
  image_tag_mutability = "MUTABLE"
  force_delete         = true 
  
  image_scanning_configuration {
    scan_on_push = true
  }
}

output "ecr_url" {
  value = aws_ecr_repository.guardian_perception.repository_url
}