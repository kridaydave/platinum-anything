# plat-anything v1 spec

Status: all four decisions are in and the spec is buildable. [Issue #1](https://github.com/kridaydave/platinum-anything/issues/1) closes with this update; no slot below is still a question.

## Destination and settled constraints

From issue #1:

- Give the tool a PlayStation game and get the best route to its platinum trophy. #3 settled what "best" means: safe, fastest, or completionist, chosen per run.
- The product name is plat-anything. The GitHub slug stays platinum-anything.
- PlayStation only. The audience is gamers, with Kriday first.
- AI does web search and text generation only. PDF rendering is ordinary software.
- First acceptance case is Kriday's own Mortal Kombat platinum run.
- Keep v1 small. No accounts, billing, or multi-user hosting. A public launch is a separate later effort.
- If v1 has a UI, use true dark mode with a black background and white text.
- Use real data and report real results. No faked results.

Xbox, Steam, and Switch support are out of scope.

## Data findings and limits

[Issue #6](https://github.com/kridaydave/platinum-anything/issues/6) is closed. Its [findings](https://github.com/kridaydave/platinum-anything/blob/research/ps-trophy-data/research/ps-trophy-data/findings.md) live on `research/ps-trophy-data`, not on this branch. Read them locally with:

```sh
git fetch origin research/ps-trophy-data
git show origin/research/ps-trophy-data:research/ps-trophy-data/findings.md
```

These are research findings, not a selected v1 data pipeline:

| Source | What #6 established | Constraint carried into the spec |
| --- | --- | --- |
| PSN API | Trophy definitions and earned status are available through an undocumented, reverse-engineered API. | Access needs the user's NPSSO token. This is not an official, stable public API. Its availability does not commit v1 to PSN login or progress import. |
| PSNProfiles | Trophy lists and guides exist, but the research fetch returned HTTP 403. | Do not assume scraper access. Respect reference-use signals, the ban on AI training, and site terms. |
| PowerPyx | Human-written roadmaps cover missables, difficulty, playthroughs, and trophy tips. HTML was accessible in #6. | No structured API. Attribution does not grant permission to copy copyrighted guide text. |
| PlayStationTrophies.org | Trophy lists and guides exist. Robots rules distinguish allowed list paths from blocked deeper paths, and a tested page returned HTTP 403. | Availability varies by path. Do not scrape blocked paths or assume guides are fetchable. |
| Fandom and other game wikis | Trophy lists and walkthrough details can be available through HTML or MediaWiki. | Check each source's terms. Fandom's CC-BY-SA content requires attribution and share-alike compliance for reuse. |

Issue #1 summarizes PowerPyx, PlayStationTrophies.org, and Fandom as scrapeable with attribution. The detailed #6 findings qualify that summary. Accessibility and reuse rights are separate checks. Link or summarize sources with attribution within their terms, rather than treating accessible guide text as free to copy.

The #6 survey found trackers, static roadmaps, and AI guide repositories, but no tool that generated ordered platinum routes using trophy dependencies, missables, and earned status. That is a bounded research finding, not proof that none exists. The research's suggested PSN-plus-guides approach remains a suggestion, not a v1 decision.

The #4 measurement runs confirmed the #6 access picture on this machine: the PowerPyx MK1 guide fetches over plain curl (16.2k words, about 22k tokens), while PlayStationTrophies guide pages return 403 and PSNProfiles returns 403. Guide prose is copyrighted, so the route summarizes and links rather than copies.

## Settled decisions

Four tickets have decided. Each decision lives in its issue comment and, for #3, #4, and #5, in an ADR on this branch.

### V1 form: harness-generated PDF (#5, ADR 0001)

V1 is a personal workflow. Kriday runs a coding-agent harness on his computer, the harness researches the game and produces a sourced, phone-readable PDF route, and he transfers the PDF to his phone. The PDF reads offline and he annotates it in his PDF reader as he plays. The v1 surface is the harness conversation itself: game and constraints in, PDF out. No account, no app-managed progress, no separate application API key.

Rejected with reasons: a local web app adds a server for little benefit, a standalone CLI duplicates the harness interface, a deployed site adds hosting and multi-user work that belong to a later public effort. Route content and attribution can inform a public site later, but the harness session, its credentials, and manual transfer do not become a hosted service on their own.

### Map shape and mid-playthrough behavior (#2)

The player gets a phone-readable PDF shaped as an ordered route line with guide depth folded in: numbered steps from where the player is now to the platinum. Each step has a number, an empty tick square, the trophy name, a tier dot, and a one-line requirement. Dependency knowledge lives as tags on steps, not as a graph: `MISSABLE: run 1 only`, `needs step 09`. Each phase opens with a short prose block plus a source tag. The stats bar carries a "route skips" line stating what the run's mode left out, so a fast route can never masquerade as a completionist one.

Mid-playthrough is one-shot and position-aware. Nothing remembers state and nothing syncs back; ticks are manual marks in the PDF reader or on paper. The model asks "how far are you?" on every run, fresh games included, and the answer produces a remaining-route PDF covering what is still gettable from that position. Dead missables get a "locked, gone for good" line at the top. If a missable dies mid-run, the same harness conversation can generate a short "from here" fragment PDF; the original stays untouched.

Rejected with reasons: a full dependency board cannot tell a player what to do tonight and does not survive a phone PDF, a static guide page alone is what PowerPyx already gives away free (its typography was folded into the winner), and remembered progress needs NPSSO import or stored progress input, both of which contradict the no-accounts v1 and manual annotations.

### Route modes: safe, fastest, completionist (#3, ADR 0003)

V1 ships three modes: safe, fastest, and completionist. Mode is a required input next to the position answer, with no default, because a route that silently skips content is worse than a slow one and the PDF gets read on a phone where a missing warning is easy to miss. Zero missables is a hard rule in every mode, not a safe-only feature: any mode may schedule missable work later, none may drop it.

The modes are defined by pass structure and cutting policy, not by trophy coverage. The platinum needs every base trophy, so coverage alone made safe and completionist print the same list; that definition died in the grilling.

- **safe** runs two passes. Pass 1 is everything that can be lost, ordered by its last safe moment. Pass 2 is everything else. It cuts nothing, takes no shortcut that skips content for time, and sources or flags every risky claim.
- **fastest** runs one pass. Required work stays. Missables are interleaved at their latest safe point instead of the earliest. Required grind keeps the cheapest known method and prints both the active hours and the hands-off hours. Everything optional is cut and listed as dropped. Content shortcuts are allowed but flagged. Fastest optimizes Kriday's attention, not the clock: on MK1 the mastery grind is 10 hours playing or about 50 hours with the AFK turbo method, and fastest recommends the second while printing both.
- **completionist** uses the safe spine for the main list plus DLC trophy lists, marked never platinum-required, with an optional fast application over main plus DLC.

Modes never change research depth. The research happens once and the modes change only the route built on it. #4 measured a second and third mode in the same run at about 3 extra minutes and 8k output tokens.

One PDF carries several modes. The first mode named is the spine and the rest print as per-step deltas plus the "route skips" line #2 built into the stats bar, so a single generated route is the spine plus overlays, not three stacked routes. When a game has no missables, safe and fastest collapse to one printed route, with one line saying safe was requested and none were found. Completionist alone takes the safe spine; riding along with another mode, it takes that mode's spine, so the document never contradicts itself.

The position ask extends too. The model researches the game's story and mode structure first, then asks where the player is, including whether the player broke the linear story order. Steps that can be done in either order get a "needs:" line and, where order matters, an "if you did Y first" note, and prerequisites adapt to what the player reports. No guessed position, no silent fresh save. V1 never re-plans in place: when the player played out of order, the PDF flags the break and says to regenerate from the new position.

If a missable is already gone when the player arrives, for example a Titan that never spawned or a story missable already passed, the route marks it lost with the reason, states the wait (next season or next playthrough), and puts it in a separate "blocked until then" block that does not reorder the rest. It never claims the run is still clean.

Season state is researched live at generation time instead of hardcoded, with the method left to generation. The PDF header prints the generation date, the season number, and the days left, and every season-bound step carries its expiry, so an old PDF shows its age rather than looking current.

Rejected with reasons: three independent full routes in one PDF (spine plus deltas is cheaper and phone-readable), dropping completionist (Kriday wants all three), a default mode when none is stated, one mode per PDF (overruled by Kriday after the first recommendation), auto re-planning on out-of-order play (in-place reordering is a different feature), modes changing research depth or source access, DLC treated as platinum-required, and defining modes by trophy coverage.

The decision record is [ADR 0003](docs/decisions/0003-route-modes.md).

### Generation power (#4, ADR 0002)

v1 generates routes on Kriday's own machine with the Codex CLI, driving his ChatGPT Plus login. The backend is `codex exec` with `tools.web_search=true` on the Codex default model `gpt-6-luna`; Sol stays the fallback for routes that come back weak. Codex does the web search, fetches the guide pages, checks its own work, writes the route, and the PDF renders outside the Codex sandbox with Playwright chromium. No metered LLM API key is part of v1. Measured: a full 51-trophy route costs about $0.06 metered and takes 9.6 minutes, three modes in one pass cost the same as one, and out-of-pocket is $0 because the runs ride the Plus subscription. The real cost is plan quota, which peaked at 34% of the primary window over a week.

Rejected with reasons: one API call with built-in search costs about ten times as much, needs a billed account that does not exist here, and works from snippets rather than the real guide page. A hybrid split adds a card, a key, and a second way to fail. Shipping the harness to gamers contradicts the no-hosting v1.

The decision record is [ADR 0002](docs/decisions/0002-generation-power.md); the measurements are in `NOTES.md` on `ticket/4-generation-power`.

## Operational requirements from the #4 measurement runs

These are not preferences. Each one comes from a run that failed or cost extra without it, so the implementation has to follow them.

- `codex exec` needs `-s workspace-write` and `-c approval_policy="never"`, plus `-c tools.web_search=true`. Without the sandbox flags, writes get rejected with "patch rejected: writing is blocked by read-only sandbox".
- The PDF render runs outside the Codex sandbox, using the Playwright chromium already installed. Chromium cannot start inside the sandbox, and the fallback the agent then produces silently ships a one page PDF instead of the real 13 to 14 page one. A run that produces a one page PDF is a failed run, not a small route.
- One generation run emits every named mode in a single cold pass. Adding modes later as a warm second turn re-sends the whole cached context and cost nearly double ($0.075 extra on luna versus $0.040 for all three modes in one pass).
- The verification loop is mandatory: fetch the real guide pages, cross-check the trophy list, cite sources, and write "unverified" rather than inventing a fact.
- Caps for any future metered backend: $1 per route and $5 per game. Every run records wall clock and token counts so this spec can state real spend instead of a guess.
- Latency targets: a full route inside 15 minutes, a "from here" fragment inside 3. Measured runs took 5.7 to 9.6 minutes for full routes.
- Routes have a season shelf life. Mortal Kombat 1 (2023) has two season-sensitive trophies, Vanquished and The Mighty Have Fallen, tied to the Invasions season. Season state is researched live at generation time, not hardcoded, and the PDF header prints the generation date, the season number, and the days left. A route for that game must be regenerated when the season turns over, and the measured route put the two season-sensitive trophies first while flagging that event availability can only be verified on the console.
- The prompt and the render command are the product now, so they live as files in the repo, not in chat history.

## Decision tree

All four decisions are settled. They meet at the mode-aware route contract.

```text
Settled: PlayStation game -> LLM-generated trophy map -> platinum route
|
+-- #2 Map shape and mid-playthrough behavior [SETTLED]
|   +-- route line with guide depth, one-shot position-aware PDF, manual ticks
|
+-- #3 Route modes and meaning of "best" [SETTLED]
|   +-- safe, fastest, completionist; mode required, no default; spine plus deltas
|
+-- #4 Generation power [SETTLED]
|   +-- local Codex harness, no metered key, measured cost and latency
|
+-- #5 V1 form [SETTLED]
    +-- harness conversation in, phone-readable PDF out

#3 -> mode definitions, per-mode route changes, and spine-plus-deltas emission
#2 + #4 -> position-aware generation (settled: mandatory position question, remaining-route PDF)
#2 + #3 + #4 + #5 -> end-to-end v1 contract and Mortal Kombat acceptance
```

## Open slots and ownership

| Slot | Owning ticket | Status | Detail |
| --- | --- | --- | --- |
| Map shape | [#2](https://github.com/kridaydave/platinum-anything/issues/2) | SETTLED | Ordered route line with guide depth, one-shot position-aware PDF, manual ticks. See the decision comment on #2. |
| Mid-playthrough behavior | #2 | SETTLED | One-shot document, no remembered state, mandatory position question every run, remaining-route PDF, "from here" fragments from the same conversation. |
| Route modes | [#3](https://github.com/kridaydave/platinum-anything/issues/3) | SETTLED | safe, fastest, completionist. Mode is a required input with no default, zero missables is a hard rule in every mode, and the modes are defined by pass structure and cutting policy, not trophy coverage. One PDF carries several modes as a spine plus per-step deltas. See the decision comment on #3 and ADR 0003. |
| Generation power | [#4](https://github.com/kridaydave/platinum-anything/issues/4) | SETTLED | Local Codex harness on the ChatGPT Plus login, no metered key. Backend, flags, render location, one-pass modes, verification loop, caps, and latency are in the decision comment and ADR 0002. |
| Route spend | #4, folded into #1 | SETTLED | Measured: $0.04 to $0.06 metered per route on luna, $0 out of pocket on the Plus plan. If a metered backend is ever used, the ceiling is $1 per route and $5 per game. Every run records wall clock and token counts. |
| V1 form | [#5](https://github.com/kridaydave/platinum-anything/issues/5) | SETTLED | Harness-generated PDF, harness conversation is the surface, manual annotations, no accounts or hosting. See the decision comment on #5 and ADR 0001. |

## End-to-end contract

These slots belong to #1's integration work. They follow the owning tickets rather than introduce competing product choices.

### Input contract (settled for v1)

The player supplies two things, both through the harness conversation:

- The game, identified by name. PlayStation only.
- The position: an answer to the mandatory "how far are you?" question, asked on every run including fresh games. "Nothing, starting fresh" is a valid answer and starts the route at step 1.
- The mode: safe, fastest, or completionist, named at generation time next to the position answer. Mode is required with no default. A run without one fails the input contract; it does not pick for the player.

PSN import is not part of v1 and no progress state is stored.

### Generation contract (settled for v1)

A v1 run is Codex CLI on Kriday's machine, riding the ChatGPT Plus login, on `gpt-6-luna` with Sol as the fallback for weak routes, `tools.web_search=true`, and the workspace-write sandbox flags from the operational section. The run fetches real guide pages (PowerPyx confirmed reachable; PlayStationTrophies and PSNProfiles confirmed 403), runs the mandatory verification loop, and writes the route. The PDF render runs outside the Codex sandbox with Playwright chromium. One run emits every named mode. The run records wall clock and token counts. Full detail and rationale live in ADR 0002.

### Output contract (settled for v1)

A phone-readable PDF: an ordered route line with guide depth, steps with number, tick square, trophy name, tier dot, and one-line requirement; dependency tags instead of a graph; phase prose blocks with source tags; a stats bar with a "route skips" line; a "locked, gone for good" section for dead missables; and a shelf-life note for season-sensitive trophies. The position answer turns the same output shape into a remaining-route PDF from where the player is.

What each mode changes about the route is settled. safe orders two passes with the lost-able work first by its last safe moment and cuts nothing. fastest runs one pass, puts missables at their latest safe point, keeps required grind with the cheapest method and both hour figures, and cuts optional content into a dropped list, shortcuts flagged. completionist takes the safe spine and appends DLC lists marked not platinum-required. Each printed mode still carries a one-line definition and its delta has to fit the "route skips" sentence in the stats bar. With several modes on one PDF, the first named is the spine and the rest are per-step deltas; safe and fastest collapse to one printed route when the game has no missables; completionist takes the spine of the first mode named.

The route also handles two arrival states #3 settled: a missable already lost gets a "blocked until then" block with the reason and the wait, without reordering the rest, and a broken story order gets flagged with a regenerate instruction rather than an in-place re-plan.

### Delivery contract (settled for v1)

The harness conversation produces the PDF file. Kriday transfers it to his phone and annotates it in his PDF reader. The PDF reads offline; only generation needs web access. Annotations are manual and never sync back. Revisiting the route means running generation again with a new position, which regenerates the document from that point rather than patching it.

### Acceptance procedure: the Mortal Kombat run

The acceptance case is Kriday's own Mortal Kombat platinum run, now concretely Mortal Kombat 1 (2023) with 51 base trophies: 1 platinum, 1 gold, 15 silver, 34 bronze. The platform (which PlayStation console) is still to be confirmed with Kriday.

A v1 acceptance run must do all of this, with actual reported results, not claims:

1. Ask the position question, including whether the linear story order was broken, and accept "nothing, starting fresh".
2. Fetch the real PowerPyx MK1 guide, cross-check the 51-trophy list against it, and cite sources. Facts the sources cannot confirm get marked "unverified".
3. Put the two season-sensitive trophies, Vanquished and The Mighty Have Fallen, where the route handles them and flag that their availability can only be verified on the console. State the season shelf life in the document so the route says when it needs regenerating.
4. Emit all three modes in one pass and check each against its acceptance bar:
   - safe: pass 1 holds Vanquished and The Mighty Have Fallen with their deadlines and the cost of missing them, pass 2 covers the remaining 49 trophies, and no step relies on an unsourced claim.
   - fastest: all 51 covered, optional work named as dropped, the mastery grind kept with both the 10-hour and 50-hour figures, and cutscene skipping flagged.
   - completionist: 51 on the safe spine, DLC lists appended or an explicit "none exist", and the optional fast application stated when used.
   - every mode: starts from the confirmed position and prints the generation date and season state.
5. Render a real multi-page PDF outside the sandbox. A one page PDF fails acceptance.
6. Finish the full route inside 15 minutes and any "from here" fragment inside 3.
7. Record wall clock and token counts and report real spend against the $1 per route / $5 per game caps.
8. Report gaps from the run honestly. A silent fallback is a failure.

## Folding in decisions

#2, #3, #4, and #5 are folded in above, with links to their decision comments and ADRs. The #3 ADR arrived on `ticket/3-route-modes` named 0002 and was renumbered to 0003 here because this branch already had ADR 0002 from #4.

All four decisions fit each other and the settled #1 constraints, so nothing went back to an owning ticket. The spec is buildable without further product decisions and issue #1 closes with this update. PR #8 carries it.
