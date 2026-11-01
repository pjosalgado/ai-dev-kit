# AI Development Kit

A toolkit for building AI-powered software development workflows. Main topics: **BMad** (structured development methodology), **custom skills**, **hooks**, and repo **Customizations**.

## BMad

[BMad Method](https://docs.bmad-method.org/) is the core framework — it turns a generic AI assistant into an AI-powered development team. You work with specialized agents (PM, Architect, Developer, Tester) through reusable skills and multi-step workflows that cover the full delivery cycle, from requirements to tested code.

| Module | Purpose |
|--------|---------|
| BMM | Core development workflow |
| BMB | Skills and workflow builder |
| CIS | Creative Intelligence Suite |
| TEA | Test Engineering & Architecture |
| BMAD Loop | Automation orchestrator |

## Custom Skills

| Skill | Purpose | Trigger |
|-------|---------|---------|
| `pjos-test-name-audit` | Audits all Spock test names, proposes behavior-focused renames, applies only approved ones, then runs the affected tests | "audit test names" or `/pjos-test-name-audit` |

## Hooks

| Hook config | Event | Condition |
|-------------|-------|-----------|
| `skill-gate.json` | `userPromptSubmitted` | Arms the test gate when the prompt invokes `pjos-test-name-audit`, disarms on any other prompt |
| `skill-gate.json` | `postToolUse` | Runs the changed-test gate when a terminal tool payload contains `skill-sentinel.sh` (and the gate is armed) |
| `agent-stop.json` | `agentStop`/`Stop` | Safety net — runs the changed-test gate at end of turn if the skill was invoked but the sentinel never fired |

## Customizations

- **`AGENTS.md`** — Detects user intent
- **`_bmad/custom/`** — Folder for BMad customizations (project context, configuration)

## Quick Start

1. Clone this repository into your project
2. Run your agent — it will ask whether you want to:
   - Customize an agent/skill
   - Develop in your project
