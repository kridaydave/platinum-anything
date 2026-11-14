# Setup and first run

plat-anything v1 is two files and one command. `prompts/route.md` is the
generation prompt, `scripts/generate.sh` is the command. ADR 0002 explains
why they live as files in the repo.

## What you need

- The Codex CLI, logged in on the ChatGPT Plus account. `~/.codex/auth.json`
  holds that login. Check with `codex login status`.
- The Playwright chromium on this machine, under `~/.cache/ms-playwright/`.
  The render script finds the newest one by itself.
- `pdfinfo` from poppler-utils, for the page count check. The script falls
  back to a grep count without it.

Nothing else. No API key, no card, no database.

## Run your Mortal Kombat route

```sh
scripts/generate.sh "Mortal Kombat 1 (2023)" "nothing, starting fresh" "safe,fastest,completionist"
```

Replace the three arguments with your real answers:

1. The game. PlayStation only.
2. Where you are. "nothing, starting fresh" is a valid answer. If you are
   mid-run or played the story out of order, say so in plain words.
3. The modes. safe, fastest, completionist, comma separated. No default:
   leaving this empty fails the run on purpose, because a route that
   silently skips content is worse than a slow one.

When it finishes it prints the PDF path, the wall clock, and the token
counts. Everything the run produced sits in `runs/<date>-<game>/`:
`prompt.txt` (exactly what was sent), `codex.jsonl`, `route.html`,
`route.pdf`, and codex's final message. `runs/` is gitignored.

## Verification status

Honest state, as of 2026-11-14:

- The render path is verified on this machine. `scripts/render-pdf.sh` was
  run against the route mockup from ticket 2 and produced a real 6 page A5
  PDF. The one page failure case also verified: the script exits non-zero
  with a loud message instead of shipping a broken PDF.
- The full generation path is NOT verified end to end. The ChatGPT Plus
  login hit its usage limit on 2026-11-14 and resets Nov 15th, 2026
  1:43 AM. `scripts/generate.sh` was exercised with a stub codex that
  follows the same contract, so the plumbing (prompt substitution, run
  directory, failure handling, render, printed wall clock and tokens)
  works, but no real route has come out of it yet.

Treat your first MK1 run as the acceptance run. If it fails, the run
directory holds everything needed to see why.

## Acceptance checklist

From SPEC.md. A run passes when all of this is true with actual reported
results, not claims:

1. The position question was asked, including whether the linear story
   order was broken, and "nothing, starting fresh" was accepted.
2. The real PowerPyx MK1 guide was fetched, the 51 trophy list was
   cross-checked against it, sources are cited. Facts the sources could
   not confirm are marked "unverified".
3. The two season-sensitive trophies, Vanquished and The Mighty Have
   Fallen, sit where the route handles them, flagged as console-only
   verification. The document states the season shelf life.
4. All three modes came out of one pass:
   - safe: pass 1 holds both season trophies with deadlines and the cost
     of missing them, pass 2 covers the other 49, no unsourced claims.
   - fastest: all 51 covered, optional work named as dropped, mastery
     grind kept with both the 10 hour and 50 hour figures, cutscene
     skipping flagged.
   - completionist: 51 on the safe spine, DLC lists appended or an
     explicit "none exist", the optional fast application stated.
   - every mode starts from the confirmed position and prints the
     generation date and season state.
5. The PDF is a real multi-page A5 document rendered outside the sandbox.
   A one page PDF fails acceptance.
6. The full route took 15 minutes or less.
7. Wall clock and token counts were recorded and reported.
8. Gaps from the run were reported honestly. A silent fallback is a
   failure.
