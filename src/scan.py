import os
import sys

def run_scan(directory, output_prefix):
    print(f"Running Checkov on {directory}...")
    os.system(f"checkov -d {directory} -o json > artifacts/{output_prefix}_checkov.json")
    os.system(f"checkov -d {directory} -o cli > artifacts/{output_prefix}_checkov.txt")
    print(f"Scans complete for {directory}. Check artifacts/ directory.")

if __name__ == "__main__":
    print("--- Starting IaC Audit Scan ---")
    run_scan("examples", "insecure")
    run_scan("fixed", "fixed")
    print("--- All scans finished. ---")
