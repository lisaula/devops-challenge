.PHONY: help init clean

help:
	@echo "Run 'make init' to initialize workspace"
	@echo "Run 'make clean' to remove TF system files (i.e. to re-init the workspace)"

init:
	@terraform init && terraform workspace select prod && terraform refresh

clean:
	@find . -name ".terraform*" -exec rm -r {} +
