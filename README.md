# AWS ECS Nginx CI/CD Pipeline

[![GitHub Workflow Status](https://github.com/rushitest4559/ecs-nginx-cicd/actions/workflows/deploy.yml/badge.svg)](https://github.com/rushitest4559/ecs-nginx-cicd/actions)

**Production-grade ECS Fargate deployment with GitHub Actions CI/CD & Terraform IaC.**

## 🚀 Features
- **Modular Terraform**: VPC → ALB → ECS Fargate
- **GitHub Actions**: Auto-build/push ECR → deploy on `app/` changes
- **OIDC Auth**: Secure, passwordless AWS access
- **S3 Remote State**: Versioned Terraform state

## Setup (5 min)
```bash
pip install boto3
python setup_infra.py  # Creates S3 state bucket
cd infra && terraform init && terraform apply
```
**change something in app/index.html and then push to github**

## Configurations (Make sure this are correct before running terraform apply)
- **region**: deploy.yml, provider.tf, setup_infra.py
- **aws account no**: deploy.yml
- **oidc github configs**: infra/modules/oidc/variables.tf