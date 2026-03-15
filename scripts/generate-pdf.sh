#!/bin/bash
# Generate PDF files from org files (docs)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

shopt -s nullglob globstar
mapfile -t ORG_FILES < <(find "${REPO_ROOT}" -name '*-doc.org' -type f)

if [ ${#ORG_FILES[@]} -eq 0 ]; then
    echo "No .org files found in ${REPO_ROOT}" >&2
    exit 1
fi

FAILED=0

for FILE in "${ORG_FILES[@]}"; do
    echo "  Generating PDF from ${FILE}"
    if ! emacs --batch -Q \
        --eval "(setq package-user-dir (expand-file-name \"~/.emacs.d/elpa\"))" \
        --eval "(package-initialize)" \
        --eval "(require 'org)" \
        --eval "(require 'ox-latex)" \
        --visit "${FILE}" \
        --eval "(condition-case err (org-latex-export-to-pdf) (error (message \"Error exporting %s: %s\" \"${FILE}\" err) (kill-emacs 1)))" \
        2>/dev/null; then
        echo "  ERROR: failed to export ${FILE}" >&2
        FAILED=1
    fi
done

# find "${REPO_ROOT}" -name '*.tex' -type f -delete

exit ${FAILED}
