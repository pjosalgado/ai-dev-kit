# CRITICAL: Read this file FIRST before doing anything else

## Rules

1. Don't assume. Don't hide confusion. Surface tradeoffs.
2. Minimum code that solves the problem. Nothing speculative.
3. Touch only what you must. Clean up only your own mess.
4. Define success criteria. Loop until verified.

## First Step

Before doing anything, ask the user:

"What would you like to do?
1. Customize an agent or skill in this repository
2. Develop something in my project using the agents/skills from this repository

If option 2, provide the project path (e.g. /home/user/my-project)."

If option 1: proceed with the customization task.
If option 2: switch working directory to the provided project path, then immediately read and load any AI instruction files from it (AGENTS.md, CLAUDE.md, .opencode/ config, .agents/, etc.) before proceeding.
