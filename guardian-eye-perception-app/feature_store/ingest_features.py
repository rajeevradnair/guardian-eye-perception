import boto3
import time
from datetime import datetime

sm_feature_store = boto3.client('sagemaker-featurestore-runtime')

def put_perception_record(vehicle_id, count, score):
    # Every record needs a current timestamp in ISO format or fractional seconds
    current_time = time.time()
    
    # SageMaker Feature Store expects data as a list of name-value pairs (as strings)
    record = [
        {'FeatureName': 'vehicle_id', 'ValueAsString': str(vehicle_id)},
        {'FeatureName': 'event_time', 'ValueAsString': str(current_time)},
        {'FeatureName': 'object_count', 'ValueAsString': str(count)},
        {'FeatureName': 'hazard_score', 'ValueAsString': str(score)}
    ]

    response = sm_feature_store.put_record(
        FeatureGroupName='guardian-perception-features',
        Record=record
    )
    return response

if __name__ == "__main__":
    # Simulating data coming from your YOLO model
    print("Ingesting simulated road data to Feature Store...")
    res = put_perception_record("unit-alpha-01", 12, 0.85)
    print(f"Success! Response Code: {res['ResponseMetadata']['HTTPStatusCode']}")