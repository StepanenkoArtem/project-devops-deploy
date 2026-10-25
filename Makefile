.DEFAULT_GOAL := help

GRADLE_VERSION ?= 9

help: ## Show this help
	@awk 'BEGIN {FS = ":.*## "; printf "Usage: make \033[36m<target>\033[0m\n\n"} \
		/^[a-zA-Z_-]+:.*## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

test: ## Run backend tests
	./gradlew test

start: run ## Alias for run

run: ## Start the backend locally (dev profile, in-memory H2)
	./gradlew bootRun

update-gradle: ## Update the Gradle wrapper to the newest GRADLE_VERSION release (default: 9)
	./gradlew wrapper --gradle-version $(GRADLE_VERSION)
	./gradlew wrapper

update-deps: ## Bump dependency versions in gradle/libs.versions.toml
	./gradlew versionCatalogUpdate

install: ## Download Gradle dependencies
	./gradlew dependencies

build: ## Build the backend jar (also runs tests and lint)
	./gradlew build

lint: ## Check code style with Spotless
	./gradlew spotlessCheck

lint-fix: ## Fix code style with Spotless
	./gradlew spotlessApply

.PHONY: help test start run update-gradle update-deps install build lint lint-fix
