# **OSINT Game Design & AI Co-Building Architecture**

Comprehensive technical specifications, gameplay mechanics, AI harness integration, and theater-specific wargame designs.

# **1\. Executive Summary & Philosophy of OSINT Game Design**

## **Deconstructing Indie Game Development Traps**

Solo and small-team indie developers frequently succumb to the "fidelity trap"—allocating catastrophic amounts of capital and time toward 3D modeling, high-polygon mesh asset creation, rigging, and complex skeletal animation systems. For developers lacking dedicated 3D production pipelines, this approach creates severe bottlenecks, visual inconsistency, and inflated scopes that destroy project viability before core gameplay loops achieve iteration.

## **Cognitive Immersion & Diegetic Interfaces**

Open-Source Intelligence (OSINT) games circumvent asset-heavy traps by redirecting scope toward **cognitive immersion** and **forensic fidelity**. Instead of rendering spatial 3D environments, the player's canvas becomes the workstation terminal, the OS desktop, the satellite imagery viewer, and the database query console.

Diegetic interfaces—where the user interface *is* the in-world object—achieve higher tension and immersion at a fraction of the graphical cost. The narrative and tension stem from realistic data relationships, authentic forensic artifacts, and logical discovery rather than real-time spatial physics.

## **Industry Reference Models**

| Title | Interaction Style | Core Immersion Vector | Key Takeaway for OSINT Design |
| :---- | :---- | :---- | :---- |
| *Her Story* | Search bar & archived video | Text-indexed video database search | Non-linear discovery via semantic keyword queries. |
| *Hypnospace Outlaw* | Simulated OS & web browser | 1990s web culture, OS navigation | Micro-details in fake web pages generate world authenticity. |
| *Papers, Please* | Document cross-referencing | Rule compliance & discrepant data | Verification latency and manual discrepancy checking create tension. |
| *Orwell* | Surveillance dashboard | Document parsing & data submission | Information submission alters world state and character outcomes. |
| *Chinatown Detective Agency* | Mixed desktop & real web | Real-world search engine requirements | Blurring real-world tools with structured game databases. |

# **2\. Core OSINT Gameplay Concepts**

## **The Grey-Zone Analyst (*Signal & Shadow*)**

* **Multimodal Geolocation:** Cross-referencing background terrain contours, foliage type, architectural styles, and road infrastructure against regional datasets.  
* **Shadow Azimuth Matching:** Calculating exact time-of-day from shadows cast by fixed objects using sun position algorithms, pitch/roll geometry, and historic solar charts.  
* **AIS Gap Tracking:** Detecting illegal transshipments, dark fleet oil transfers, and sanction evasion by modeling automatic identification system (AIS) telemetry gaps, draft-change markers, and speed anomalies.  
* **Corporate Shell Entity Resolution:** Traversing multi-jurisdictional registry records, offshore leaks, nominee director networks, and shared physical registration addresses to uncover ultimate beneficial owners (UBOs).

## **The Verification Desk (*Fog of Open Source*)**

* **Disinformation vs. Ground Truth:** Analyzing conflicting field reports, synthetic media, state-backed info-ops, and social media dumps to construct validated chronological timelines.  
* **EXIF Auditing & Spectral Analysis:** Verifying image authenticity via Exchangeable Image File (EXIF) metadata parsing, Error Level Analysis (ELA) for image manipulation detection, and audio spectrogram review to identify acoustic background signatures.  
* **Publication Reputation Engine:** Scoring sources based on historical accuracy, bias vectors, funding sources, and technical reliability before ingesting claims into formal intel briefs.

## **The Digital Bloodhound (*Chasing Dark Networks*)**

* **Passive DNS & Cert Logs:** Mapping infrastructure footprints using historical passive DNS records, WHOIS registration shifts, and Certificate Transparency (CT) log expansion.  
* **On-Chain Crypto Forensics:** Tracking illicit financial flows across public blockchains, clustering wallet addresses via UTXO heuristics, identifying mixer usage, and matching exchange deposit addresses to real-world identities.

# **3\. Autonomous AI Co-Building & The Pareto Frontier**

## **Two-Tier Model Architecture**

To maximize code velocity while minimizing token burn, execution is structured across a tiered model topology:\[ Tier 1: System Architect \]

Claude 3.5 Sonnet / GPT-4o

\- High-level system design

\- Directed Acyclic Graphs (DAGs)

\- Schema definitions & PR reviews

              │

              ▼

\[ Tier 2: REPL Workhorse \]

DeepSeek V3 / Qwen 2.5 Coder 32B

\- High-throughput code generation

\- Test-driven local implementation

\- Repetitive data transformation

## **Key Pre-Build Architecture Decisions**

### **Interaction Topology: Tauri \+ Web Frontend vs. Game Engines**

* **Selected:** Tauri \+ Web Tech (React or Svelte \+ HTML5 Canvas \+ Embedded SQLite).  
* **Rationale:** Game engines (Godot, Unity) introduce unnecessary abstraction layers for UI-heavy, document-centric OSINT games. Web technologies offer native DOM manipulation, rich data grid rendering, precise typography controls, and simple layouting for desktop/OS terminal simulations. Tauri provides a minimal memory footprint and secure native bindings.

### **Verification Contracts**

* **Selected:** Deterministic Graph Traversal & Spatial Geofencing (e.g., Haversine distance calculations for coordinates).  
* **Rationale:** Brittle string-matching causes player frustration due to minor formatting discrepancies. Soft fuzzy-matching introduces false positives. Graph nodes and mathematical geofences ensure rigid, fair validation of player deductions.

### **Determinism vs. Live LLM Simulation**

* **Selected:** Pre-calculated, static runtime fixtures and ground-truth knowledge graphs.  
* **Rationale:** Live LLM API integration at runtime introduces latency, hallucination risks, unbonded costs, non-deterministic quest states, and potential prompt injection exploits. Static knowledge graphs guarantee authored narrative pacing while allowing wide, open-ended player deduction paths.

## **Critical Development Blindspots**

               \[ AGENT DRIFT \]

        Unchecked code & scope bloat

                     │

    ┌────────────────┴────────────────┐

    ▼                                 ▼

\[ INFORMATION DESIGN \]       \[ AGENCY VS LINEARITY \]

Synthetic metadata must      Open search vs curated

match real formats           closed-network discovery

(EXIF, ADS-B, Sanctions)     (Avoid "guess-the-verb")

* **Information Design:** Generating authentic-feeling forensic metadata (ADS-B log parameters, shipping manifests, SWIFT wire headers, EXIF structures) requires manual schema engineering before agent generation.  
* **Agent Drift & Tool-Spam:** Autonomous code generators drift into massive refactoring loops or unneeded dependencies unless bound by explicit specs.  
* **Agency vs. Linearity:** Balancing true open-ended investigation against structured narrative progression requires carefully designed "choke points" where validated key evidence opens access to broader network subgraphs.

# **4\. Harnessing Meridian for Game Development**

## **Mitigating Autonomous Agent Failure Modes**

The Meridian agent harness (`github.com/PCSchmidt/meridian`) resolves common multi-agent development traps:

* **Premature Convergence:** Halting work when a partial, non-functional build is reached.  
* **Unearned Self-Satisfaction:** Agents reporting tasks as complete without running unit or integration tests.  
* **Context Drift:** Loss of architectural constraints across long development sessions.

## **Core Meridian Mechanics**

                 ┌──────────────────────────┐

                 │    Planner / Human Spec  │

                 └─────────────┬────────────┘

                               │

                               ▼

 ┌──────────────────────────────────────────────────────────┐

 │  GENERATOR SUBAGENT (DeepSeek V3 / Qwen 2.5 Coder)      │

 │  Writes code, builds components, edits state             │

 └─────────────────────────────┬────────────────────────────┘

                               │

                               ▼

 ┌──────────────────────────────────────────────────────────┐

 │  PRE-COMMIT TEST GATES (Deterministic CLI)               │

 │  Executes \`npm test\` / \`tsc\` / \`vitest\`                  │

 └──────────────┬────────────────────────────┬──────────────┘

                │ PASS                       │ FAIL

                ▼                            ▼

 ┌──────────────────────────┐  ┌──────────────────────────┐

 │ EVALUATOR SUBAGENT       │  │ Feedback loop sent back  │

 │ (Claude 3.5 Sonnet)      │  │ to Generator for fix     │

 │ Checks design & logic    │  └──────────────────────────┘

 └──────────────┬───────────┘

                │

                ▼

 ┌──────────────────────────┐

 │ Merge to Main Branch     │

 └──────────────────────────┘

* **Hard Generator / Evaluator Separation:** The LLM generating the code is forbidden from evaluating its own work. A separate, higher-tier model assesses correctness and adherence to the specification.  
* **Deterministic Test Gates:** Pre-commit hooks run real-world CLI checks (`vitest`, `tsc`, `eslint`). Code cannot merge if tests fail, regardless of model confidence.  
* **Validated Memory Anchors:** Core schema files, API contracts, and architecture requirements are pinned to system prompts, maintaining context alignment across hundreds of commits.  
* **Recommended Recipe:** Utilizing the `fullstack-web` recipe customized for Tauri, React, Tailwind, and embedded SQLite.

# **5\. Defense-Aligned Game Concepts: The Oceania Theater**

Connecting real-world defense data engineering—heterogeneous streaming feeds, geopolitical intelligence, and regional Common Operating Pictures (COP)—into compelling gameplay mechanics.

## **Game 1: First Island / Blue Continent**

* **Genre:** Macro Wargame / Grand Strategy & Operational Level.  
* **Focus:** Distributed maritime warfare, gray-zone coercion, and sensor-grid management across the Pacific.  
* **Core Mechanics:** Allocating Synthetic Aperture Radar (SAR) satellite passes, managing hydrophone arrays, deploying High-Altitude Long-Endurance (HALE) UAVs, maneuvering passive intelligence ships, counter-lawfare operations, and managing regional escalation ladders without crossing kinetic thresholds.

## **Game 2: The Oceania Desk**

* **Genre:** Maritime Domain Awareness (MDA) & COP Stream Simulator.  
* **Focus:** Tactical-level intelligence analysis workstation.  
* **Core Mechanics:** Ingesting real-time streaming data feeds (AIS telemetry, radio direction-finding points, satellite imagery hits). Players cross-reference dark vessels, track illegal, unreported, and unregulated (IUU) fishing fleets, map undersea cable repair ship anomalies, evaluate island infrastructure investments, and author Daily Intelligence Briefs (DIBs) for military/policy decision-makers.

## **Game 3: Outpost 19: Iron Atoll**

* **Genre:** Diegetic 1st-Person Edge SCIF Simulator.  
* **Focus:** High-tension, single-room physical and digital system operation.  
* **Core Mechanics:** Set entirely within a 20-foot containerized Sensitive Compartmented Information Facility (SCIF) located on a remote Micronesian atoll. Achievable 3D scope: single-room static environment. Players manually swap server blade racks, adjust physical antenna azimuths during tropical storms, manage power consumption, enforce EMCON (Emissions Control) silent protocols, and decipher high-frequency (HF/VHF) signal intercepts.

## **Game 4: Dark Cable**

* **Genre:** Subsea Infrastructure & Acoustic Warfare Sim.  
* **Focus:** Bathymetric micro-tactical defense and interdiction.  
* **Core Mechanics:** Monitoring deep-sea fiber optic trunk lines. Players deploy Autonomous Underwater Vehicles (AUVs), analyze passive sonar signatures against bathymetric topographies, detect mothership subsea activity, and neutralize seabed espionage/sabotage operations without escalating to surface warfare.

# **6\. Execution Roadmap & Recommended First Steps**

## **Phase 0: Case \#1 Ground-Truth Specification**

Write the complete ground-truth narrative graph for the initial tutorial case before writing system code:

* Define target entity, evidence nodes, required tool sequence, and validation conditions.  
* Generate authentic mock datasets: synthetic EXIF headers, AIS trajectory CSVs, mock domain WHOIS queries, and redacted PDF records.

## **Phase 1: Tech Stack Initialization**

Set up a clean, lightweight monorepo architecture:

* Framework: Tauri v2 \+ React \+ TypeScript.  
* State Management: Zustand / TanStack Query.  
* Database: Embedded SQLite (via Tauri plugin) with SQL.js fallbacks for web builds.  
* UI Engine: TailwindCSS \+ Lucide Icons \+ Canvas-based map renderer (Leaflet/MapLibre GL).

## **Phase 2: Meridian Harness Setup**

Initialize the project directory with the Meridian agent harness framework:\# Clone and install Meridian harness inside the project repository

bash ../meridian/install.sh . \--recipe fullstack-web

Configure `.meridian/config.json` to assign model roles:

* **Generator:** `deepseek/deepseek-chat` or `qwen/qwen-2.5-coder-32b`  
* **Evaluator:** `anthropic/claude-3-5-sonnet`

## **Phase 3: Evaluator Subagent Prompting & Validation Gates**

* Define `vitest` validation contracts for case completion states.  
* Set up pre-commit gates enforcing TypeScript zero-error strict mode.  
* Prompt the Evaluator subagent with rigid state transition rules, ensuring autonomous code generation remains strictly bound to the game's intelligence validation graph.

