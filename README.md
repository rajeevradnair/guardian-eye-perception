System Architecture
Guardian Eye is designed as a cloud-native perception microservice. Unlike monolithic vision apps, it separates the compute-heavy inference engine from the infrastructure management layer, ensuring high availability and fault tolerance.

Core Components
Perception Engine: A Python-based microservice using FastAPI to wrap YOLO11. It exposes RESTful endpoints for real-time image analysis and system health monitoring.

Orchestration Layer: Hosted on Amazon EKS (Elastic Kubernetes Service). It leverages Helm for package management and Kubernetes Probes (Liveness/Readiness) to manage the lifecycle of the AI model.

Infrastructure as Code (IaC): 100% of the cloud environment—including the VPC, Subnets, and EKS Cluster—is provisioned via Terraform for full reproducibility.

Networking: Implements VPC Lattice for secure, service-to-service communication, allowing the perception engine to integrate with downstream safety and planning modules without exposing internal traffic to the public internet.

Reliability & Resilience
Self-Healing: The system automatically detects and restarts stalled inference processes via Liveness probes.

Traffic Management: Readiness probes prevent "cold-start" failures by ensuring the YOLO11 weights are fully loaded into memory before the service accepts traffic.

Resource Throttling: Configured with specific CPU and Memory requests/limits to prevent "noisy neighbor" issues and ensure stable matrix multiplication during peak inference loads.