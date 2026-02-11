.PHONY: help build fmt fmt-check init validate lint shellcheck security docs docs-check test clean shell

# Docker image name
IMAGE_NAME := opentofu-oci-test
DOCKER_RUN := docker run --rm -v $(PWD):/workspace $(IMAGE_NAME)

# Colors for output
GREEN  := \033[0;32m
YELLOW := \033[0;33m
RED    := \033[0;31m
NC     := \033[0m # No Color

help: ## Show this help
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker image
	@echo "$(GREEN)Building Docker image...$(NC)"
	docker build -t $(IMAGE_NAME) .

fmt: build ## Format OpenTofu files
	@echo "$(GREEN)Formatting OpenTofu files...$(NC)"
	$(DOCKER_RUN) tofu fmt -recursive

fmt-check: build ## Check OpenTofu formatting
	@echo "$(GREEN)Checking OpenTofu formatting...$(NC)"
	$(DOCKER_RUN) tofu fmt -check -recursive -diff

init: build ## Initialize OpenTofu
	@echo "$(GREEN)Initializing OpenTofu...$(NC)"
	$(DOCKER_RUN) tofu init -backend=false

validate: init ## Validate OpenTofu configuration
	@echo "$(GREEN)Validating OpenTofu configuration...$(NC)"
	$(DOCKER_RUN) tofu validate

lint: build ## Run tflint
	@echo "$(GREEN)Running tflint...$(NC)"
	$(DOCKER_RUN) tflint --init
	$(DOCKER_RUN) tflint

shellcheck: build ## Lint shell scripts with shellcheck
	@echo "$(GREEN)Running shellcheck...$(NC)"
	$(DOCKER_RUN) shellcheck -x scripts/*.sh

security: build ## Run Trivy security scan
	@echo "$(GREEN)Running Trivy security scan...$(NC)"
	$(DOCKER_RUN) trivy config --severity HIGH,CRITICAL .

security-all: build ## Run Trivy security scan (all severities)
	@echo "$(GREEN)Running Trivy security scan (all severities)...$(NC)"
	$(DOCKER_RUN) trivy config .

docs: build ## Generate terraform-docs
	@echo "$(GREEN)Generating terraform-docs...$(NC)"
	$(DOCKER_RUN) terraform-docs markdown table --output-file README.md --output-mode inject .

docs-check: docs ## Check if terraform-docs is up-to-date
	@echo "$(GREEN)Checking if docs are up-to-date...$(NC)"
	@git diff --exit-code README.md || (echo "$(RED)README.md is out of date. Run 'make docs' and commit.$(NC)" && exit 1)

test: fmt-check validate lint shellcheck security ## Run all tests
	@echo "$(GREEN)All tests passed!$(NC)"

clean: ## Clean up Docker image and OpenTofu files
	@echo "$(YELLOW)Cleaning up...$(NC)"
	docker rmi $(IMAGE_NAME) 2>/dev/null || true
	rm -rf .terraform
	rm -f .terraform.lock.hcl

shell: build ## Open a shell in the Docker container
	@echo "$(GREEN)Opening shell in container...$(NC)"
	docker run --rm -it -v $(PWD):/workspace $(IMAGE_NAME) /bin/bash

# Native targets (without Docker)
.PHONY: native-fmt native-validate native-lint native-shellcheck native-security native-test

native-fmt: ## Format OpenTofu files (native)
	tofu fmt -recursive

native-validate: ## Validate OpenTofu configuration (native)
	tofu init -backend=false
	tofu validate

native-lint: ## Run tflint (native)
	tflint --init
	tflint

native-shellcheck: ## Lint shell scripts (native)
	shellcheck -x scripts/*.sh

native-security: ## Run Trivy security scan (native)
	trivy config --severity HIGH,CRITICAL .

native-test: native-fmt native-validate native-lint native-shellcheck native-security ## Run all tests (native)
	@echo "$(GREEN)All tests passed!$(NC)"
