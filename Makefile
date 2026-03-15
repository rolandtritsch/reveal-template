SHELL := /bin/bash
.DEFAULT_GOAL := help

PUBLISH_PATTERNS := *-slides.html *-slides.pdf *-slides_with-notes.pdf *-doc.pdf *-doc.tex

.PHONY: help
help: ## Show help for all targets
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: clean
clean: ## Remove published files from public/
	@echo "Cleaning files from public ..."
	@for pattern in $(PUBLISH_PATTERNS); do rm -f ./public/$$pattern; done
	@echo "Cleaned"

.PHONY: fix-reveal-notes
fix-reveal-notes: ## Patch Reveal.js 3.x/4.x in all generated HTML files
	@echo "Fixing Reveal.js 3.x/4.x ..."
	@./scripts/fix-reveal-notes.sh
	@echo "All HTML files fixed"

.PHONY: generate-html
generate-html: ## Generate Reveal.js HTML files from org files (slides)
	@echo "Generating HTML files from org files ..."
	@./scripts/generate-html.sh
	@echo "All HTML files generated"

.PHONY: generate-print-pdf
generate-print-pdf: ## Generate PDF files from Reveal.js HTML slides via Puppeteer
	@echo "Generating PDFs from Reveal.js HTML slides ..."
	@./scripts/generate-print-pdf.sh
	@echo "All presentation PDFs generated"

.PHONY: generate-pdf
generate-pdf: ## Generate PDF files from org files in lectures/
	@echo "Generating PDF files from org files ..."
	@./scripts/generate-pdf.sh
	@echo "All PDF files generated"

.PHONY: verify-slides
verify-slides: ## Screenshot generated slide PDFs into tmp/ for visual verification
	@echo "Screenshotting slide PDFs ..."
	@node ./scripts/verify-slides.cjs
	@echo "Screenshots saved to tmp/"

.PHONY: publish
publish: generate-pdf generate-html fix-reveal-notes generate-print-pdf ## Move generated HTML/PDF files to public/
	@echo "Publishing HTML/PDF files to public ..."
	@for pattern in $(PUBLISH_PATTERNS); do find . -not -path './public/*' -name "$$pattern" -type f | xargs -I {file} mv {file} ./public; done
	@echo "Published successfully"
