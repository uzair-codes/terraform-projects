# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# REMOTE STATE BOOTSTRAP - Creates S3 bucket + DynamoDB table for Terraform
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# -------------------------
# Provider Configuration
# -------------------------
provider "aws" {
  region = "ap-south-1" # Change this to your desired AWS region
}

# -------------------------
# Get Current Account ID
# -------------------------
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# -------------------------
# Create S3 Bucket
# -------------------------
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${local.account_id}-terraform-states" # Globally unique bucket name

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle {
    prevent_destroy = true # Protect against accidental deletion
  }

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "DevOps"
    ManagedBy   = "Terraform"
  }
}

## Enable Versioning ##
resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# -------------------------
# Create DynamoDB Table
# -------------------------
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform Lock Table"
    Environment = "DevOps"
    ManagedBy   = "Terraform"
  }
}
