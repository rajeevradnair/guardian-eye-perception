from ultralytics import YOLO
import json

# 1. Load the "V1" model we registered yesterday
model = YOLO("yolo11s.pt")

# 2. Run validation on a test set (e.g., 'coco8.yaml' is a tiny subset for testing)
metrics = model.val(data="coco8.yaml") 

# 3. Extract the metrics SageMaker cares about
report_dict = {
    "detection_metrics": {
        "mAP50-95": {"value": metrics.box.map, "standard_deviation": "NaN"},
        "mAP50": {"value": metrics.box.map50, "standard_deviation": "NaN"},
        "precision": {"value": metrics.box.mp, "standard_deviation": "NaN"},
    },
}

# 4. Save as a SageMaker-compatible evaluation file
with open("yolo11s_evaluation.json", "w") as f:
    json.dump(report_dict, f)