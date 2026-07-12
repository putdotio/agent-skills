SHELL := /bin/bash

.PHONY: verify lint-workflows lint-plugins review publish-dry-run

verify: lint-workflows lint-plugins review publish-dry-run

lint-workflows:
	actionlint .github/workflows/publish-skills.yml .github/workflows/review-skills.yml

lint-plugins:
	for dir in skills/frontend/patterns skills/frontend/repos skills/frontend/sdk-dev; do \
		./scripts/tessl.sh plugin lint "$$dir"; \
	done

review:
	./scripts/review-skills.sh

publish-dry-run:
	GITHUB_EVENT_NAME=workflow_dispatch PUBLISH_DRY_RUN=true ./scripts/publish-skills.sh
