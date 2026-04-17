from fastapi import FastAPI
from ultralytics import YOLO
import torch

app = FastAPI()

# Load YOLO11 - Choosing the 'Small' variant for speed
model = YOLO("yolo11s.pt") 

@app.get("/health")
def health():
    # Principal Logic: Check if GPU is actually being used
    cuda_available = torch.cuda.is_available()
    return {"status": "online", "gpu_active": cuda_available}

@app.post("/analyze")
async def analyze(image_url: str):
    results = model(image_url)
    return {"objects": results[0].summary()}