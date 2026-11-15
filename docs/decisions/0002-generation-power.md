# ADR 0002: what powers generation

Status: clarified for v1 following the agent-independent product decision
Ticket: [#4](https://github.com/kridaydave/platinum-anything/issues/4)
Measurements: [NOTES.md](../../NOTES.md)

## Decision

The product is a reusable prompt and PDF template usable with any capable agent. It does not select, bundle or launch an agent, model, API, browser or renderer. A chosen agent must be able to research accessible sources and generate route text; a suitable tool must render the template to PDF. If the agent cannot complete a step, disclose the limitation and provide the available intermediate output. AI is limited to web search and text generation; rendering is ordinary software.

The player supplies the game, current position and requested modes. Research the current game and source pages, cross-check trophy information, cite sources and mark unconfirmed facts as unverified rather than inventing them. Emit requested modes together using the settled route structure. The completed PDF must be checked against the output for legibility, completeness and sensible page breaks. Page count alone is not a validity test.

Accounts, keys, costs, quotas, permissions and latency depend on the selected agent and renderer. The product does not require its own application account or key, though an agent may require one. A player can use an agent already available to them or an API-backed agent. No model, cost cap, timing guarantee, sandbox setting or browser path is imposed by this decision.

## Evidence and scope

[NOTES.md](../../NOTES.md) records historical measurements from a specific local Codex configuration and Mortal Kombat 1 research. They show that one setup could generate a route, and that one rendering fallback produced a truncated PDF; they do not establish performance, source access, billing, necessary flags or page counts for all agents. Cost comparisons with unrun API options were estimates, not measurements. Current source access and seasonal facts must be checked for each run.

The previous choice of a Codex CLI backend, specific model and sandbox flags, subscription login, outside-sandbox renderer, and no API key is superseded by the agent-independent product direction. A hosted public service would need separate decisions about hosting, credentials, costs and progress storage; none is selected here.
