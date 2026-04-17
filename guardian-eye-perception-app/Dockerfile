# Using the 2026 optimized PyTorch base for AWS
FROM 763104351884.dkr.ecr.us-east-1.amazonaws.com/pytorch-inference:2.3.0-gpu-py311-cu121-ubuntu20.04-ec2

WORKDIR /app
COPY . .

RUN pip install ultralytics fastapi uvicorn
EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]