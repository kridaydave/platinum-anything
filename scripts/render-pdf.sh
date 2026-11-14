#!/bin/sh
# Render a route HTML to PDF with the Playwright chromium on this machine.
#
# This runs outside the Codex sandbox on purpose: chromium cannot start
# inside it, and the sandbox fallback used to ship a silent one page PDF.
# This script is the loud version of that fix. A PDF with fewer pages than
# asked for exits non-zero.
#
# usage: render-pdf.sh <input.html> [output.pdf] [min-pages]

set -eu

[ "$#" -ge 1 ] || { echo "usage: render-pdf.sh <input.html> [output.pdf] [min-pages]" >&2; exit 2; }
HTML=$1
PDF=${2:-${HTML%.html}.pdf}
MIN=${3:-2}
case $MIN in ''|*[!0-9]*) echo "render-pdf: min-pages must be a number, got '$MIN'" >&2; exit 2;; esac

[ -f "$HTML" ] || { echo "render-pdf: no such file: $HTML" >&2; exit 2; }

# Find the chromium binary, newest version first. No version numbers in here.
CHROME=$(ls -d "$HOME"/.cache/ms-playwright/chromium-*/chrome-linux64/chrome 2>/dev/null | sort -V | tail -1)
[ "$CHROME" ] || { echo "render-pdf: no Playwright chromium under ~/.cache/ms-playwright, install it first" >&2; exit 2; }

# The route HTML sets its own page size. Without an @page rule the PDF comes
# out Letter and loses the A5 phone shape, so warn.
grep -qi '@page' "$HTML" || echo "render-pdf: warning: $HTML has no @page rule, the PDF will not be A5" >&2

"$CHROME" --headless --disable-gpu --no-sandbox --no-pdf-header-footer \
  --print-to-pdf="$PDF" "$HTML" 2>/dev/null
[ -s "$PDF" ] || { echo "render-pdf: chromium wrote no PDF at $PDF" >&2; exit 1; }

count_pages() {
  if command -v pdfinfo >/dev/null 2>&1; then
    pdfinfo "$1" | sed -n 's/^Pages: *//p'
  else
    # No pdfinfo. Chromium does not use object streams, so page objects are
    # plain text in the file. /Page[^s] skips the /Pages tree root.
    grep -ao '/Type */Page[^s]' "$1" | wc -l
  fi
}

PAGES=$(count_pages "$PDF")
if [ "$PAGES" -lt "$MIN" ]; then
  echo "render-pdf: FAILED: $PDF has $PAGES page(s), minimum is $MIN." >&2
  echo "render-pdf: a one page PDF is the exact silent failure this script exists to catch. The route is broken, do not use this PDF." >&2
  exit 1
fi
echo "render-pdf: $PDF ($PAGES pages)"
