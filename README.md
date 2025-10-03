form Projects

This repository contains multiple Terraform projects that demonstrate Infrastructure as Code (IaC) best practices on AWS.  
It currently includes:

1. **remote-state** – Bootstraps the S3 + DynamoDB backend for storing Terraform state.
2. **ec2-project** – Provisions an EC2 instance and secures it with a security group, using the remote backend for state management.

## 📂 Project Structure

```

terraform-projects/
├── remote-state/      # Creates S3 bucket + DynamoDB table for remote state
├── ec2-project/       # Provisions EC2 instance using remote state backend
└── README.md          # Documentation

````

---

## 🚀 1. Remote State Project

### 🔹 What is Remote State?
Terraform generates a **state file** (`terraform.tfstate`) that tracks resources it manages.  
If this file is kept **locally**, it can lead to:
- Loss of state if your machine is wiped.
- Conflicts when multiple people run Terraform.
- Difficulty collaborating across environments (dev, staging, prod).

👉 **Solution:** Store state in a **remote backend** (S3 bucket) and enable state locking (DynamoDB).  

### 🔹 Why is it needed?
- **Centralized state** → Everyone works with the same source of truth.
- **Team collaboration** → Prevents accidental overwrites.
- **Versioning** → S3 bucket with versioning protects against accidental state corruption.
- **Locking** → DynamoDB ensures only one `terraform apply` runs at a time.

### 🔹 Resources Created
- **S3 Bucket** (`<account-id>-terraform-states`)  
  - Stores `.tfstate` files.
  - Versioning enabled.
  - Server-side encryption (AES-256).
  - `prevent_destroy` lifecycle rule.
- **DynamoDB Table** (`terraform-lock`)  
  - Used for state locking.
  - Hash key: `LockID`.

### 🔹 How to Deploy
```bash
cd remote-state
terraform init
terraform apply -auto-approve
````

### 🔹 Outputs

After apply, Terraform will output:

* S3 bucket name, ARN, and region.
* DynamoDB table name and ARN.

---

## 🚀 2. EC2 Project

### 🔹 What it Does

This project provisions:

* An **EC2 instance** using a chosen AMI and instance type.
* A **Security Group** that allows SSH (`tcp/22`) access.
* Remote state is stored in the S3 bucket and DynamoDB table created by the **remote-state** project.

### 🔹 Project Files

* `backend.tf` → Configures S3 + DynamoDB as the remote backend.
* `provider.tf` → AWS provider setup.
* `variables.tf` → Defines configurable variables (AMI, instance type, VPC ID).
* `ec2.tf` → Provisions an EC2 instance.
* `security-groups.tf` → Creates SSH security group.
* `outputs.tf` → Prints EC2 instance ID and public IP.
* `config/backend-dev.conf` → Stores backend configuration (bucket, key, region, DynamoDB table).

### 🔹 How to Deploy

1. Make sure **remote-state** project is applied first.
2. Initialize the backend:

   ```bash
   cd ec2-project
   terraform init -backend-config=./config/backend-dev.conf
   ```
3. Apply the configuration:

   ```bash
   terraform apply -auto-approve
   ```

### 🔹 Outputs

* EC2 Instance ID
* EC2 Public IP (for SSH access)

---

## ⚠️ Security Notes

* **Account ID**: Appears in bucket names but is safe to commit (not a secret).
* **Never commit** AWS access keys, `terraform.tfstate`, or `.tfvars` with secrets.
* `.gitignore` is set up to exclude sensitive/local files.

---

## 📖 Next Steps

* Add more environments (`staging`, `prod`) with separate backend configs.
* Use variables/Workspaces to manage multiple environments dynamically.
* Extend the EC2 project with networking (VPC, subnets, load balancer, etc.).

---

## 🛠️ Tech Stack

* **Terraform** `>= 1.0.0`
* **AWS Provider** `~> 5.0`
* **AWS Services** → S3, DynamoDB, EC2, Security Groups
