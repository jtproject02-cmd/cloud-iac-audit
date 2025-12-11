scan:
	@echo "Running all IaC scans..."
	python3 src/scan.py

report:
	@echo "Report generation is manual. Edit docs/project-report.md"
	
clean:
	rm -rf artifacts/*.json artifacts/*.txt
	@echo "Cleaned scan artifacts."

scan-fixed:
	@echo "Running Checkov on fixed IaC..."
	python3 src/scan.py fixed/
