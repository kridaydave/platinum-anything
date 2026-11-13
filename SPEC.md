# plat-anything v1 spec

Status: skeleton, not ready for implementation. [Issue #1](https://github.com/kridaydave/platinum-anything/issues/1) stays open until #2 through #5 settle and their decisions fit together here. Open slots below are questions, not defaults or approved requirements.

## Destination and settled constraints

From issue #1:

- Give the tool a PlayStation game and get the best route to its platinum trophy. What "best" means depends on the selected mode.
- The product name is plat-anything. The GitHub slug stays platinum-anything.
- PlayStation only. The audience is gamers, with Kriday first.
- The output is an LLM-generated map of the trophies. Its exact shape belongs to #2.
- AI does web search and text generation only.
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

## Decision tree

The settled destination branches into four open decisions. The tickets can proceed in parallel. Their results meet at the v1 input, generation, and output contract in #1.

```text
Settled: PlayStation game -> LLM-generated trophy map -> platinum route
|
+-- #2 Map shape and mid-playthrough behavior [OPEN]
|   +-- output structure and player interaction
|   +-- progress state, if any
|   +-- mid-run help scope in #1
|
+-- #3 Route modes and meaning of "best" [OPEN]
|   +-- route ordering and trade-offs per mode
|   +-- required player inputs and mode-specific acceptance checks
|
+-- #4 Generation power [OPEN]
|   +-- runtime, keys, search/data access, and execution flow
|   +-- latency and per-route LLM cost acceptance in #1
|
+-- #5 V1 form [OPEN]
    +-- launch/install flow and user-facing controls
    +-- packaging, storage location, and runtime integration

#2 + #3 -> generated route contract
#2 + #4 -> progress-aware generation, only if #2 selects it
#2 + #3 + #4 + #5 -> end-to-end v1 contract and Mortal Kombat acceptance
```

The arrows show what downstream work waits on a decision. They do not require one ticket to wait for another before discussing its own choice.

## Open slots and ownership

| Slot | Owning ticket | Decision still needed | Downstream decisions waiting on it |
| --- | --- | --- | --- |
| Map shape | [#2](https://github.com/kridaydave/platinum-anything/issues/2) | Ordered route to tick off, visual dependency map, static guide, or another explicitly chosen shape. | Output structure, rendering or export needs, route-reading interaction, and output acceptance checks. |
| Mid-playthrough behavior | #2 | One-shot document or remembered progress. Whether the player can ask what to do next mid-run. | Need for saved state, progress input or import, resuming or regenerating a route, and the mid-run-help scope in #1. Coordinate implementation with #4 and #5 only if selected. |
| Route modes | [#3](https://github.com/kridaydave/platinum-anything/issues/3) | Which modes ship, what "best" means in each, and what changes in the route. Safe, fastest, and completionist are candidates only. | Mode selection, ordering rules, handling of grinding and missables, required player constraints, and checks that distinguish the modes. |
| Generation power | [#4](https://github.com/kridaydave/platinum-anything/issues/4) | LLM API with web search, coding-agent harness, hybrid, or another explicit choice. Who holds the keys and how generation runs. | Runtime integration, credential setup, source-access method, latency expectations, and per-route cost measurement. Web search and text generation remain the AI capability limit. |
| Route spend | #4, folded into #1 | Actual LLM spend for a generated route and whether it is acceptable. No budget or cost claim exists yet. | Generation defaults and cost acceptance for the first real run. Measure against the selected runtime and route contract. |
| V1 form | [#5](https://github.com/kridaydave/platinum-anything/issues/5) | Local web app, CLI, deployed site, or another explicit choice, with rationale and v1 scope. | Entry point, install/run instructions, controls, storage location if needed, and packaging for #4's runtime. Any choice must respect #1's no-accounts and no-multi-user-hosting limits. |

## End-to-end contract to fill after the decisions

These slots belong to #1's integration work. They must follow the owning tickets rather than introduce competing product choices.

- Input contract, pending #2, #3, and #5. Specify how the player identifies the game and supplies any selected mode, constraints, or progress. PSN import is not assumed.
- Generation contract, pending #4 and the #2/#3 route contract. Record the chosen execution flow, source handling within the #6 limits, key ownership, and measured cost and latency.
- Output contract, pending #2 and #3. Specify the map contents, route ordering, mode-dependent behavior, and any chosen progress interaction.
- Delivery contract, pending #5 and its integration with #2/#4. Specify how Kriday starts the tool and receives or revisits the result.
- Acceptance procedure, integrated in #1 after #2 through #5. Identify the exact Mortal Kombat title and platform with Kriday, then define the input-to-route checks against the chosen contracts. The later implementation must report actual results and gaps from that run. This skeleton does not claim that run has happened.

## Folding in decisions

When a ticket reports a decision, read its rationale and link the decision comment here. Replace its open slots with the approved result and update the downstream contracts. A progress comment or a list of options is not a decision.

If decisions conflict with each other or a settled #1 constraint, return the conflict to the owning ticket instead of silently choosing a resolution. Preserve the remaining open slots. Keep #1 open until #2 through #5 settle and the integrated spec is clear enough to build without further product decisions.
