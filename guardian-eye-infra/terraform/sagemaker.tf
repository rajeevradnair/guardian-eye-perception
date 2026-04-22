# 1. Define the Model Package Group (The "Folder" for our model versions)
resource "aws_sagemaker_model_package_group" "guardian_perception" {
  model_package_group_name        = "guardian-perception-group"
  model_package_group_description = "Registry for Guardian Eye YOLO11 perception models"

  tags = {
    Project = "GuardianEye"
    Stage   = "Foundation"
  }
}

# 2. IAM Role for SageMaker (The "Identity" that allows SageMaker to work)
resource "aws_iam_role" "sagemaker_execution_role" {
  name = "guardian-sagemaker-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "sagemaker.amazonaws.com"
      }
    }]
  })
}

# 3. Attach basic SageMaker access to the role
resource "aws_iam_role_policy_attachment" "sagemaker_full_access" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

# 4. Define the Feature Group for Perception Data
resource "aws_sagemaker_feature_group" "perception_features" {
  feature_group_name             = "guardian-perception-features"
  record_identifier_feature_name = "vehicle_id"  # The "Primary Key"
  event_time_feature_name        = "event_time"  # The "Timestamp" for lineage
  role_arn                       = aws_iam_role.sagemaker_execution_role.arn

  # Column 1: Which vehicle is reporting this?
  feature_definition {
    feature_name = "vehicle_id"
    feature_type = "String"
  }

  # Column 2: When did this happen? (Required for Feature Stores)
  feature_definition {
    feature_name = "event_time"
    feature_type = "Fractional"
  }

  # Column 3: The count of objects detected by YOLO
  feature_definition {
    feature_name = "object_count"
    feature_type = "Integral"
  }

  # Column 4: A calculated score of how dangerous the scene is
  feature_definition {
    feature_name = "hazard_score"
    feature_type = "Fractional"
  }

  # Online Store: High-speed lookups for the EKS Pod
  online_store_config {
    enable_online_store = true
  }

  # Offline Store: Long-term storage in your S3 Data Lake for training
  offline_store_config {
    s3_storage_config {
      s3_uri = "s3://guardian-eye-data-lake-22a265a8/feature-store/"
    }
  }
}

# 5. Policy for S3 Data Lake access (Fixes the 403 Forbidden error)
resource "aws_iam_policy" "sagemaker_s3_access" {
  name        = "guardian-sagemaker-s3-access"
  description = "Allows SageMaker to manage the Offline Feature Store in S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketAcl",
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::guardian-eye-data-lake-22a265a8",
          "arn:aws:s3:::guardian-eye-data-lake-22a265a8/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "glue:CreateDatabase",
          "glue:CreateTable",
          "glue:GetDatabase",
          "glue:GetTable",
          "glue:GetPartitions",
          "glue:UpdateTable"
        ]
        Resource = "*" # Required for Feature Store to create the Glue Catalog tables
      }
    ]
  })
}

# 6. Attach the S3 Custom Policy to the SageMaker Role
resource "aws_iam_role_policy_attachment" "sagemaker_s3_attach" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = aws_iam_policy.sagemaker_s3_access.arn
}

# 7. Attach the AWS Managed Feature Store Policy (Required for internal buffering)
resource "aws_iam_role_policy_attachment" "sagemaker_feature_store_attach" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFeatureStoreAccess"
}