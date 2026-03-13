# DevOps Examples Repository

A collection of practical **DevOps infrastructure examples** including
Docker, Docker Compose, Kubernetes, and Terraform.

This repository is intended as a reference for developers and DevOps
engineers who want to quickly learn or bootstrap environments using
modern container and infrastructure tooling.

------------------------------------------------------------------------

## 📦 Repository Contents

This repository includes examples such as:

-   Docker images for various applications
-   Docker Compose setups for multi-container environments
-   Kubernetes manifests for container orchestration
-   Terraform infrastructure examples
-   DevOps configuration templates

------------------------------------------------------------------------

## 🐳 Docker Examples

Example directory structure:

    docker/
     ├── node-app/
     │    ├── Dockerfile
     │    └── app.js
     ├── python-app/
     │    ├── Dockerfile
     │    └── main.py
     └── nginx/
          └── Dockerfile

Build an image:

    docker build -t example-image .

Run container:

    docker run -p 8080:8080 example-image

------------------------------------------------------------------------

## ⚙️ Docker Compose Examples

Docker Compose is used for running multi-container applications.

Example:

    docker-compose/
     ├── web-db/
     │    └── docker-compose.yml
     └── redis-stack/
          └── docker-compose.yml

Run services:

    docker compose up -d

Stop services:

    docker compose down

------------------------------------------------------------------------

## ☸️ Kubernetes Examples

Kubernetes manifests for deploying applications.

Structure:

    kubernetes/
     ├── deployment/
     │    └── app-deployment.yaml
     ├── service/
     │    └── app-service.yaml
     └── ingress/
          └── ingress.yaml

Deploy resources:

    kubectl apply -f kubernetes/

Check running resources:

    kubectl get pods

------------------------------------------------------------------------

## 🌍 Terraform Examples

Terraform examples for provisioning infrastructure.

Structure:

    terraform/
     ├── aws/
     │    ├── main.tf
     │    ├── variables.tf
     │    └── outputs.tf
     └── gcp/
          └── main.tf

Initialize Terraform:

    terraform init

Plan infrastructure:

    terraform plan

Apply infrastructure:

    terraform apply

------------------------------------------------------------------------

## 🎯 Purpose

This repository helps with:

-   Learning DevOps tools
-   Testing infrastructure configurations
-   Building reusable templates
-   Sharing deployment examples

------------------------------------------------------------------------

## 🧰 Technologies Covered

-   Docker
-   Docker Compose
-   Kubernetes
-   Terraform
-   Containerized Development

------------------------------------------------------------------------

## 🤝 Contributing

Contributions are welcome.

Steps:

1.  Fork the repository
2.  Create a new branch
3.  Add your example
4.  Submit a pull request

------------------------------------------------------------------------

## 📄 License

MIT License
