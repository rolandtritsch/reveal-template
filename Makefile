SHELL := /bin/bash
.DEFAULT_GOAL := help

SLIDES_ORG    := $(wildcard slides/*-slides.org)
DOCS_ORG      := $(wildcard docs/*-doc.org)
PUBLIC_SLIDES := $(patsubst slides/%.org,public/%.pdf,$(SLIDES_ORG))
PUBLIC_DOCS   := $(patsubst docs/%.org,public/%.pdf,$(DOCS_ORG))

.PHONY: help clean clean-full publish verify-slides

help: ## Show help for all targets
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

clean: ## Remove generated files from public/
	@echo "Cleaning ./public ..."
	@rm -f public/*-slides.html public/*-slides.pdf public/*-slides_with-notes.pdf public/*-doc.pdf public/*-doc.tex
	@echo "Cleaned"

clean-full: clean ## Remove all generated HTML/PDF/TeX artifacts
	@echo "Cleaning all artifacts ..."
	@find . -path ./public -prune -o \( -name '*.html' -o -name '*.pdf' -o -name '*.tex' \) -type f -print | xargs -r rm -f
	@echo "Cleaned"

public/%-slides.pdf: slides/%-slides.org
	@./scripts/build-slides.sh "$<"

public/%-doc.pdf: docs/%-doc.org
	@./scripts/build-doc.sh "$<"

publish: $(PUBLIC_SLIDES) $(PUBLIC_DOCS) ## Build and publish all slides and docs
	@mkdir -p ./public
	@ln -sfn ../images ./public/images

verify-slides: ## Screenshot generated slide PDFs into tmp/ for visual verification
	@echo "Screenshotting slide PDFs ..."
	@node ./scripts/verify-slides.cjs
	@echo "Screenshots saved to tmp/"
