#!/bin/bash
# Patch Reveal.js notes plugin in a generated HTML file.
# Usage: fix-reveal-notes.sh <file.html>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FILE="$1"
TMP="${FILE}.tmp"

echo "  Fixing ${FILE}"

# Check if already patched
if grep -q "plugins: \[ RevealNotes \]" "${FILE}" && ! grep -q "dependencies:" "${FILE}"; then
    echo "  Already fixed: ${FILE}"
    exit 0
fi

# Rewrite Reveal.initialize block (removes dependencies, adds plugins)
awk -f "${SCRIPT_DIR}/fix-reveal-notes.awk" "${FILE}" > "${TMP}" && mv "${TMP}" "${FILE}"

# Add notes.js if missing (ox-reveal hardcodes the 3.x path; reveal.js 4.x moved it)
if ! grep -q "plugin/notes/notes.js" "${FILE}"; then
    sed -i '/<script src="https:\/\/cdn.jsdelivr.net\/npm\/reveal.js\/dist\/reveal.js"><\/script>/a\<script src="https://cdn.jsdelivr.net/npm/reveal.js/plugin/notes/notes.js"></script>' "${FILE}"
fi

# Fix print CSS path (3.x -> 4.x)
sed -i 's|reveal\.js/css/print/pdf\.css|reveal.js/dist/print/pdf.css|g' "${FILE}"

# Remove dead pdf.css dynamic-injection script block
awk -f "${SCRIPT_DIR}/fix-print-pdf.awk" "${FILE}" > "${TMP}" && mv "${TMP}" "${FILE}"
