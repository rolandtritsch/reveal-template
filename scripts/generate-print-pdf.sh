#!/bin/bash
# Generate PDF files from Reveal.js HTML slides via Puppeteer.
# Requires: npm install -g puppeteer

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
export NODE_PATH="$(npm root -g)"

shopt -s nullglob globstar
mapfile -t HTML_FILES < <(find "${REPO_ROOT}"  -not -path './public/*' -name '*-slides.html' -type f)

if [ ${#HTML_FILES[@]} -eq 0 ]; then
    echo "No .html files found" >&2
    exit 1
fi

FAILED=0

for FILE in "${HTML_FILES[@]}"; do
    PDF="${FILE%.html}.pdf"
    PDF_NOTES="${FILE%.html}_with-notes.pdf"

    echo "  Generating PDF from ${FILE}"
    if ! node "${SCRIPT_DIR}/print-slides.cjs" "file://${FILE}" "${PDF}"; then
        echo "  ERROR: failed to convert ${FILE}" >&2
        FAILED=1
    fi

    echo "  Generating PDF with notes from ${FILE}"
    if ! node "${SCRIPT_DIR}/print-slides.cjs" "file://${FILE}" "${PDF_NOTES}" --notes; then
        echo "  ERROR: failed to convert ${FILE} (with notes)" >&2
        FAILED=1
    fi
done

exit ${FAILED}
