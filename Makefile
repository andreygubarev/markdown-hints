OUTPUT = out/hints.md

.PHONY: all
all: clean deps gen ## Clean, install dependencies and run script

.PHONY: help
help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: clean
clean: ## Remove cache
	@echo "Removing cache..."
	@rm -rf venv
	@rm -rf out
	@echo "Cache removed."

venv: ## Create virtual environment
	@echo "Creating virtual environment..."
	@python3 -m venv venv
	@echo "Virtual environment created."

.PHONY: deps
deps: venv ## Install dependencies
	@echo "Installing dependencies..."
	@venv/bin/pip install -r requirements.txt
	@echo "Dependencies installed."

.PHONY: gen
gen: lint ## Run script
	@echo "Running..."
	@mkdir -p out
	@venv/bin/python3 gen.py -o $(OUTPUT)
	@echo "Done."

.PHONY: lint
lint: ## Lint code
	@echo "Linting..."
	@venv/bin/pycodestyle gen.py
	@echo "Linting done."

.PHONY: run
run: ## Run script
	@echo "Running..."
	@mkdir -p out
	@fswatch - --exclude="out" --exclude=".git" . | xargs -n1 -I{} venv/bin/python3 gen.py -o $(OUTPUT)
	@echo "Done."
