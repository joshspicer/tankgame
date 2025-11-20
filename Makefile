.PHONY: run build run-multiplayer clean help launch

# Default target
.DEFAULT_GOAL := help

help: ## Show this help message
	@echo "Tank Game - Build and Run Targets"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

launch: ## Launch interactive menu
	./launch.sh

run: ## Run the game on iOS simulator (single player)
	./run.sh

run-multiplayer: ## Run two instances for multiplayer testing
	./run.sh -n 2

run-macos: ## Run the game natively on macOS
	./run.sh -p macOS

build: ## Build the iOS version (Debug)
	./build.sh

build-release: ## Build the iOS version (Release)
	./build.sh -c Release

build-macos: ## Build the macOS version
	./build.sh -p macOS

clean: ## Clean build artifacts
	rm -rf ./build
	xcodebuild clean -project tankgame.xcodeproj -scheme "tankgame iOS" || true
	xcodebuild clean -project tankgame.xcodeproj -scheme "tankgame macOS" || true
	xcodebuild clean -project tankgame.xcodeproj -scheme "tankgame tvOS" || true
