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

# The route HTML should carry its own @page rule. If it does not name a page
# size, inject the A5 default into a temp copy so the PDF is always the right
# shape. A Letter PDF on a phone is small type on a wrong shape, the same
# class of silent failure as the one page PDF. The input file is never
# modified.
TMP=""
trap 'rm -f "$TMP"' EXIT INT TERM
SRC=$HTML
SIZE_NOTE="page size from the input's own @page rule"
# The rule may span lines, so awk over lowercased lines: once inside an
# @page block, look for "size" before the block closes.
if ! awk '{l=tolower($0)} l ~ /@page/{inp=1} inp && l ~ /size/{f=1} l ~ /}/{inp=0} END{exit f?0:1}' "$HTML"; then
  SRC=$(mktemp /tmp/route-page-XXXXXX.html)
  TMP=$SRC
  if grep -qi '</head>' "$HTML"; then
    sed "s|</head>|<style>@page { size: A5; margin: 13mm 12mm; }</style>\n</head>|i" "$HTML" > "$SRC"
  else
    { cat "$HTML"; printf '\n<style>@page { size: A5; margin: 13mm 12mm; }</style>\n'; } > "$SRC"
  fi
  SIZE_NOTE="default A5 supplied by render-pdf.sh"
fi

"$CHROME" --headless --disable-gpu --no-sandbox --no-pdf-header-footer \
  --print-to-pdf="$PDF" "$SRC" 2>/dev/null
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
echo "render-pdf: $PDF ($PAGES pages, $SIZE_NOTE)"
