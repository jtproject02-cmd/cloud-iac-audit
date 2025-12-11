# Cloud Security Misconfiguration Auditing with IaC — Project Report

COSC 435 — Computer & Network Security
Project 5: Cloud Security Misconfiguration Auditing with IaC
Institution: Bowie State University
Instructor: Dr. Devharsh Trivedi, CISSP
Project Category: Cloud Security Posture Management (CSPM) via IaC Scanning
Repository: cloud-iac-audit

## 1. Project Overview

Infrastructure-as-Code (IaC) scanning is a Shift-Left security practice that detects cloud misconfigurations before deployment. Rather than waiting for vulnerabilities to appear in a live AWS environment, IaC scanning evaluates Terraform configuration files against industry frameworks such as:

- CIS Benchmarks

- NIST 800-53

- AWS Well-Architected Security Pillar

This project implements an IaC audit using Checkov, an open-source static analysis engine that evaluates Terraform code for compliance and security risks.

This project demonstrates:

- Detection of high-severity misconfigurations in the insecure Terraform files
- Creation of secure “fixed” Terraform configurations addressing:

  - Encryption requirements

  - IAM least privilege

  - S3 hardening

  - KMS lifecycle policies

  - Network access restrictions

- Re-scanning to validate remediation
- Documentation of five+ major findings, Checkov rule IDs, and corrected code

---

## 2. Methodology
### 2.1 Audit Scope

The audit evaluated AWS resources commonly misconfigured in real-world cloud environments:

| AWS Resource  | Risk Category       |
|-------|------------|
| S3 Buckets | Public exposure, no versioning, no logging, missing encryption   |
| IAM Policies   | Wildcard privileges (*), privilege escalation risk    |
| EBS Volumes | No encryption at rest |
| Security Groups | Ports exposed to 0.0.0.0/0 |
| KMS Keys | Rotation disabled, missing key policies |

These categories perfectly align with the CSPM scope in the assignment.

---

### 2.2 Tools & Environment
| Component  | Tool       |
|-------|------------|
| IaC Language | Terraform   |
| Static Analysis Engine   | Checkov   |
| Automation/Python (src/scan.py) | Makefile |
| OS | Kali Linux |
| Reports | JSON + CLI output stored in /artifacts/ |

---

### 2.3 Scanning Workflow

The workflow simulates how a real CI/CD security pipeline detects and prevents misconfigurations.

**Step 1 - Baseline Scan**
```
make scan
```

Produces:

artifacts/insecure_checkov.txt
artifacts/insecure_checkov.json


Results:

Passed: 10

Failed: 24

**Step 2 - Remediation**

All failing configurations were rewritten in ``` /fixed/ ```to comply with Checkov rule requirements:

- Added KMS encryption

- Removed wildcards from IAM

- Blocked S3 public access

- Added SG restrictions

- Added KMS rotation + key policies

**Step 3 — Verification Scan**

Re-run:
```
make scan
```

Checkov evaluates the fixed files.
All high-severity misconfigurations required for the assignment were remediated.

---
## 3. Key Findings & Remediation

Below are five major findings with rule IDs, explanations, insecure code, and corrected versions.

### Finding 1 - Unencrypted EBS Volume
**Rule Violated**

- CKV_AWS_3 - EBS volume must be encrypted

- CKV_AWS_189 - Must use a Customer Managed Key (CMK)

**Why This Is Critical**

Unencrypted disks expose data if snapshots or volumes leak.

**Insecure Code**
```
resource "aws_ebs_volume" "secure_volume" {
  availability_zone = "us-east-1a"
  size              = 10

  encrypted = true
}
```

**Secure Code**
```
# KMS key for EBS encryption
resource "aws_kms_key" "ebs_kms" {
  description         = "CMK for EBS volume encryption"
  enable_key_rotation = true

  # Minimal, non-wildcard principal policy
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EnableRootPermissions"
        Effect   = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:root"
        }
        Action   = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

# Secure, KMS-encrypted EBS volume
resource "aws_ebs_volume" "secure_volume" {
  availability_zone = "us-east-1a"
  size              = 8
  encrypted         = true
  kms_key_id        = aws_kms_key.ebs_kms.arn

  tags = {
    Name = "secure-ebs-volume"
  }
}
```

### Finding 2 - Wildcard IAM Policy (“*” Policies)
**Rule Violated**

- CKV_AWS_62

- CKV_AWS_63

- CKV_AWS_355

- CKV_AWS_286

- CKV_AWS_289, etc.

**Why This Is Critical**

Grants full administrative privileges, enabling:
- Data theft
- Account takeover
- Privilege escalation

**Insecure Code**
```
resource "aws_iam_policy" "secure_policy" {
  name = "secure-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes"
        ]
        Resource = "*"
      }
    ]
  })
}
```

**Secure Code Example**
```
# Least-privilege IAM policy: read-only access to a specific S3 bucket
resource "aws_iam_policy" "limited_read_only" {
  name        = "limited-readonly-policy"
  description = "Read-only access to a single logs bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowListBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::app-logs-bucket"
      },
      {
        Sid    = "AllowGetObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::app-logs-bucket/*"
      }
    ]
  })
}
```

### Finding 3 - Public S3 Bucket + Missing Protections
**Rule Violated**

- CKV_AWS_20 - Public READ

- CKV2_AWS_6 - Missing Public Access Block

- CKV_AWS_18 - No access logging

- CKV_AWS_21 - No versioning

**Insecure Code**
```
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "my-secure-bucket-example"
}

resource "aws_s3_bucket_public_access_block" "secure_bucket_block" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "secure_bucket_acl" {
  bucket = aws_s3_bucket.secure_bucket.id
  acl    = "private"
}
```

**Secure Code**
```
# Secure S3 bucket (not public, encrypted, versioned, logged)
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "secure-bucket-example-435"
}

# Block public access
resource "aws_s3_bucket_public_access_block" "secure_bucket_block" {
  bucket                  = aws_s3_bucket.secure_bucket.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Default encryption with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "secure_bucket_sse" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.secure_kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Versioning
resource "aws_s3_bucket_versioning" "secure_bucket_versioning" {
  bucket = aws_s3_bucket.secure_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Access logging (logs to a separate bucket, usually)
resource "aws_s3_bucket" "logs_bucket" {
  bucket = "secure-bucket-logs-435"
}

resource "aws_s3_bucket_logging" "secure_bucket_logging" {
  bucket        = aws_s3_bucket.secure_bucket.id
  target_bucket = aws_s3_bucket.logs_bucket.id
  target_prefix = "logs/"
}

# Lifecycle configuration example (helps with some lifecycle-related checks)
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    id     = "abort-multipart-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
```

### Finding 4 - Security Group Allows SSH From 0.0.0.0/0
**Rule Violated**

- CKV_AWS_24 - Prevent wide-open SSH

- CKV_AWS_23 - Missing description

- CKV2_AWS_5 - Not attached to resource

**Insecure Code**
```
resource "aws_security_group" "secure_sg" {
  name = "secure-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]   # restricted private network
  }
}
```

**Secure Code**
```
resource "aws_security_group" "restricted_sg" {
  name        = "restricted-ssh-sg"
  description = "Allow SSH only from corporate subnet"
  vpc_id      = "vpc-12345678" # example VPC ID placeholder

  ingress {
    description = "SSH from corporate office"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]  # internal subnet only
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "restricted-ssh-sg"
  }
}
```

### Finding 5 — KMS Key Rotation Disabled
**Rule Violated**

- CKV_AWS_7 - Must enable key rotation

- CKV2_AWS_64 - KMS policy required

**Insecure Code**
```
resource "aws_kms_key" "no_rotate" {
  enable_key_rotation = false
}
```

**Secure Code**
```
resource "aws_kms_key" "secure_kms" {
  description         = "Secure KMS key with rotation and explicit policy"
  enable_key_rotation = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowRootAccount"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:root"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}
```
---
## 4. Testing & Validation
### 4.1 Insecure Scan Results
```
Passed checks: 10  
Failed checks: 24  
```

These represent high-severity misconfigurations.
---
### 4.2 Fixed Scan Results

After remediation:

- All high-severity violations required by the assignment were fixed.
- Remaining issues are medium/low severity, often requiring real AWS resources.

---
## 5. Security Considerations

- No AWS account was used; all testing occurred locally.

- Terraform files were scanned statically without deployment.

- All IAM policies follow least privilege.

- All encryption requirements were met.

- Fully aligned with ethical guidelines in the course project.

---
## 6. Limitations

- Some Checkov rules cannot be passed without deployed AWS infrastructure.

- Optional features (replication, lifecycle rules) add complexity not required for the Project.

- Static analysis cannot detect runtime drift or cloud configuration changes.

---
## 7. Future Improvements

- Add GitHub Actions CI/CD pipeline with automatic Checkov scans.

- Add full CIS benchmark compliance modes.

- Generate HTML or PDF reporting.

- Expand scanning to include CloudFormation and Kubernetes YAML.

- Aim to achieve 100% pass rate without breaking strictness of Checkov.

---
## 8. Conclusion

This project demonstrates the importance of proactive cloud security using IaC scanning. By detecting 24 misconfigurations, remediating the code, and verifying fixes with Checkov, this project was a very educational experience as it has shown us a peak into what this type of work is like in the real world. We aim to increase our knowledge and skills to both improve this project and complete future works in the Cyber Security field.

The result is a complete, functioning CSPM toolchain suitable for academic and professional use.
