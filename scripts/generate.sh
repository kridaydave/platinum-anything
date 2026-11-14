#!/bin/sh
# plat-anything: one command from game to PDF.
#
# Runs prompts/route.md through codex exec with the ADR 0002 flags, then
# renders the route HTML to PDF outside the sandbox. Prints the PDF path,
# wall clock and token counts, which every run has to record.
#
# usage: generate.sh "<game>" "<position>" "<modes>"
# example:
#   scripts/generate.sh "Mortal Kombat 1 (2023)" "nothing, starting fresh" \
#     "safe,fastest,completionist"

set -eu

[ "$#" -eq 3 ] || { echo "usage: generate.sh \"<game>\" \"<position>\" \"<modes>\"" >&2; exit 2; }
GAME=$1
POSITION=$2
MODES=$3
REPO=$(cd "$(dirname "$0")/.." && pwd)

[ -n "$MODES" ] || { echo "generate.sh: mode is a required input, no default. Name safe, fastest, completionist, or a comma separated mix." >&2; exit 2; }
for m in $(printf '%s' "$MODES" | tr ',' ' '); do
  case $m in safe|fastest|completionist) ;; *)
    echo "generate.sh: unknown mode '$m'. Modes are safe, fastest, completionist." >&2
    exit 2 ;;
  esac
done

# Run directory: everything a run produced stays together and git ignores it.
SLUG=$(printf '%s' "$GAME" | tr '[:upper:]' '[:lower:]' | tr -c '[:alnum:]' '-' | sed 's/-\{2,\}/-/g; s/^-//; s/-$//')
RUN="$REPO/runs/$(date +%Y%m%d-%H%M%S)-$SLUG"
mkdir -p "$RUN/mockups"

# Fill the input block and send a copy, so the committed prompt stays clean
# and the run dir holds exactly what was sent.
esc() { printf '%s' "$1" | sed 's/[&|\]/\\&/g'; }
sed -e "s|{{GAME}}|$(esc "$GAME")|g" \
    -e "s|{{POSITION}}|$(esc "$POSITION")|g" \
    -e "s|{{MODES}}|$(esc "$MODES")|g" \
    "$REPO/prompts/route.md" > "$RUN/prompt.txt"
if grep -qE '\{\{(GAME|POSITION|MODES)\}\}' "$RUN/prompt.txt"; then
  echo "generate.sh: unresolved placeholder in the prompt, aborting. See $RUN/prompt.txt" >&2
  exit 1
fi
cp "$REPO/mockups/a-route-line.html" "$RUN/mockups/a-route-line.html"

START=$(date +%s)
echo "plat-anything: game \"$GAME\", position \"$POSITION\", modes \"$MODES\""
echo "plat-anything: run dir $RUN"
echo "plat-anything: codex is researching. Full routes take 6 to 10 minutes."

codex exec --json --skip-git-repo-check -C "$RUN" \
  -s workspace-write -c approval_policy="never" -c tools.web_search=true \
  -o "$RUN/last-message.txt" \
  "$(cat "$RUN/prompt.txt")" \
  > "$RUN/codex.jsonl" 2> "$RUN/codex.err" \
  || {
    rc=$?
    echo "generate.sh: codex exec failed (exit $rc). Look at $RUN/codex.err and $RUN/codex.jsonl" >&2
    echo "generate.sh: wall clock $(( $(date +%s) - START ))s" >&2
    exit "$rc"
  }

[ -f "$RUN/route.html" ] || {
  echo "generate.sh: codex did not write route.html. Its final message is in $RUN/last-message.txt" >&2
  exit 1
}

"$REPO/scripts/render-pdf.sh" "$RUN/route.html" "$RUN/route.pdf" 2

ELAPSED=$(( $(date +%s) - START ))
# Token usage rides the JSONL events. Parse what is there; if the shape
# changed, say so instead of printing a fake number.
USAGE=$(jq -c 'select(.type=="token_count") | .info' "$RUN/codex.jsonl" 2>/dev/null | tail -1)
echo ""
echo "plat-anything: done"
echo "plat-anything: PDF: $RUN/route.pdf"
echo "plat-anything: wall clock: ${ELAPSED}s ($(( ELAPSED / 60 ))m $(( ELAPSED % 60 ))s)"
if [ -n "$USAGE" ]; then
  echo "plat-anything: token usage: $USAGE"
else
  echo "plat-anything: token usage: not reported in codex.jsonl, read it from $RUN/codex.jsonl"
fi
