# Serverless E-Commerce Microservices on Google Cloud Platform

A production-ready, fully automated serverless e-commerce platform demonstrating secure API Gateway integration with Cloud Armor, deployed entirely through Infrastructure as Code (Terraform) and CI/CD (Cloud Build).

---

## Overview

This project implements a complete serverless microservices architecture on Google Cloud Platform (GCP), featuring:

* 4 containerized microservices (Frontend, Product, Order, Inventory) running on Cloud Run
* API Gateway with OpenAPI 2.0 specification for API management
* Cloud Armor security policy automatically injecting API keys
* External HTTP(S) Load Balancer with path-based routing
* Complete CI/CD pipeline using Cloud Build
* Infrastructure as Code using Terraform with remote state management

The architecture demonstrates enterprise-grade patterns for securing APIs, managing microservices, and automating deployments in a serverless environment.

---

## Why This Project Exists

Building secure, scalable microservices architectures on cloud platforms involves numerous challenges that developers and DevOps teams face daily. This project was created to provide a complete, working reference implementation that solves real-world problems encountered when:

1. Securing API Gateways without exposing API keys in client code
2. Integrating Cloud Armor with API Gateway for header injection
3. Deploying serverless NEGs (Network Endpoint Groups) correctly
4. Managing Terraform state in CI/CD pipelines
5. Orchestrating multi-service deployments with proper dependencies
6. Implementing path-based routing at the Load Balancer level

### Common Challenges Include:

* API Gateway returning 401 even through Load Balancer
* Cloud Armor policy not injecting headers correctly
* Serverless NEG configuration errors with timeout parameters
* Terraform state conflicts in Cloud Build runs
* Backend services showing as unhealthy
* Resource already exists errors in Terraform
* Manual API enablement steps breaking automation
* Circular dependencies in infrastructure code

This project solves all of these issues with proven, production-tested code.

---

## Key Challenges Addressed

### 1. API Gateway Security Without Client-Side Keys

Problem: Traditional API key authentication requires clients to include keys in requests, exposing them in client code or network traffic.

Solution: Cloud Armor automatically injects the API key header (`x-api-key`) for all requests passing through the Load Balancer, while direct API Gateway access remains blocked.

### 2. Serverless NEG Configuration

Problem: Serverless Network Endpoint Groups for API Gateway don't support `timeout_sec` parameter, causing Terraform errors.

Solution: Properly configured serverless NEG using `serverless_deployment` block without timeout parameters.

### 3. Terraform State Management in CI/CD

Problem: Local Terraform state files are lost between Cloud Build runs, causing Resource already exists errors.

Solution: GCS backend for Terraform with versioning enabled, plus intelligent resource import logic in the pipeline.

### 4. Complete API Enablement Automation

Problem: Many GCP APIs need manual enablement before infrastructure deployment.

Solution: Terraform automatically enables all required APIs with proper dependency management and wait times.

### 5. Zero-Downtime Deployments

Problem: Updating services causes downtime and requires manual intervention.

Solution: Cloud Run's built-in blue-green deployment with health checks, orchestrated through Cloud Build.

---

## Problems Solved

### Security

* No exposed API keys - Keys never leave GCP infrastructure
* Defense in depth - Multiple layers of security (Load Balancer, Cloud Armor, API Gateway)
* Automatic key rotation - Keys managed by Terraform, rotatable via redeployment
* Direct access blocked - API Gateway rejects requests without valid keys (401)

### Operations

* Fully automated deployments - One git push deploys everything
* No manual steps - Zero console clicking required
* Idempotent pipeline - Safe to re-run at any time
* Smoke testing - Automatic health checks after deployment

### Development

* Clear separation of concerns - Each service is independent
* Easy to extend - Add new services by following existing patterns
* Local development friendly - Services run standalone
* Comprehensive logging - Cloud Logging integration built-in

### Cost Optimization

* Pay-per-use model - Cloud Run scales to zero
* No idle resource costs - Serverless architecture
* Efficient caching - Docker layer caching reduces build times
* Resource limits - Configured memory/CPU constraints

---

## How the Solution Works

### Architecture Flow

```text
Internet
    ↓
External HTTP(S) Load Balancer
    ├── /        → Frontend Service (Cloud Run)
    └── /api/*   → Cloud Armor → API Gateway
                                         ├── Product Service
                                         ├── Order Service
                                         └── Inventory Service
```

### Security Model

Scenario 1: Request via Load Balancer

```text
1. User → http://LB_IP/api/products
2. Load Balancer routes request
3. Cloud Armor injects x-api-key
4. API Gateway validates key
5. Backend service returns response
```

Scenario 2: Direct API Gateway Access

```text
1. User → https://gateway-url/api/products
2. API Gateway validates request
3. Missing x-api-key
4. 401 Unauthorized response
```

### CI/CD Pipeline

The Cloud Build pipeline executes in three phases:

Phase 1: Container Builds

* Build Docker images
* Push images to Artifact Registry

Phase 2: Infrastructure Deployment

* Terraform Init
* Terraform Validate
* Terraform Plan
* Terraform Apply

Phase 3: Validation

* Enable API Gateway managed service
* Smoke testing
* Load Balancer health verification

---

## Key Features

### Infrastructure

* Fully serverless architecture
* Auto-scaling Cloud Run services
* Multi-region deployment capability
* Cost-optimized resource usage

### Security

* API key authentication
* Cloud Armor integration
* Automated header injection
* Secure backend routing

### DevOps

* GitOps deployment workflow
* Remote Terraform state management
* Parallelized Cloud Build pipeline
* Automated rollback support

### Observability

* Cloud Logging integration
* Cloud Monitoring support
* Request tracing
* Health checks and monitoring

### Developer Experience

* Modular Terraform structure
* Reusable infrastructure components
* Template-based configuration management
* Easy customization through variables

---

## Prerequisites

### Required Tools

* gcloud CLI
* Git
* GitHub Account

### GCP Requirements

* GCP Project with billing enabled
* Owner or Editor role permissions
* GitHub repository connected to Cloud Build

### APIs

* Cloud Run API
* Compute Engine API
* API Gateway API
* Cloud Build API
* Artifact Registry API
* API Keys API
* Cloud Resource Manager API

---

## Repository Structure

```text
.
├── README.md
├── bootstrap.sh
├── cloudbuild.yaml
│
├── services/
│   ├── product-service/
│   ├── order-service/
│   ├── inventory-service/
│   └── frontend-service/
│
└── infra/
    ├── f1-versions.tf
    ├── f2-generic-variables.tf
    ├── f3-local-variables.tf
    ├── f4-apis.tf
    ├── f5-artifact-registry.tf
    ├── f6-02-cloudrun-product.tf
    ├── f6-03-cloudrun-order.tf
    ├── f6-04-cloudrun-inventory.tf
    ├── f6-05-cloudrun-frontend.tf
    ├── f7-02-apigateway.tf
    ├── f8-01-apikey.tf
    ├── f9-02-alb-negs.tf
    ├── f9-03-alb-backends.tf
    ├── f9-04-alb-urlmap.tf
    ├── f9-05-alb-frontend.tf
    ├── f10-01-cloudarmor.tf
    ├── terraform.tfvars
    └── templates/
```

---

## When to Use This Project

### Use this project when you need:

* API Gateway integration with Cloud Armor
* Serverless microservices on GCP
* Complete CI/CD automation
* Infrastructure as Code reference implementation
* Production-ready Cloud Run deployment patterns
* Secure API management architecture

### Avoid this project for:

* VM-based deployments
* Kubernetes workloads
* Stateful applications
* Long-running batch processing
* Database-heavy monolithic applications

---

## Future Improvements

### Security Enhancements

* HTTPS with managed SSL certificates
* Cloud Armor rate limiting
* Advanced WAF protection
* Secret Manager integration

### Observability

* Custom Monitoring dashboards
* Alerting policies
* Distributed tracing
* Service-level metrics

### Architecture

* Cloud SQL integration
* Redis caching layer
* Pub/Sub integration
* Multi-region deployment

### DevOps

* Staging environment support
* Canary deployments
* Automated testing
* Disaster recovery workflows

### Features

* Identity Platform authentication
* GraphQL API layer
* WebSocket support
* API versioning strategy

---

## Conclusion

This project demonstrates a production-ready serverless microservices architecture on Google Cloud Platform using Terraform, Cloud Build, Cloud Run, API Gateway, Load Balancer, and Cloud Armor.

The implementation provides secure API management, automated infrastructure deployment, scalable serverless application hosting, and production-grade CI/CD automation.

The architecture showcases Infrastructure as Code best practices while solving real-world challenges related to API security, serverless backend integrations, Terraform automation, and cloud-native deployment workflows.

---

## Additional Resources

* GCP Cloud Run Documentation
* API Gateway Documentation
* Cloud Armor Documentation
* Terraform GCP Provider Documentation
* Cloud Build Documentation

---

## Contributing

Contributions are welcome through pull requests and issue submissions.

---

## License

This project is provided for educational and reference purposes.



