.PHONY: help fmt fmt-check init validate tofu-test shellcheck test clean

GREEN  := \033[0;32m
YELLOW := \033[0;33m
NC     := \033[0m

help: ## Show this help
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

fmt: ## Format OpenTofu files
	@echo "$(GREEN)Formatting OpenTofu files...$(NC)"
	tofu fmt -recursive

fmt-check: ## Check OpenTofu formatting
	@echo "$(GREEN)Checking OpenTofu formatting...$(NC)"
	tofu fmt -check -recursive -diff

init: ## Initialize OpenTofu (no backend, refreshing the provider lock)
	@echo "$(GREEN)Initializing OpenTofu...$(NC)"
	tofu init -backend=false -upgrade

validate: init ## Validate OpenTofu configuration
	@echo "$(GREEN)Validating OpenTofu configuration...$(NC)"
	tofu validate

tofu-test: init ## Run OpenTofu native tests
	@echo "$(GREEN)Running OpenTofu native tests...$(NC)"
	tofu test

shellcheck: ## Lint shell scripts with shellcheck
	@echo "$(GREEN)Running shellcheck...$(NC)"
	shellcheck -x scripts/*.sh

test: fmt-check validate tofu-test shellcheck ## Run all checks
	@echo "$(GREEN)All checks passed!$(NC)"

clean: ## Remove OpenTofu working files
	@echo "$(YELLOW)Cleaning up...$(NC)"
	rm -rf .terraform
