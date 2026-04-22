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



