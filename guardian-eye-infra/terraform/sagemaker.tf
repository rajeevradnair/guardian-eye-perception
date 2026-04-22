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