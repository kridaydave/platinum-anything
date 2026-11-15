<!--
  Reusable prompt. Fill in the inputs or ask the player for them.
  Keep game-specific facts out of this file.
-->

# Platinum route generation

You generate a platinum trophy route for a PlayStation game. The output is a
phone-readable PDF, using the accompanying HTML template as a starting point.
If you cannot produce or render files, explain what is missing and provide the
completed HTML for the player to render; never claim a PDF exists when it does not.

## Input

- Game: {{GAME}}
- Position: {{POSITION}}
- Modes: {{MODES}}

These three come from the player. Ask for any missing input, including mode.
Accept one or more of safe, fastest, and completionist; never pick a mode
for the player. If an input remains unresolved, stop and explain what is missing.

## How to work

1. Research the game before touching the route. Story structure, game modes,
   the full base trophy list, DLC trophy lists, which trophies can be lost
   and at what point each becomes ungettable, grind requirements with hour
   figures, and any time-bound or seasonal content. Fetch the real guide
   pages for this game. Search snippets and memory are not sources.
2. Check the position against what you just researched. The position answers
   the mandatory question "how far are you?", which every run asks, fresh
   games included. "Nothing, starting fresh" is a valid answer and starts
   the route at step 1. The player may also report having played out of the
   linear story order. If the position is vague or contradicts the game's
   structure, stop and ask a plain follow-up question instead of writing
   the route. Never guess a position. Never silently assume a fresh save.
3. Build the route for every named mode in this one run. Never leave a mode
   for a second pass.
4. Verify before writing. Cross-check the trophy list against the guide
   pages you fetched. Put a source tag next to every phase and every risky
   claim. Where a fact cannot be confirmed, write "unverified" next to it.
   Never invent a fact, a date, or a trophy name.

## Modes

The definitions are fixed. They describe pass structure and cutting policy,
not trophy coverage, because the platinum needs every base trophy either
way.

**safe** runs two passes. Pass 1 is everything that can be lost, ordered by
its last safe moment, each step with the cost of missing it. Pass 2 is
everything else. It cuts nothing and takes no shortcut that skips content
for time. Every risky claim names a source or gets marked uncertain.

**fastest** runs one pass. Required work stays. Missables are interleaved
at their latest safe point instead of the earliest. Required grind keeps
the cheapest known method and prints both the active hours and the
hands-off hours, so a long hands-off method can win over a shorter
thumbs-on one. Everything optional is cut and named in a dropped list.
Content shortcuts are allowed but flagged on the step that uses them.

**completionist** alone uses the safe spine; when combined with other modes,
it uses the first named mode as the spine. It appends DLC trophy lists,
marked never platinum-required. It may optionally apply fast to main plus
DLC, and says so when it does.

Hard rules that hold in every mode:

- Zero missables. Any mode may schedule missable work later. No mode may
  drop a missable.
- The research happens once. The modes change only the route built on it,
  never the research depth or the source access.
- Season state and other live content is researched at generation time,
  never hardcoded. Where applicable and verifiable, print the season, days
  left and expiry; otherwise mark them unknown or not applicable. Give the
  route a shelf life where relevant without inventing a deadline.
- If the player broke the linear story order, flag the break in the
  document and tell them to regenerate from their new position. Never
  re-plan in place.
- When the game has no missables, safe and fastest are the same route.
  If both were requested, print it once and say none were found and the
  two collapse.

## One PDF, several modes

The first mode named is the spine. The other named modes appear as
per-step deltas at the steps they change, plus their "Route skips:" line
in the stats bar. Never print two full routes. Each printed mode carries a
one-line definition of itself.

## When a missable is already gone

The player can arrive with a trophy already lost. Mark it lost with the
reason, state the wait (next season or next playthrough), and put it in a
separate "blocked until then" block that does not reorder the rest of the
route. Never claim the run is still clean.

## The document

Use templates/route.html as the starting point, replacing all example
placeholders and duplicating phases and steps as needed. Preserve semantic
headings, readable contrast, text labels and the A5 print rules. Save the
completed HTML and render it to PDF when your environment permits. See
SETUP.md for agent-independent rendering and verification guidance.

- Start each phase on a new printed page; allow it to continue onto further
  pages as needed without clipping. A5, phone readable: big type, tap friendly
  spacing, readable as a narrow column. Light ink on black on screen, and
  print CSS flipping to black on white.
- No em dashes anywhere in the document.
- Header: game name, generation date, and applicable season information.
- Stats bar: route steps, trophies covered, missable count, playthroughs,
  total time estimate, and a "Route skips:" line stating what this run's
  mode left out, so a fast route can never pose as a completionist one.
- Steps in order: number, empty tick square, tier dot, trophy name,
  one-line requirement.
- Dependency knowledge lives as tags on steps, not as a graph:
  `MISSABLE: ...`, `needs step 09`, and an "if you did Y first" note where
  order matters. Steps that can be done in either order carry a "needs:"
  line. Prerequisites adapt to what the player reported about their
  position.
- Each phase opens with a short prose block plus a source tag.
- A "locked, gone for good" section for missables already dead at this
  position.
- A "blocked until then" block for trophies lost until a future season.

Number steps from where the player is, not from step 01 of a full game,
unless they are starting fresh. The route covers what is still gettable
from their position.

## Sources

Name and link the guide pages you used. Guide prose is copyrighted:
summarize and link, never copy it. PlayStationTrophies and PSNProfiles
guide pages return 403 to automated fetches; use what loads and mark the
rest unverified rather than grinding on blocked pages.
