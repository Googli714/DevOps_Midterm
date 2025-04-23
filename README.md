# DevOps Pipeline - Web Application

This repository contains a simplified DevOps pipeline implementation for a Flask web application, created as part of a DevOps course midterm project. The pipeline demonstrates key DevOps principles including version control, automated testing, CI/CD, and Infrastructure as Code (IaC).

## Project Overview

The project implements a complete DevOps pipeline for a simple Flask web application that calculates the area of rectangles. The application features:
- A web interface for user input
- API endpoints for calculations
- Health check functionality
- Blue/Green deployment strategy
- Automated testing

## Tools & Technologies Used

- **Web Framework**: Flask
- **Version Control**: Git, GitHub
- **CI/CD**: GitHub Actions
- **Infrastructure as Code**: Terraform
- **Containerization**: Docker
- **Testing**: pytest
- **Deployment Strategy**: Blue/Green deployment

## DevOps Pipeline Components

### 1. Web Application

A Flask application that provides:
- Web interface for calculating rectangle areas
- REST API endpoint for square calculation (`/square`)
- Health check endpoint (`/health`)

### 2. Version Control

The project uses Git for version control with two main branches:
- `master`: Production-ready code
- `dev`: Development and feature integration

### 3. Continuous Integration

GitHub Actions is configured to automatically:
- Run tests on every push or PR to master
- Report test results
- Archive test artifacts

Configuration file: `.github/workflows/ci.yml`

### 4. Infrastructure as Code

Terraform is used to manage the application's infrastructure:
- Creates separate deployment directories (blue/green)
- Builds Docker images
- Manages container deployment
- Sets up health checks
- Handles port allocation

Configuration files: 
- `terraform-blue/main-blue.tf`
- `terraform-green/main-green.tf`

### 5. Continuous Deployment

The project implements a Blue/Green deployment strategy:
- Two identical environments (blue and green)
- Port 5000 for green deployment
- Port 5001 for blue deployment
- Switching between environments involves running the corresponding Terraform script

### 6. Monitoring and Health Check

A Bash script (`health_check.sh`) performs:
- Regular health checks of the application
- Logs results to a log file
- Configured to run every 60 seconds

## Pipeline Workflow

1. Developer commits code to repository (dev branch)
2. Pull request is created to merge into master
3. GitHub Actions runs automated tests
4. If tests pass, code can be merged to master
5. Deployment is triggered using Terraform
6. Terraform provisions the environment (blue or green)
7. Application is deployed in Docker container
8. Health check script monitors application status

## Setup Instructions

### Prerequisites

- Git
- Docker
- Terraform (>= 0.12)
- Python 3.9 or higher

### Local Development

1. Clone the repository:
   ```
   git clone https://github.com/Googli714/DevOps_Midterm
   cd DevOps-Midterm
   ```

2. Create a virtual environment and install dependencies:
   ```
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

3. Run the application locally:
   ```
   python -m flask --app src/app run
   ```

4. Run tests:
   ```
   pytest tests/
   ```

### Deployment

#### Green Deployment (Port 5000)

```
cd terraform-green
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

#### Blue Deployment (Port 5001)

```
cd terraform-blue
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### Switching Deployments

To perform a Blue/Green deployment switch:

1. Verify the new environment is healthy:
   ```
   curl http://localhost:5001/health  # For blue deployment
   ```

2. Update your load balancer or proxy to point to the new environment.

3. Once traffic is directed to the new environment, you can tear down the old one if needed.

### Rollback Procedure

To rollback to the previous deployment:

1. Verify the previous environment is still available:
   ```
   curl http://localhost:5000/health  # For green deployment
   ```

2. Redirect traffic back to the previous environment.

## CI/CD Pipeline Details

The CI pipeline in GitHub Actions:
- Triggers on push to master or PRs targeting master
- Sets up Python environment
- Installs dependencies
- Runs pytest tests
- Uploads test results as artifacts
- Publishes test results report

## Project Structure

```
.
├── .github/workflows        # CI/CD configuration
├── blue/                    # Blue deployment directory
├── green/                   # Green deployment directory
├── src/                     # Application source code
│   ├── templates/           # HTML templates
│   └── app.py               # Main Flask application
├── terraform-blue/          # Terraform config for blue deployment
├── terraform-green/         # Terraform config for green deployment
├── tests/                   # Test files
├── .gitignore               # Git ignore file
├── Dockerfile               # Docker configuration
├── health_check.sh          # Health monitoring script
└── requirements.txt         # Python dependencies
```

## Monitoring and Logs

Health check logs are stored in:
- Blue deployment: `blue/logs/LOGS.txt`
- Green deployment: `green/logs/LOGS.txt`