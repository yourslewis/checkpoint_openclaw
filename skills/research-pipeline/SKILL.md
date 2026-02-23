---
name: research-pipeline
description: >
  End-to-end research orchestration with an evaluator-centric control model.
  The evaluator ALWAYS runs in the main agent session, ensuring persistent
  control, retries, and cross-validation. Subagents are used strictly as
  workers (planner, retriever, readers), never as evaluators.
  Use when a task requires structured research, literature review,
  evidence validation, or high-confidence analytical synthesis.
---

## Core Principle (MANDATORY)

**The evaluator ALWAYS runs in the MAIN AGENT.**

- The evaluator is responsible for:
  - orchestration
  - quality control
  - retries and branching
  - final synthesis and decision-making
- Subagents are NEVER evaluators.
- Subagents are short-lived workers only.

This rule exists to guarantee:
- persistent control loops
- stable retries
- reliable file I/O
- platform-safe long reasoning

---

## Entry Contract

```yaml
mode: evaluator
```

Other modes (e.g. cron, scheduled) may exist in the future but MUST still
route evaluation logic through the main agent.

---

## Evaluator-Controlled Pipeline (Authoritative)

### Role Separation

- **Main Agent (Evaluator / Orchestrator)**
  - owns the research state
  - decides what to do next
  - evaluates quality and coverage
  - terminates ONLY when satisfied

- **Subagents (Workers)**
  - planner
  - retriever
  - readers
  - critics (advisory only)

Subagents return artifacts. They do not decide next steps.

---

## Pipeline Stages

### Stage 1: Planning (Worker)

Spawn a planner subagent.

Responsibilities:
- Translate the task into research questions
- Identify relevant categories and entities
- Propose coverage criteria

Constraints:
- No browsing
- No retrieval
- No synthesis

Evaluator responsibility:
- Accept, revise, or reject the plan

---

### Stage 2: Retrieval (Worker)

Spawn one or more retriever subagents.

Responsibilities:
- Discover and download relevant sources
- Prioritize highly cited and authoritative papers

Tools:
- web_search
- web_fetch
- browser (only if unavoidable)

Evaluator responsibility:
- Verify coverage
- Detect missing entities or categories
- Decide whether more retrieval is needed

---

### Stage 3: Reading (Workers, Parallel)

Spawn multiple reader subagents.

Responsibilities:
- Read assigned papers
- Produce one-page structured reviews including:
  - problem addressed
  - key innovations
  - evaluation methodology
  - strengths and weaknesses

Evaluator responsibility:
- Compare reviews
- Identify conflicts or gaps
- Decide whether additional readers or papers are needed

---

### Stage 4: Critique & Synthesis (Evaluator)

Performed EXCLUSIVELY by the main agent.

Responsibilities:
- Cross-validate all reader outputs
- Identify consensus vs disagreement
- Weigh evidence quality
- Synthesize findings into a coherent narrative

Optional:
- Request targeted re-runs of retrieval or reading

---

### Stop Conditions (Evaluator Only)

The evaluator terminates the pipeline ONLY when one is met:

- High confidence achieved
- Acceptable confidence with documented gaps
- Diminishing returns confirmed

---

## Artifacts & Persistence

- All outputs MUST be written to disk
- Subagents return structured artifacts only
- The evaluator owns final artifact layout and naming

---

## Design Guarantees

- No evaluator logic in subagents
- No one-shot evaluator sessions
- Unlimited retry capability
- Stable long-running research

This model is the REQUIRED default for all future uses of this skill.
