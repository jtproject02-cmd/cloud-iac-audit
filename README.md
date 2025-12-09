# ☁️ Cloud Security Misconfiguration Auditing with IaC  
### A Terraform Static Analysis & Remediation Project (Checkov + Python + Kali Linux)

---

## 📌 Project Overview

This project demonstrates a **Shift-Left Cloud Security workflow** by statically scanning Infrastructure-as-Code (IaC) for misconfigurations *before deployment*. Using **Checkov**, we identify high-severity cloud security issues in Terraform files, generate audit reports, then validate fixes by rescanning corrected versions.

The project contains:

- Vulnerable Terraform IaC (`examples/`)
- Remediated secure IaC (`fixed/`)
- A Python-based auditor (`src/scan.py`)
- Automated scanning via Makefile
- Audit artifacts stored in `artifacts/`

Everything runs locally — **no AWS credentials or infrastructure required**.

---

## 🔍 High-Severity Findings Identified

The following AWS misconfigurations were intentionally introduced and detected:

### 1. **Public S3 Bucket**  
File: `examples/s3-public.tf`  
- ACL set to `public-read`  
- Risk: Data exposure / unintended public access  

### 2. **Security Group Exposing Port 22 to Internet**  
File: `examples/sg-open.tf`  
- `0.0.0.0/0` allowed on port 22  
- Risk: Remote compromise  

### 3. **Unencrypted EBS Volume**  
File: `examples/ebs-no-encryption.tf`  
- Missing encryption block  
- Risk: Fails CIS benchmarks + sensitive data exposure  

### 4. **Wildcard IAM Policy (`*` actions, `*` resources)**  
File: `examples/iam-wildcard.tf`  
- Violates least privilege  
- Risk: Privilege escalation & full account compromise  

### 5. **KMS Key Rotation Disabled**  
File: `examples/kms-no-rotation.tf`  
- `enable_key_rotation = false`  
- Risk: Key lifecycle vulnerabilities & compliance failures  

---

## 🛠 Technology used

| Component | Tool | Purpose |
|----------|------|---------|
| IaC Scanner | **Checkov** | Static security analysis |
| IaC Language | **Terraform (.tf files)** | AWS Infrastructure definitions |
| Automation | **Python (`src/scan.py`)** | Wrapper + reporting |
| Dev Environment | **Kali Linux** | Verified system |
| Build Tasks | **Makefile** | Streamlined audits |

---

## 📂 Repository Structure

cloud-iac-audit/
├── artifacts/
│ ├── insecure_checkov.json
│ ├── insecure_checkov.txt
│ ├── fixed_checkov.json
│ ├── fixed_checkov.txt
│
├── examples/
│ ├── ebs-no-encryption.tf
│ ├── iam-wildcard.tf
│ ├── kms-no-rotation.tf
│ ├── s3-public.tf
│ ├── sg-open.tf
│
├── fixed/
│ ├── ebs-no-encryption-fixed.tf
│ ├── iam-wildcard-fixed.tf
│ ├── kms-no-rotation-fixed.tf
│ ├── s3-public-fixed.tf
│ ├── sg-open-fixed.tf
│
├── src/
│ └── scan.py
│
├── Makefile
├── requirements.txt
└── README.md

yaml
Copy code

---

## ⚙️ Installation (Kali Linux)

### 1. Clone the repository

```bash
git clone https://github.com/jtproject02-cmd/cloud-iac-audit
cd cloud-iac-audit
2. Create virtual environment
bash
Copy code
python3 -m venv .venv
source .venv/bin/activate
3. Install scanner dependencies
bash
Copy code
pip install -r requirements.txt
🚀 Usage
🔸 Run scan on insecure Terraform files
bash
Copy code
make scan
This generates:

bash
Copy code
artifacts/insecure_checkov.json
artifacts/insecure_checkov.txt
These documents show all FAILED checks.

🔸 Run scan on fixed Terraform files
bash
Copy code
make scan-fixed
Outputs:

bash
Copy code
artifacts/fixed_checkov.json
artifacts/fixed_checkov.txt
These represent PASSED checks after remediation.

🔸 Compare insecure vs fixed IaC
Example:

bash
Copy code
git diff examples/sg-open.tf fixed/sg-open-fixed.tf
Use this during a class presentation to show step-by-step remediation.

🧪 Automated Testing (Optional)
You can add a script under tests/:

bash
Copy code
checkov -d examples | grep FAILED
checkov -d fixed | grep PASSED
echo "All tests passed."
📄 Documentation (Optional)
You can create:

bash
Copy code
docs/project-report.md
docs/user-manual.md
These typically include:

Rule IDs

Misconfigurations

Before/After code

Screenshots of Checkov results

Useful for academic submissions.

📘 Requirements Summary
System-Level
Python 3.8+

pip

Git

make (GNU Make)

Linux-based OS (Kali recommended)

Python Level
Installed automatically:

nginx
Copy code
checkov
No AWS CLI, no Terraform CLI, and no cloud credentials required.

🏁 Conclusion
This project effectively demonstrates:

How IaC introduces security risks

How automated scanning prevents insecure deployments

How to remediate misconfigurations following best practices

How to validate improvements and generate professional audit artifacts

It is fully reproducible, cloud-free, and presentation-ready.
