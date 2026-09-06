# BMad Default Template

A comprehensive AI-powered software development framework with specialized agents, skills, and workflows for the entire product lifecycle.

## Overview

BMad Default provides a structured approach to software development using AI agents that simulate real team roles. The framework covers planning, design, development, testing, and creative processes.

## Modules

- **BMM (BMad Method)** - Core software development workflow with planning and implementation artifacts
- **BMB (BMad Builder)** - Skills and workflow builder for extending the framework
- **CIS (Creative Innovation Suite)** - Creative agents for storytelling, design thinking, brainstorming, and innovation
- **TEA (Test Engineering & Architecture)** - Testing strategy, automation, and quality assurance

## Agents

### Software Development Team
- **Mary** (Analyst) - Business analysis and requirements
- **John** (PM) - Product management and PRD creation
- **Sally** (UX Designer) - User experience and interface design
- **Winston** (Architect) - System architecture and technical design
- **Amelia** (Developer) - Implementation and code development
- **Murat** (Test Architect) - Testing strategy and quality assurance

### Creative Team
- **Sophia** (Storyteller) - Narrative and content creation
- **Maya** (Design Thinking Coach) - Human-centered design
- **Carson** (Brainstorming Coach) - Ideation and creative thinking
- **Dr. Quinn** (Problem Solver) - Systematic problem-solving
- **Victor** (Innovation Strategist) - Business model innovation
- **Caravaggio** (Presentation Expert) - Visual communication

## Skills

78 specialized skills covering:
- PRD creation and validation
- Architecture design
- Sprint planning and retrospectives
- Code review and testing
- Research and analysis
- Creative workflows
- And more

## Configuration

Configuration files:
- `_bmad/config.toml` - Main configuration (read-only, managed by installer)
- `_bmad/custom/config.toml` - Team overrides (committed)
- `_bmad/custom/config.user.toml` - Personal overrides (gitignored)

## Output

All generated artifacts are stored in `_bmad-output/`:
- Planning artifacts
- Implementation artifacts
- Test artifacts

## License

MIT License - see [LICENSE](LICENSE) for details.
