provider "aws" {
  region = "us-east-1" 
}

# 1. Create the Data Lake (S3 Bucket)
resource "aws_s3_bucket" "guardian_data_lake" {
  bucket = "guardian-eye-data-lake-${random_id.id.hex}"
}

resource "random_id" "id" {
  byte_length = 4
}

# 2. Create the Network (VPC)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "guardian-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

# 3. Create the VPC Lattice Service Network
resource "aws_vpclattice_service_network" "guardian_net" {
  name      = "guardian-service-net"
  auth_type = "AWS_IAM" # Only authorized AI agents can talk to each other
}

# 4. Associate your VPC with the Service Network
resource "aws_vpclattice_service_network_vpc_association" "guardian_vpc_assoc" {
  service_network_identifier = aws_vpclattice_service_network.guardian_net.id
  vpc_identifier             = module.vpc.vpc_id
}

# Output the S3 Bucket Name and Lattice ID for your records
output "data_lake_name" {
  value = aws_s3_bucket.guardian_data_lake.id
}

output "service_network_id" {
  value = aws_vpclattice_service_network.guardian_net.id
}

# 5. Create the EKS Cluster (Auto Mode)
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0" # Using the latest 2026 standard

  name    = "guardian-perception-cluster"
  kubernetes_version = "1.31"

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

# 6. The Model Registry (ECR)
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
