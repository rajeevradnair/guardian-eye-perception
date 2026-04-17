# System Architecture

Guardian Eye is designed as a **cloud-native perception microservice**. Unlike monolithic vision applications, it cleanly separates the **compute-heavy inference engine** from the **infrastructure management layer**, improving **high availability**, **fault tolerance**, and operational flexibility.

## Core Components

### Perception Engine
A **Python-based microservice** built with **FastAPI** wraps **YOLO11** and exposes RESTful endpoints for:

- real-time image analysis
- inference requests
- system health monitoring

This makes the model easy to integrate with other services while keeping deployment lightweight and modular.

### Orchestration Layer
The service runs on **Amazon EKS**, where Kubernetes manages scaling, recovery, and deployment lifecycle. It uses:

- **Helm** for package management and repeatable deployment
- **Liveness probes** to detect stalled or unhealthy inference processes
- **Readiness probes** to ensure the model is ready before traffic is routed to it

### Infrastructure as Code
The entire cloud environment is provisioned through **Terraform**, making the platform fully reproducible and easier to manage across environments. Managed resources include:

- VPC
- subnets
- EKS cluster
- supporting cloud infrastructure

This approach reduces manual setup errors and enables consistent deployments.

### Networking
Guardian Eye uses **VPC Lattice** for secure **service-to-service communication**. This allows the perception engine to communicate with downstream systems such as safety, decisioning, or planning modules without exposing internal traffic to the public internet.

---

## Reliability & Resilience

### Self-Healing
The platform uses **Kubernetes liveness probes** to automatically detect and restart stalled inference containers. This helps the service recover from transient failures without manual intervention.

### Traffic Management
**Readiness probes** prevent cold-start failures by ensuring that **YOLO11 model weights are fully loaded into memory** before the service begins accepting requests. This protects callers from hitting a pod that is technically running but not yet ready to serve inference.

### Resource Throttling
The deployment is configured with explicit **CPU and memory requests/limits** to:

- prevent noisy-neighbor issues
- stabilize runtime performance
- protect matrix multiplication workloads during peak inference demand

This leads to more predictable performance under load and better cluster resource isolation.