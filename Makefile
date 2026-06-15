.DEFAULT_GOAL := help

.PHONY: help install

help: ## Show this help
	@ echo 
	@ echo "Available Commands:"
	@ echo 
	@ grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*##"}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Install for all providers (opencode, claude), all commands (agents, skills, commands)
	./scripts/link.sh
