# /plan — Architecture Planning Workflow

## Description
Explore the codebase and produce a structured implementation plan before writing any code. Uses the architect agent to analyze existing patterns and design a solution that fits.

## Usage
```
/plan $ARGUMENTS
```
Where `$ARGUMENTS` is a description of the feature or change to plan.

## Workflow

### Step 1: Explore
Use the architect agent to explore the codebase:
- Project structure and key directories
- Existing patterns for similar features
- Shared utilities and abstractions
- Test patterns in use
- Related configuration

### Step 2: Plan
Produce a structured implementation plan following the architect agent's output format:
- Goal and approach
- Files to create and modify
- Step-by-step implementation guide
- Edge cases and risks
- Testing strategy

### Step 3: Review
Present the plan to the user for feedback. Do NOT proceed to implementation until the user approves.

## Why Plan Before Code?
- **Prevents rework**: Catching a wrong direction after 500 lines of code costs more than 10 minutes of planning
- **Surfaces questions early**: Better to ask "should this be a new service or extend the existing one?" before writing code
- **Ensures consistency**: The plan explicitly references existing patterns — maintaining architectural coherence
- **User alignment**: The user sees the approach before code is written and can steer

## Implementation
Launch the architect agent with the following prompt:

```
Analyze the codebase and create a detailed implementation plan for: $ARGUMENTS

Follow the output format defined in your agent instructions.
Explore existing patterns thoroughly before designing the solution.
Flag any open questions that need user input.
```
