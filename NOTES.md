# Ticket #4 notes: what powers the generation

Working notes for issue #4 on kridaydave/platinum-anything. Branch `ticket/4-generation-power`.

## Settled context this ticket builds on

- Issue #1 notes bind the ticket. PlayStation only, Kriday first, no accounts, AI does web search and text generation only, real results only.
- Ticket #5 (ADR 0001, PR #7): v1 is a harness-generated, phone-readable PDF. Personal workflow. No app-managed key.
- Ticket #2 (committed on `ticket/2-trophy-map-shape`): ordered route line with guide depth, one-shot PDF, manual ticks, position-aware generation. The model asks "how far are you?" every run and emits a remaining-route PDF from that point. A mid-run death can produce a "from here" fragment PDF from the same conversation.
- Ticket #3 (settled, still being posted by its owner): three modes ship, safe, fastest, completionist. One PDF can carry several modes, named at generation time. Mode is a required input next to the position answer. A re-run with a new position regenerates the document, it does not patch it. Shape is one spine plus per-mode deltas.

## Credentials that actually exist on this machine

Checked by looking, not by asking.

| Credential | Where | Notes |
| --- | --- | --- |
| ChatGPT Plus, OAuth | `~/.codex/auth.json` | `OPENAI_API_KEY` is null, it is a subscription login. Codex CLI 0.169.0 installed. Account webbie.byte@gmail.com. |
| DeepAI account | `T3_DEEPAI_TOKEN` and friends in the shell env | Plan `premium` per the telemetry. Drives this harness. |
| Kilo, OAuth | `~/.local/share/kilo/auth.json` | Installed and authenticated. |
| GitHub token | `~/.config/gh/hosts.yml`, keyring | Scope `repo`, `workflow`. |
| `TOKENROUTER_API_KEY` | `~/.zshrc` line 3 | The only raw API-style key on the box. Nothing in any config points at it and no script references it. Unknown gateway, unusable until someone works out what it fronts. |

Not present anywhere: Anthropic, OpenAI, Google or Gemini API keys, and every third party search key (Tavily, Exa, Serper, Brave, Perplexity, Firecrawl, Jina). So an API-backed v1 means account, card and key setup before anything runs.

## Search and fetch that work today with no new key

- The harness has a built-in `web_search` tool that rides the DeepAI account.
- Codex CLI has web search via `tools.web_search=true`, confirmed working in the runs below.
- Plain curl works. Verified today: `https://www.powerpyx.com/mortal-kombat-1-trophy-guide-roadmap/` returns 200 and is about 16.2k words, roughly 22k tokens of guide text.
- Blocked, per issue #6 research and confirmed in today's runs: PlayStationTrophies guide pages return 403, a Fandom page returned 402 through the local proxy, PSNProfiles returns 403.

## Measured cost of one generation run

Authentic runs on this machine. Codex CLI, ChatGPT Plus subscription, web search on, default model `gpt-6-luna` ($0.10 in, $0.01 cached in, $0.50 out per MTok).

| Run | Wall | Input (cached part) | Output + reasoning | Searches |
| --- | --- | --- | --- | --- |
| Research plus write a 12-step route with citations | 75 s | 439,224 (295,296) | 2,775 | 4 |
| Full route for Mortal Kombat 1 (2023), safe mode, PDF written | 574 s | 3,201,475 (3,109,248) | 31,146 | 5 |
| Three modes in one pass, safe plus fastest plus completionist | 340 s | 2,114,115 (2,019,712) | 19,719 | 8 |
| Three modes as a warm second turn on top of the single-mode run | 177 s | 4,297,473 (4,190,336) | 44,118 | 0 |

Same work priced at other model rates:

| Run | luna | gpt-6.1-sol | claude-sonnet-5.5 |
| --- | --- | --- | --- |
| Research plus 12-step route | $0.02 | $0.35 | $0.53 |
| Full single-mode route | $0.056 | $0.81 | $1.37 |
| Three modes, one cold pass | $0.040 | $0.59 | $0.98 |

Out of pocket is $0 because the runs ride the Plus subscription. The cost that matters is plan quota. Codex usage peaked at 34% of the primary window over the last 7 days, so a route is well inside the plan.

Comparison point for the API route: the published prices are Anthropic web search at $0.01 per search plus tokens, OpenAI web search at $0.01 per call plus the retrieved search text billed at model rates, and Gemini grounding free for the first 5,000 queries a month then $0.014 per query. A single call with built-in search for Mortal Kombat 1 lands around $0.50 on Sonnet 5.5, $0.35 on GPT-6.1-Sol, $0.17 on GPT-6-Luna. That is an estimate, not a measurement, because no metered key exists on this box to measure with. It also relies on search snippets, not the 22k-token guide page a fetch returns.

## The multi-mode cost question, answered for ticket #3

One generation run emits every mode the player names. Adding fastest and completionist to a route that already has safe, in a fresh pass, cost 340 s and $0.040 on luna, which is the same ballpark as the single-mode run at 574 s and $0.056. Adding the modes later, as a warm second turn inside the same session, cost an extra 177 s and $0.075 on luna because the whole cached context is sent again. One pass with all modes is the cheaper shape.

## Operational facts for whatever tool wins

- `codex exec` defaults to a read-only sandbox outside a trusted directory. Writes were rejected with "patch rejected: writing is blocked by read-only sandbox". The generating command needs `-s workspace-write` and `-c approval_policy="never"`.
- Chromium cannot start inside the Codex sandbox. The agent burned several turns on retries and fell back to a Python renderer that produced a 1-page PDF. Rendering outside the sandbox with the Playwright chromium already on disk produced the real 13 to 14 page A5 PDFs. The generating command has to run the render where chromium can start, or the route silently ships as a bad PDF.
- Playwright chromium is at `~/.cache/ms-playwright/chromium-1255/chrome-linux64/chrome`. Headless print to PDF works from a normal shell.
- The MCP server in the Codex config fails auth on every run ("invalid_token" for the Vercel MCP). It is noise, but it pollutes every run's logs.

## Product facts the runs turned up

- Mortal Kombat 1 (2023) has 51 base trophies: 1 platinum, 1 gold, 15 silver, 34 bronze.
- Exactly two are season-sensitive: Vanquished (silver) and The Mighty Have Fallen (bronze). The route puts them first and flags that current event availability cannot be verified from the guide, only from the console. A route for this game has a shelf life tied to the Invasions season, so routes need regenerating when the season turns over.
- PlayStationTrophies guide pages 403, Fandom pages intermittently 402 through the proxy, PowerPyx works. Guide prose is copyrighted, so the route summarizes and links rather than copies.

## Artifacts from the measurement runs

- `/tmp/plat-mk1/mk1-safe-route.md` and `mk1-safe-route-chrome.pdf`, 14 pages A5, single mode.
- `/tmp/plat-mk1/mk1-3modes.md` and `mk1-3modes-chrome.pdf`, 13 pages, three modes.
- `/tmp/plat-mk1-onpass/mk1-onpass.md` and `mk1-onpass-chrome.pdf`, three modes in one cold pass.

These are measurement artifacts, not the v1 implementation. They are not committed to this branch.
