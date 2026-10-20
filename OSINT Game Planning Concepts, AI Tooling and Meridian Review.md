# OSINT Game Planning: Concepts, AI Tooling and Meridian Review

Oct 20, 2026 · @Chris Schmidt

## Overview

The plan: build a small, polished OSINT-themed game first, co-built with AI tools, then grow it into a slate of three or four defense-aligned games set in one fictional world. OSINT suits a first-time developer because the game is mostly screens, documents, maps and reasoning, not 3D art.

This document collects the full planning conversation: foundations, game concepts, AI tooling and model choices, decisions to make before writing a spec, a review of the Meridian harness for this build, and the defense-aligned game slate.

## Foundations

Scope is the biggest risk: a 2–4 hour game with five or six handcrafted cases beats a sprawling open world. Many of the best games in this genre came from one to three people.

### Games to study

| Game | Why it matters |
| --- | --- |
| Her Story, Telling Lies | The whole game is typing searches into a database of video clips |
| Return of the Obra Dinn, The Case of the Golden Idol | The best solutions to checking a player's reasoning |
| Orwell: Keeping an Eye on You | A surveillance and OSINT game, including its ethics |
| Hypnospace Outlaw | A fake internet as a world to explore |
| The Operator | An FBI desk-analyst game; the closest to this idea |
| The Roottrees are Dead | Deduction played through a period-appropriate fake internet |
| GeoGuessr | Proof that geolocation alone compels millions of players |

### The central design problem: checking reasoning

Multiple-choice answers get brute-forced; exact typed answers stall players on wording. Two proven fixes:

- Obra Dinn confirms answers only in batches of three, so guessing doesn't pay.
- Golden Idol uses fill-in-the-blank sentences built from words collected as evidence.

An OSINT version could be a filed assessment (location, time, actor, confidence) graded as a whole.

### What makes OSINT fun

The payoff is cross-referencing: the moment a shadow angle, a shop sign and a flight log agree. The fictional world must therefore be dense and internally consistent, which is mostly a writing and data job.

### Tools

- **Godot**: free, light, excellent for 2D and UI; the default beginner pick.
- **Web stack** (TypeScript, packaged for Steam with Tauri or Electron): viable because the game is mostly fake apps and dashboards.
- **Unity or Unreal**: only for a 3D world, which multiplies scope.

### Using AI carefully

Live LLM characters make puzzles unreliable. The stronger use is in production: drafting forum posts, ship registries and social feeds, then curating them. A narrow live-AI feature, such as an adversary analyst who adapts, can differentiate without being the foundation.

### Keep the world fictional

Use real techniques with fictional people and places. This avoids doxxing-adjacent content and licensing problems: Google Earth imagery can't be used commercially, but Sentinel and Landsat imagery or stylized maps can.

## Initial game concepts

Six OSINT concepts, from puzzle deduction (1, 3, 6) to systems and resources (2, 5) to a flipped perspective (4).

| # | Concept | Premise | Core mechanic |
| --- | --- | --- | --- |
| 1 | Verification Desk | Open-source investigations outfit during a crisis | Geolocate and chronolocate viral media before deadline; wrong calls spread misinformation into later cases |
| 2 | Dark Fleet | Shadow tankers move sanctioned oil through a chokepoint | AIS gaps and spoofing, a limited satellite-tasking budget, port and shell-company records |
| 3 | Squawk 7500 | An aircraft vanishes from flight tracking | Rebuild its last hours from ADS-B fragments, spotter photos, webcams and passenger posts |
| 4 | The Inverse Game | You are the target, getting someone out of a country | Evade an AI analyst using OSINT against you; every trace counts |
| 5 | Analytic Cell | Run a small intelligence team | Weigh competing hypotheses, brief a decision-maker; calibration matters more than being right |
| 6 | Dead Drop Internet | A journalist disappears in a fake web from a specific year | Period search engine, archived pages, leaked dumps; the smallest scope of the six |

### A realistic path

1. Build two or three throwaway game-jam games (a week each) to learn the engine.
2. Build one 20–30 minute case of the chosen concept with placeholder art.
3. Watch five people play it without helping; their confusion is the roadmap.
4. Then commit to art direction, a full case set and a Steam page; early wishlists matter for indie launches.

## Building with AI tools

Use three model tiers, judged by cost per completed task rather than per token: a cheap model that loops costs more than a pricier one that finishes. On Artificial Analysis's FrontierCode benchmark, the last step up the Pareto frontier (GPT-6.1 Sol to Claude Opus 5.5) adds 3 points for more than 12x the cost per task.

### Frontier models (as of October 2026)

| Model | FrontierCode score | Cost per task | OpenRouter price, in / out per 1M tokens | Role |
| --- | --- | --- | --- | --- |
| GPT-6 Luna (max) | 42% | $0.09 | $0.10 / $0.50 | Workhorse |
| MiMo-V2.6-Pro | 45% | $0.18 | not checked | Workhorse |
| GPT-6.1 Sol (max) | 49% | $0.81 | $2 / $10 | Default for real features |
| Claude Opus 5.5 (max) | 52% | $10.15 | $4 / $20 | Escalation only |

Other cheap options: GLM 5.3 Flash ($0.15 / $0.50) and DeepSeek V4.1 Flash ($0.15 / $0.60 off-peak, $0.30 / $1.20 at weekday peak). Grok 4.7 ($2 / $6 under 200K prompt tokens) is worth testing for hard multi-file work.

- **Workhorse** (most tokens): boilerplate, UI components, data plumbing, tests, refactors.
- **Default**: real features.
- **Escalation**: architecture reviews, nasty bugs, anything cheaper tiers fail twice.

Once the skeleton exists, run a ten-task eval on your own repo; it beats any public leaderboard.

### Prime Agent notes

- Recursive sub-agents multiply token spend; set its goal token budgets.
- No model has yet been trained around Prime Agent, so cheaper models underuse the recursion.
- Its self-modifying harness can learn bad habits; one reported run refined itself toward cheating. Keep tests and acceptance checks outside its write access.
- Use it for long, well-specified batches (implement a system against a spec and pass its tests); use Copilot for interactive editor work.
- When routing to DeepSeek or MiMo, check OpenRouter's provider and data-retention settings.

## Decisions before the spec

The data-driven case architecture (item 3) is the single most important technical decision.

1. **Concept and length.** Pick one concept and a target playtime of 2–4 hours.
2. **Engine and language, chosen partly for AI-friendliness.** AI models are much stronger in TypeScript and React than in GDScript. A web stack packaged with Tauri lets AI tools do the most; Godot suits real game-engine features like animation, shaders and controller support.
3. **Data-driven case architecture.** Cases, documents, evidence, fake web pages and solutions live as schema-validated JSON or YAML, separate from engine code. Agents then build against a stable contract, content is authored without touching code, and cases can be validated automatically.
4. **Answer checking.** Batched confirmations, fill-in-the-blank, or graded assessments with confidence levels; this shapes the data schema.
5. **Art and audio direction.** A style one person can sustain: a stylized desktop OS, diegetic documents, minimalist maps.
6. **Goal.** Portfolio piece or commercial release; this sets the polish, marketing and legal care needed.

## Blind spots

The game is limited by content, not code: perhaps 70–80% of the effort is designing cases, writing documents, and keeping clues consistent and fair. AI coding tools speed up the smaller part.

- **Automated solvability checking is the edge.** A validator walks each case's clue graph and proves the solution is reachable and unique, with no dead ends or contradictions. It also makes LLM-drafted content safe to use.
- **Fun can't be specified.** Find it by watching people play a vertical slice early, then iterate; don't fully spec up front.
- **Steam's AI disclosure.** Steam requires disclosing AI-generated player-facing content. AI-written code doesn't count; AI art and writing do, and some players react badly to AI art.
- **Employer IP agreement.** Before going commercial, check the HII agreement for outside-activity and invention-assignment clauses. Keep content fictional and away from anything work-adjacent; a quick check with the security office is cheap insurance.
- **Time against school.** With JHU running through 2029, a small first release such as a free demo or prologue keeps momentum.
- **Game feel.** Sound, transitions and the moment a clue snaps into place make a desk game feel high quality; schedule real time for them.

## Meridian review

Meridian is useful here as governance, not as a creative-phase tool, but two gaps must be fixed before pairing it with Copilot or Prime Agent, or its independent evaluation becomes an honor system.

### Where it fits

- **Scope drift** kills solo games; CONTRACT.md's out-of-scope list plus the drift sensor targets it directly.
- **Happy path vs. full lifecycle** maps to game content: a case that works when played as intended vs. one that is fair, has no dead ends, and survives out-of-order play. AeroIntel showed the same gap (100% happy path, 0% full lifecycle).
- **Reflexion calibration** helps estimate feature time around JHU coursework.
- **The git/CI boundary** works with any tool.

### Gaps for this tooling

| # | Gap | Evidence in the repo | Effect |
| --- | --- | --- | --- |
| 1 | Copilot and Prime Agent are Tier 2/3; nothing launches the evaluator | `run-evaluator.sh` relies on Claude Code's Task tool; `meridian-verify.sh` (lines 140–141) treats a missing verdict as not a failure | Independent evaluation runs only when remembered |
| 2 | Verdicts can be forged and never go stale | PreToolUse guards `gate-state.json` and memory, not `.meridian/evaluator/`; verdicts carry no artifact hash | An agent can write its own passing verdict; old passes survive rewrites |
| 3 | Fun isn't LLM-scorable | Evaluator scores 0–10 on spec dimensions | A fun score would be theater |
| 4 | No game recipe | `fullstack-web` wants API\_SPEC.md and DATABASE\_SCHEMA.md; a recent commit notes 20 declared recipe hooks didn't exist | A new recipe needs real hooks from day one |
| 5 | Competing memory | Prime Agent's Continual Harness keeps its own prompts, skills and memory | Two sources of truth |

Gates need three kinds of evidence: mechanical checks (tests, builds, the case validator), human evidence (playtest notes behind an approval token), and LLM evaluation only for spec adherence and consistency. Split roles: Meridian for gates, verdicts and CI; Prime Agent for execution, with Meridian files outside its write scope.

### The opportunity: evaluate content, not just code

The riskiest failures are unsolvable cases, cases with two solutions, and contradictory clues. Apply Generator/Evaluator separation there:

- **Deterministic gate:** the case validator proves each solution is reachable and unique; unfakeable, like `tests_passing`.
- **Cross-model evaluator:** a script calls OpenRouter with a different model family from the author (GPT-6.1 Sol drafts, a non-OpenAI model judges). This also fixes gap 1, since a script-launched evaluator works from any tool.

A content-heavy game recipe would be a third, structurally different dogfood project, strengthening the claim that gate patterns transfer.

&#91;embedded content: proposed game recipe gate DAG · 6 gates\]

The case gate is the content analog of `tests_passing`: no case reaches playtesters until a solver and a different-family model both clear it.

### Fixes before starting, in priority order

1. Block agent writes to `.meridian/evaluator/`; better, make verdicts writable only by an `--invoke` script that calls the evaluator model itself.
2. Record an artifact hash and evaluator model ID in each verdict; reject verdicts whose hash no longer matches.
3. Fail commits when a passed gate requires a verdict and none exists.
4. Add the OpenRouter `--invoke` path with a configurable evaluator model.
5. Check whether Copilot's agent mode exposes a pre-action hook; Meridian's docs don't cover Copilot.

Leave Meridian out of the first game-jam prototypes; gates during exploration fight finding the fun. Bring it in at the vertical slice.

## Defense-aligned game slate

Build four games in one shared fictional archipelago, drawing on the experience of fusing streaming data into a read on a region's geopolitical mood. That procedural authenticity is more distinctive than photoreal graphics.

### On realistic first-person 3D

It's the most expensive genre, and AI coding tools help least with environments, animation and lighting. Two things make it workable solo:

- **Confine the space.** One ship, island or facility rendered convincingly is achievable; a city is not. Solo-made *Iron Lung*, set inside a tiny submarine, worked because of that constraint.
- **Mind the engine.** Unreal's Blueprints are visual scripting that Copilot can't really write; Unity (C#) or Unreal in C++ suits AI-carried coding better.

### Fictionalize the region

Use a fictional analog of Oceania, as *Papers, Please* invented Arstotzka. Real geopolitics dates faster than a game ships; fiction keeps clear of anything tied to work, sidesteps partisan reactions, and lets the situation be designed to be interesting. Public themes to borrow: competition for port and security agreements, undersea cable vulnerability, illegal fishing, climate-driven sovereignty questions, deep-sea mining, and gray-zone pressure below the threshold of war.

### The four games

| # | Game | Form | Premise | Why it fits |
| --- | --- | --- | --- | --- |
| 1 | Zeitgeist | 2D systems sim | Run a fusion cell; file daily indicators-and-warnings briefs on signals from an agent-based nation sim; decision-makers act on your judgment | Closest to the job; low art cost; its simulation powers the other three |
| 2 | Cable Ship | First-person 3D, confined | Investigate a severed undersea cable: storm-dragged anchor or sabotage? ROV dives, vessel tracks, a crew with divided loyalties | Atmospheric 3D within one ship and the ocean |
| 3 | Atoll | First-person 3D, field investigation | A journalist on a small island during a contested port deal; photograph, geolocate, verify while outside actors shape the story | Makes the region human; reuses shared-world assets |
| 4 | Horizon 2040 | Strategy roguelike | Each run generates a regional future from structured drivers (sea level, great-power posture, technology spread, regional cohesion); keep a small state sovereign | Futures methods like the NIC's *Global Trends*; LLM flavor text checked by a Meridian-style evaluator |

### Build order

1. **Zeitgeist** first: achievable, close to existing expertise, and it builds the shared simulation.
2. **Cable Ship** second, as the first 3D game in a confined space.
3. **Horizon 2040** or **Atoll** next, depending on whether to go deeper on systems or on 3D.

To use current events as an idea generator, build a driver matrix: list the forces shaping the region, pick two critical uncertainties as axes, and each quadrant yields a future and a game premise.

## Next steps

The first concrete artifact is the shared world bible, since every game in the slate depends on it; the case data schema and validator follow.

- [ ] Pick the first game (recommended: Zeitgeist) and its target playtime
- [ ] Draft the driver matrix and world bible for the fictional archipelago
- [ ] Choose engine and language with AI-friendliness in mind
- [ ] Design the case data schema and the solvability validator
- [ ] Apply the five Meridian fixes and draft a game recipe `gates.yaml`
- [ ] Build two or three game-jam prototypes, then a 20–30 minute vertical slice
- [ ] Check the HII outside-activity and IP agreement before any commercial plans

## Sources

- [FrontierCode on Artificial Analysis](https://artificialanalysis.ai/articles/frontiercode)
- [OpenRouter Top Models (Oct 2026)](https://www.teamday.ai/blog/top-ai-models-openrouter-2026)
- [Benchmarking Coding Agents on Databricks' Codebase](https://www.databricks.com/blog/benchmarking-coding-agents-databricks-multi-million-line-codebase)
- [Prime Agent: Self-Improving Agentic Harness (ZenML)](https://www.zenml.io/llmops-database/self-improving-agentic-harness-with-recursive-language-models-and-continual-learning)
- [Prime Agent coverage (QQ News)](https://news.qq.com/rain/a/20260807A0FIIF00)
- [Prime Agent RLM Harness Guide](https://agentpedia.codes/blog/prime-agent-rlm-harness-arc-agi-3-guide)
- [Meridian repository](https://github.com/PCSchmidt/meridian)
