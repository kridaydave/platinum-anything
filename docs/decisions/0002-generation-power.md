# ADR 0002: what powers the generation

Status: accepted for v1
Date: 2026-11-14
Ticket: [#4](https://github.com/kridaydave/platinum-anything/issues/4)
Branch: `ticket/4-generation-power`
Measurements: [NOTES.md](https://github.com/kridaydave/platinum-anything/blob/ticket/4-generation-power/NOTES.md) (lives on `ticket/4-generation-power`, not on the branch carrying this ADR)

## Decision

v1 generates routes with a coding agent harness on Kriday's own machine. The harness does the web search, fetches the source pages, checks its own work, writes the route and renders the PDF. It runs on the credentials Kriday already pays monthly for.

No metered LLM API key is part of v1. The prompt and the render command are kept as files in the repo so a later public version can swap the harness for a paid API without rewriting the product.

Concretely, a v1 run is:

```sh
codex exec --json --skip-git-repo-check -C <workdir> \
  -s workspace-write -c approval_policy="never" -c tools.web_search=true \
  "$(cat prompts/route.md)"
```

followed by the PDF render run outside the Codex sandbox, because chromium cannot start inside it.

## Why

The measurements are in NOTES.md. The short version:

| | Harness route | One API call with built-in search |
| --- | --- | --- |
| Wall clock per route | 5.7 min for three modes, 9.6 min for one | 1 to 3 min, estimated |
| Metered cost | $0.04 to $0.06 on luna, $0.81 on Sol | about $0.35 to $0.50, estimated |
| Out of pocket for Kriday | $0 | needs a new card, account and key |
| What it reads | the real guide pages, 22k tokens each | search snippets |
| Can it re-read a page it misread | yes | no |

Three things decided it.

The credentials are already here. The machine holds a ChatGPT Plus OAuth login for Codex, a DeepAI account, a Kilo OAuth login and a GitHub token. It holds no Anthropic key, no OpenAI key, no Gemini key and no third party search key. The API route means signing up and paying before anything runs.

The harness reads the same material the API path would. The MK1 PowerPyx guide is 16.2k words, roughly 22k tokens, and it fetches over plain curl. A single call with built-in search works from snippets and cannot re-read a page.

ADR 0001 already committed v1 to a harness-generated PDF using the harness's own credentials, and said to revisit that if the form turns out to need a standalone API. It does not.

## What the decision fixes

- Backend is the Codex CLI with `tools.web_search=true`, on the Codex default model `gpt-6-luna`. Sol is roughly fifteen times the tokens and did not get measured on a full route, so it stays the fallback for routes that come back weak.
- The sandbox flags are not optional. `codex exec` is read-only outside a trusted directory and rejects writes. A run needs `-s workspace-write` and `-c approval_policy="never"`.
- The PDF render runs outside the Codex sandbox, using the Playwright chromium already on the machine. Inside the sandbox chromium will not start, and the agent burns turns on fallbacks that produce a one page PDF instead of a fourteen page one.
- One generation run emits every mode the player names. Adding modes later in a warm second turn cost nearly twice as much, because the whole context is sent again.
- Position is asked on every run. A new position regenerates the document from that point, it does not patch it.
- The verification loop is mandatory. The run fetches the real guide pages, cross-checks the trophy list, cites sources, and writes "unverified" rather than inventing a fact.
- Cost policy: the measured cost is $0.04 to $0.06 per route. If a metered backend is ever used, the ceiling is $1 per route and $5 per game. Every run records wall clock and token counts so issue #1 can state real spend instead of a guess.
- Latency: the measured runs took 5.7 to 9.6 minutes. The spec assumes a full route is ready inside 15 minutes and a fragment inside 3.

## Rejected options

**One LLM API call with built-in web search.** Rejected for v1. It costs roughly ten times what the harness route costs, it needs a billed account and a key that do not exist on this machine, and it works from search snippets rather than the guide pages. Its real advantage is that it is the shape that will serve other people later, so we keep it as a documented escape hatch rather than as the v1 backend.

**Hybrid, harness researches and one API call writes the route.** Rejected for v1. It buys a stronger final draft for roughly $0.25 and pays for it with a card, a key and a second way to fail. The measured harness runs produced a publishable draft on the cheap model, with the two season-sensitive trophies pulled to the front and the unverified event dates flagged on its own. Worth revisiting if harness drafts turn out to be weak on real games.

**Shipping the harness to gamers.** Out of scope. Issue #1 rules out accounts and multi-user hosting in v1, and there is no way to hand a person's local agent to a stranger.

## Consequences

- v1 needs no new account, no card and no key.
- A public launch still needs a paid backend and its own key handling. That work is not done here.
- Routes have a shelf life. Mortal Kombat 1 (2023) has two season-sensitive trophies, Vanquished and The Mighty Have Fallen, so a route for that game has to be regenerated when the Invasions season turns over.
- The prompt and the render command are the product now, so they live in files, not in chat history.

## What would reverse this

- Harness drafts fail to hold up on the first few real games.
- Kriday wants a metered key and per-route billing from day one.
- A public launch arrives sooner than expected.

## Still open, and what the answers would change

Four questions went to Kriday and have not been answered yet. The defaults above are the measured values, and only two of the four would change something if he answers differently:

- Model tier. Measurements used `gpt-6-luna`. Sol was not measured on a full route. Another answer moves this line.
- Cost and latency caps. The defaults are $1 per route, $5 per game, 15 minutes per route, 3 minutes per fragment.
- Backend posture. A preference for a metered key from day one would reopen the hybrid option.
- Verification depth. The default is the full loop, fetch, cross-check, cite, and mark what is unknown.
