# Cloud IaC Audit — Infrastructure-as-Code Security Misconfiguration Scanner

This repository provides a self-contained Infrastructure-as-Code (IaC) security auditing workflow.  
It scans **Terraform configuration files** for cloud security misconfigurations, documents the findings, and includes **fixed versions** of each issue for validation and reporting.

No cloud accounts, credentials, or external services are required — all scanning happens locally.

---

## 📁 Repository Structure

This is the exact structure of the project:

```text
.
├── artifacts/                ← Scan results (generated automatically)
│   ├── fixed_checkov.json
│   ├── fixed_checkov.txt
│   ├── insecure_checkov.json
│   └── insecure_checkov.txt
├── examples/                 ← Vulnerable IaC Terraform files
│   ├── ebs-no-encryption.tf
│   ├── iam-wildcard.tf
│   ├── kms-no-rotation.tf
│   ├── s3-public.tf
│   └── sg-open.tf
├── fixed/                    ← Corrected, secure IaC versions
│   ├── ebs-no-encryption-fixed.tf
│   ├── iam-wildcard-fixed.tf
│   ├── kms-no-rotation-fixed.tf
│   ├── s3-public-fixed.tf
│   ├── sg-open-fixed.tf
│   └── (copies of original files for comparison)
├── src/
│   └── scan.py               ← Python wrapper that runs Checkov scans
├── Makefile                  ← Convenience tasks (scan, clean, etc.)
├── requirements.txt          ← Python package dependencies
└── README.md                 ← Project documentation
🎯 Project Purpose
This project demonstrates:

how cloud infrastructure misconfigurations occur inside Terraform,

how static IaC scanning tools identify them,

how to remediate each issue,

and how to validate that fixes are correct.

This is ideal for:

✔ Cybersecurity coursework
✔ Cloud compliance demonstrations
✔ DevSecOps training
✔ CI/CD security integration demos

🛠 Installation
1. Clone the repo
bash
Copy code
git clone https://github.com/jtproject02-cmd/cloud-iac-audit.git
cd cloud-iac-audit
2. Install Python dependencies
bash
Copy code
pip install -r requirements.txt
This installs Checkov, the IaC scanner used in this project.

🚀 Usage
▶️ Scan vulnerable IaC code
bash
Copy code
python3 src/scan.py examples/
This produces:

artifacts/insecure_checkov.json

artifacts/insecure_checkov.txt (human-readable CLI output)

▶️ Scan fixed IaC code
bash
Copy code
python3 src/scan.py fixed/
Outputs:

artifacts/fixed_checkov.json

artifacts/fixed_checkov.txt

▶️ Makefile shortcuts
Run all scans:

bash
Copy code
make scan
Clean artifacts:

bash
Copy code
make clean
🔍 Misconfigurations Included (Before → After)
Each Terraform file in examples/ intentionally contains a high-severity AWS misconfiguration.

1️⃣ Public S3 Bucket (s3-public.tf)
Issue: Bucket ACL allows public read; no block-public-access.

Risk: Data exposure to the entire internet.

Fix: ACL set to private, public access block enabled.

2️⃣ Security Group Open to World (sg-open.tf)
Issue: Port 22 or 0–65535 open to 0.0.0.0/0.

Risk: Remote compromise, brute force entry.

Fix: Restrict to known CIDR range (e.g., corporate subnet).

3️⃣ Unencrypted EBS Volume (ebs-no-encryption.tf)
Issue: Encryption is disabled by default.

Risk: Data-at-rest compromise.

Fix: encrypted = true.

4️⃣ Wildcard IAM Policy (iam-wildcard.tf)
Issue: Action="*", Resource="*"

Risk: Privilege escalation, full-account takeover.

Fix: Restrict to specific actions & ARNs.

5️⃣ KMS Key Rotation Disabled (kms-no-rotation.tf)
Issue: enable_key_rotation = false

Risk: Key aging, cryptographic weakness.

Fix: Set enable_key_rotation = true.

📊 Scan Output (Artifacts)
Your scan results appear in the artifacts/ directory.

File	Description
insecure_checkov.json	JSON results of scanning the vulnerable IaC
insecure_checkov.txt	Human-readable report of failures
fixed_checkov.json	JSON results of scanning the remediated IaC
fixed_checkov.txt	Confirms that fixes pass

These can be used in:

reports

risk assessments

compliance checklists

audit documentation

🧪 Validating Fixes
You should see:

❌ FAILED checks for the examples/ directory
✔️ PASSED checks for the fixed/ directory

Example:

vbnet
Copy code
Check: CKV_AWS_20
Resource: aws_s3_bucket.public
Result: FAILED → PASSED (after fix)
📚 How to Extend This Project
You can easily add:

CloudFormation (YAML/JSON)

Kubernetes manifests

Additional Terraform modules

Organization-specific policies

CI/CD integration (GitHub Actions, GitLab CI, Jenkins)

Just drop new files into examples/ or fixed/ and re-run the scanner.

⚠️ Security Disclaimer
This repository contains intentionally insecure IaC for educational and testing purposes only.
Never deploy the examples/ directory into a real cloud environment.

🙌 Credits
Developed as a lightweight, extensible platform for learning IaC security, cloud risk management, and automated misconfiguration detection.
