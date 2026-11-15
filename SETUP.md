# Use the route prompt and template

The product is a reusable prompt and an HTML template for a phone-readable PDF. Use them with any agent that can research the web, read the template, and produce files. No launcher or particular agent is required. Provider access, credentials, cost, capabilities and permission settings depend on your chosen agent.

1. Give the agent [prompts/route.md](prompts/route.md) and [templates/route.html](templates/route.html), by attaching them, sharing their contents, or pointing to their paths if it can read the repository.
2. Supply the PlayStation game, your current position (including any out-of-order progress), and one or more modes: safe, fastest, completionist. For example: `Mortal Kombat 1 (2023); nothing, starting fresh; safe, fastest, completionist`.
3. Ask the agent to research and verify the route, replace the template placeholders, and deliver the completed HTML and PDF. If it cannot fetch a source or create the PDF, it should say so and identify any unverified facts rather than inventing results.
4. Review the sources and the generated PDF, transfer it to your phone, and annotate it in your PDF reader. Annotations stay in that reader; they do not sync back into the prompt or agent.

## Rendering and checking

The self-contained template uses A5 print CSS, dark on-screen styling and a light print palette. An agent with a PDF renderer can print the completed HTML using its available tools; alternatively open it in a browser and use Print → Save as PDF, enabling background graphics only if needed. Preserve A5 and avoid browser headers and footers where possible. No specific browser, operating system, agent or renderer is required.

Open the resulting PDF and inspect every page: confirm that text is legible on a phone, content and sources are present, no steps are clipped or missing, and page breaks make sense. Compare it against the HTML. A page count alone cannot establish correctness; a short route may legitimately fit on one page, but an unexpectedly short PDF requires investigation. Check that placeholders are gone, claims are sourced or marked unverified, mode differences and current position are represented, and seasonal deadlines are verified or marked unknown. The static template is a starting point, not a real route or proof that a generation run works.

## Product clarification and related decisions

The reusable prompt and template replace the earlier assumption that v1 requires a specific coding-agent harness, account, model, sandbox flags or launcher. An agent may use its own tools or credentials, and some may need an API key. This clarification supersedes provider-specific product requirements in the earlier #4 decision and the proposed spec in PR #8; their measurements remain historical observations, not guarantees. Route structure and mode decisions in PRs #9 and #11 overlap with the prompt and template and should be reconciled as those PRs land.
