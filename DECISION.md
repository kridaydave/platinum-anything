# Ticket #2 decision: map shape and mid-playthrough behavior

Settled by Kriday on ticket/2-trophy-map-shape via grill-me rounds. The full record lives in the decision comment on issue #2. Short version for anyone reading this branch.

## What the player gets

An ordered route line with guide depth. One phone-readable PDF, shaped like `mockups/a-route-line.html` with the prose depth of `mockups/c-guide-page.html` folded in per phase.

- Steps in order from the player's current position to the platinum. Each step: number, empty tick square, trophy name, tier dot, one-line requirement.
- Tags on steps carry dependency knowledge: `MISSABLE: run 1 only`, `needs step 09`. No graph.
- Each phase opens with a short prose block and a source tag.
- Stats bar includes a "route skips" line stating what the run's mode left out, so a fast-mode route can never read as a completionist one.

## Mid-playthrough behavior

One-shot document, no remembered state, nothing syncs back. Manual ticks only, per ADR 0001.

- Generation is position-aware: the model mandatorily asks "how far are you?" on every run, fresh games included. The answer maps to a route start.
- Output is a remaining-route PDF covering what is still gettable. Already-dead missables get a "locked, gone for good" line at the top.
- If a missable dies mid-run, the same harness conversation can generate a "from here" fragment PDF. The original stays untouched.

## Rejected options

- Full dependency board (mockup B): the graph answers "what blocks what" but not "what do I do tonight", needs an order living somewhere else anyway, and crossing edges do not survive phone PDF.
- Static guide page alone (mockup C): readable and printable, but nothing is tickable and the order hides in prose. Its typography and prose depth were folded into the winning shape.
- Remembered progress: needs NPSSO import or manual input plus storage, contradicts no-accounts and the manual-annotation ADR.

## Downstream

- #3: mode-to-content deltas must fit the one-sentence "route skips" line.
- #4: owns how position-aware generation executes. The shape only fixes that the position question happens at generation time and output is a remaining-route PDF.
- #1: output contract slot can be filled from this comment.
