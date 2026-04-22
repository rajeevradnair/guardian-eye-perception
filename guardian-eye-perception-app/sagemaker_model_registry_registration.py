import boto3
import time

sm_client = boto3.client('sagemaker')

# Configuration
GROUP_NAME = "guardian-perception-group"
MODEL_S3_URI = "s3://guardian-eye-data-lake-22a265a8/models/perception/v1/model.tar.gz"
# Use a standard PyTorch inference image provided by AWS
IMAGE_URI = "763104351884.dkr.ecr.us-east-1.amazonaws.com/pytorch-inference:2.1.0-cpu-py310"

def register_yolo_model():
    print(f"Registering model version in {GROUP_NAME}...")
    
    model_package_input = {
        "ModelPackageGroupName": GROUP_NAME,
        "ModelPackageDescription": "Initial YOLO11s weights for Guardian Eye Foundation",
        "ModelApprovalStatus": "PendingManualApproval",
        "InferenceSpecification": {
            "Containers": [
                {
                    "Image": IMAGE_URI,
                    "ModelDataUrl": MODEL_S3_URI
                }
            ],
            "SupportedContentTypes": ["image/jpeg", "image/png"],
            "SupportedResponseMIMETypes": ["application/json"],
            "SupportedRealtimeInferenceInstanceTypes": ["ml.t2.medium", "ml.m5.large"],
        }
    }

    response = sm_client.create_model_package(**model_package_input)
    print(f"Success! Model Package ARN: {response['ModelPackageArn']}")

if __name__ == "__main__":
    register_yolo_model()