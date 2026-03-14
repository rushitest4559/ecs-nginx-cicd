terraform {
  required_version = ">= 1.5.0" # Ensures you're using a modern Terraform CLI

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Uses the latest major version 5.x
    }
  }

  # The Backend block: This is where your 'Source of Truth' lives
  backend "s3" {
    bucket       = "rushi-nginx-terraform-state-bucket-4559"
    key          = "dev/nginx-app/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true # Used for state locking
    encrypt      = true # Encrypts the state file at rest
  }
}

provider "aws" {
  region = "us-east-1"

  # Standard Tags: Every resource created will automatically have these
  default_tags {
    tags = {
      Project   = "Nginx-ECS-Fargate"
      ManagedBy = "Terraform"
      Owner     = "DevOps-Team"
    }
  }
}