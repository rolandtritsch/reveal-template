#!/bin/bash
# Generate Reveal.js HTML files from *-slides.org files in the repo

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

shopt -s nullglob globstar
mapfile -t ORG_FILES < <(find "${REPO_ROOT}" -name '*-slides.org' -type f)

if [ ${#ORG_FILES[@]} -eq 0 ]; then
    echo "No *-slides.org files found under ${REPO_ROOT}" >&2
    exit 1
fi

FAILED=0

for FILE in "${ORG_FILES[@]}"; do
    echo "  Generating HTML from ${FILE}"
    if ! emacs --batch -Q \
        --eval "(add-to-list 'load-path (expand-file-name \"~/.emacs.d/lisp\"))" \
        --eval "(setq package-user-dir (expand-file-name \"~/.emacs.d/elpa\"))" \
        --eval "(package-initialize)" \
        --eval "(require 'org)" \
        --eval "(require 'ox-reveal)" \
        --eval "(setq org-reveal-root \"https://cdn.jsdelivr.net/npm/reveal.js\")" \
        --visit "${FILE}" \
        --eval "(save-excursion (goto-char (point-min)) (while (re-search-forward \"{{{time(%Y-%m-%d_%H:%M:%S)}}}\" nil t) (replace-match (format-time-string \"%Y-%m-%d_%H:%M:%S\"))))" \
        --eval "(condition-case err (org-reveal-export-to-html) (error (message \"Error exporting %s: %s\" \"${FILE}\" err) (kill-emacs 1)))" \
        2>/dev/null; then
        echo "  ERROR: failed to export ${FILE}" >&2
        FAILED=1
    else
        HTML="${FILE%.org}.html"
        sed -i 's|</head>|<style>.reveal .slide-number { right: auto; left: 0; width: 100%; text-align: center; background: transparent; color: #333; }</style>\n</head>|' "${HTML}"
        sed -i 's|Reveal.initialize({|Reveal.initialize({\n  slideNumber: "c/t",|' "${HTML}"
    fi
done

exit ${FAILED}
