# ADR 0003: route modes and what "best" means

Status: decided for v1. Closes [#3](https://github.com/kridaydave/platinum-anything/issues/3).

## Decision

V1 ships three route modes: **safe**, **fastest**, **completionist**. Mode is a required input. Nothing is defaulted, because a route that silently skips content is worse than a slow one, and Kriday reads the result on a phone where a missing warning is easy to miss.

One PDF can carry several modes. The first mode Kriday names is the spine and the others appear as per-step deltas. A single generated route is the spine plus overlays, not three stacked routes.

Zero missables is a hard rule in every mode, not a safe-only feature. Any mode may schedule missable work later. None may drop it.

## What best means per mode

**safe** runs two passes. Pass 1 is everything that can be lost, ordered by its last safe moment. Pass 2 is everything else. It cuts nothing, takes no shortcut that skips content for time, and every risky claim in it names a source or gets marked uncertain.

**fastest** runs one pass. Required work stays. Missables are interleaved and scheduled at the latest safe point instead of the earliest. It keeps required grind with the cheapest known method and prints both the active hours and the hands-off hours. Everything optional is cut and named in a dropped list.

**completionist** uses the safe spine for the main list and appends DLC trophy lists. It can optionally apply fast to the main list plus DLC. DLC is never treated as required for the platinum.

Kriday's currency for fastest is his own attention, not the clock. A long hands-off method beats a shorter thumbs-on one. On Mortal Kombat 1 the mastery grind is 10 hours playing or about 50 hours with the AFK turbo method, and fastest recommends the second while printing both numbers.

## What changes in the route

| | safe | fastest | completionist |
| --- | --- | --- | --- |
| Passes | two, lost-able work first | one | two, safe spine |
| Missable timing | earliest safe point | latest safe point | earliest safe point |
| Required grind | kept | kept, cheapest method, both hour figures | kept |
| Optional content | kept | cut and listed as dropped | kept |
| Content shortcuts | none | allowed, flagged | none |
| DLC lists | no | no | yes, marked not platinum-required |
| Claim sourcing | every risky claim sourced or flagged | best effort | every risky claim sourced or flagged |

Modes do not change research depth. The research happens once and the modes only change the route built on it. A second mode inside the same run is a delta pass over the same research, measured at about 3 extra minutes and 8k output tokens on top of a 3.2M input route (ticket #4).

## Multi-mode PDF behavior

- First mode named is the spine. Later modes print as one-line deltas at the step they affect.
- Each printed mode carries a one-line definition and the "Route skips:" line that ticket #2 built into the stats bar.
- When a game has no missables, safe and fastest are the same route. The PDF prints it once and says in one line that safe was requested, no missables were found, and the two collapse.
- Completionist alone uses the safe spine. When it rides along with another mode it takes that mode's spine so the document never contradicts itself.

## Position and season state

The position ask is mandatory on every run. The model researches the game's story and mode structure first, then asks where the player is, including whether the player broke the linear order. Two steps that can be done in either order get a "needs:" line and, where order matters, an "if you did Y first" note. Prerequisites adapt to what the player reports. The route never guesses a position and never silently assumes a fresh save.

Season state is researched live at generation time instead of hardcoded. Kriday's instruction was to research Invasions and similar time-bound content as the model sees fit, so the spec states the requirement and leaves the method to generation. The PDF header prints the generation date, the season number and the days left. Every season-bound step carries its expiry.

A route tied to a live season has a shelf life. On Mortal Kombat 1 two trophies are season-bound (`Vanquished`, `The Mighty Have Fallen`), so an old PDF must show its age rather than look current.

## When a missable is already gone

The player can arrive with a trophy already lost, for example a Titan that never spawned or a story missable already passed. The route marks it lost with the reason, states the wait (next season or next playthrough), and puts it in a separate "blocked until then" block that does not reorder the rest. It never claims the run is still clean.

## Acceptance checks

Measured on Mortal Kombat 1, 51 base trophies and 2 season-bound missables.

- safe: pass 1 holds both season-bound trophies with their deadlines and the cost of missing them, pass 2 covers the remaining 49 with none missing, and no step relies on an unsourced claim.
- fastest: all 51 covered, optional work named as dropped, mastery grind kept with both hour figures, cutscene skipping flagged.
- completionist: 51 covered on the safe spine, DLC lists appended or an explicit "none exist", optional fast application stated when used.
- every mode: starts from the confirmed position, prints the generation date and season state, marks expired or unobtainable trophies instead of listing them as doable.

## Rejected options

- Three independent full routes in one PDF. The spine plus deltas is cheaper and readable on a phone.
- Dropping completionist. Kriday wants all three.
- A default mode when none is stated. Mode is required.
- One mode per PDF. Overruled by Kriday after the first recommendation.
- Auto re-planning when the player plays out of order. V1 flags the break and tells the player to regenerate. Reordering in place is a different feature.
- Modes changing research depth or source access. The research happens once.
- Treating DLC as required for the platinum. DLC ships as an extra list, never a gate.
- Defining modes by trophy coverage. The platinum needs every base trophy, so coverage alone made safe and completionist identical. The modes are defined by pass structure and cutting policy instead.

## How this closed

Rounds 1 to 4 were answered by Kriday. Round 5 confirmed acceptance checks, already-lost missables, mode labels, and the rejected list as recommended, and Kriday closed the session without answering it line by line. Every round 5 item restated something already settled, so this document adopts them on the recommended terms and says so here rather than presenting them as separately confirmed.
