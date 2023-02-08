PYTHON ?= python3
VIRTUALENV ?= venv

OUTPUT_DIR = out
OUTPUT ?= $(OUTPUT_DIR)/hints.md

.PHONY: all
all: clean venv deps lint gen ## Clean, install dependencies and run script

.PHONY: help
help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: clean
clean: ## Remove cache
	@echo "Removing cache..."
	@rm -rf $(VIRTUALENV)
	@rm -rf $(OUTPUT_DIR)
	@echo "Cache removed."

venv: ## Create virtual environment
	@echo "Creating virtual environment..."
	@$(PYTHON) -m venv $(VIRTUALENV)
	@echo "Virtual environment created."

.PHONY: deps
deps: ## Install dependencies
	@echo "Installing dependencies..."
	@$(PYTHON) -m pip install -r requirements.txt
	@echo "Dependencies installed."

.PHONY: gen
gen: ## Run script
	@echo "Running..."
	@mkdir -p $(OUTPUT_DIR)
	@$(PYTHON) gen.py -o $(OUTPUT)
	@echo "Done."

.PHONY: lint
lint: ## Lint code
	@echo "Linting..."
	@pycodestyle $(shell git ls-files '*.py')
	@echo "Linting done."

.PHONY: run
run: ## Run script
	@echo "Running..."
	@mkdir -p $(OUTPUT_DIR)
	@fswatch - --exclude="$(OUTPUT_DIR)" --exclude=".git" . | xargs -n1 -I{} $(PYTHON) gen.py -o $(OUTPUT)
	@echo "Done."
