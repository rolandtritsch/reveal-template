#!/bin/bash
# Patch Reveal.js notes plugin in all generated HTML files in slides/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

shopt -s nullglob globstar
mapfile -t HTML_FILES < <(find "${REPO_ROOT}"  -not -path './public/*' -name '*-slides.html' -type f)

if [ ${#HTML_FILES[@]} -eq 0 ]; then
    echo "No .html files found in ${REPO_ROOT}" >&2
    exit 1
fi

FAILED=0

for FILE in "${HTML_FILES[@]}"; do
    echo "  Fixing ${FILE}"

    # Check if already fixed
    if grep -q "plugins: \[ RevealNotes \]" "${FILE}" && ! grep -q "dependencies:" "${FILE}"; then
        echo "  Already fixed: ${FILE}"
        continue
    fi

    TMP_FILE="${FILE}.tmp"
    awk -f "${SCRIPT_DIR}/fix-reveal-notes.awk" "${FILE}" > "${TMP_FILE}"
    mv "${TMP_FILE}" "${FILE}"

    # Fix notes script path: ox-reveal hardcodes the 3.x path; reveal.js 4.x moved it
    if ! grep -q "plugin/notes/notes.js" "${FILE}"; then
        sed -i '/<script src="https:\/\/cdn.jsdelivr.net\/npm\/reveal.js\/dist\/reveal.js"><\/script>/a\<script src="https://cdn.jsdelivr.net/npm/reveal.js/plugin/notes/notes.js"></script>' "${FILE}"
    fi

    # Fix print CSS path: ox-reveal hardcodes the 3.x path; reveal.js 4.x moved it
    sed -i 's|reveal\.js/css/print/pdf\.css|reveal.js/dist/print/pdf.css|g' "${FILE}"

    # Replace dynamic pdf.css injection with a static link
    awk -f "${SCRIPT_DIR}/fix-print-pdf.awk" "${FILE}" > "${TMP_FILE}"
    mv "${TMP_FILE}" "${FILE}"
done

find "${REPO_ROOT}" -name '*.tmp' -type f -delete

exit ${FAILED}
