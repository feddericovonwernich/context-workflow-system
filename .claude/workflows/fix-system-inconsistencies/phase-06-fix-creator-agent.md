---
phase_metadata:
  inputs:
    files:
      - name: CREATOR_AGENT
        required: true
        path: "$BASE_DIR/agents/workflow/workflow-creator.md"
        description: "Workflow creator agent prompt"
    parameters:
      - name: BASE_DIR
        required: true
        description: "Base .claude directory"
  outputs:
    files:
      - path: "$BASE_DIR/agents/workflow/workflow-creator.md"
        description: "Fixed creator agent"
    parameters:
      - name: CREATOR_FIXES
        description: "Number of creator fixes"
---

# Phase 06: Fix Workflow Creator Agent

**Purpose**: Clarify parallel execution constraint to prevent confusion about agent invocation.

## Prerequisites
- Core fixes complete

## Tasks for Todo List
1. Add clarification about orchestrator launching agents for parallel phases
2. Ensure no contradiction between "no nested agents" and parallel config

## Process

### Fix 1: Clarify Parallel Execution (after line 200)

After the parallel phase metadata example, add this clarification:

```markdown
**Important Clarification**: The `agent_type` in `parallel_config` specifies which agent the **workflow orchestrator** will launch for each work item. The phase itself does NOT invoke agents - the orchestrator does. This maintains the "no nested agent execution" constraint while enabling parallelism.

In other words:
- Phase files define WHAT work should be parallelized
- The orchestrator decides HOW to parallelize (by launching multiple agents)
- The executing agent still cannot invoke other agents
```

### Fix 2: Update the Constraint Section (around line 28-33)

Add a cross-reference:

**Current**:
```markdown
## CRITICAL CONSTRAINT: No Nested Agent Execution

Phases CANNOT invoke sub-agents. See `.claude/docs/SPECIFICATION.md#agent-constraints` for full details.

**Key rule**: If complex work requires multiple specialized approaches, design it as SEQUENTIAL PHASES, not nested agent calls.
```

**Enhanced**:
```markdown
## CRITICAL CONSTRAINT: No Nested Agent Execution

Phases CANNOT invoke sub-agents. See `.claude/docs/SPECIFICATION.md#agent-constraints` for full details.

**Key rules**:
- If complex work requires multiple specialized approaches, design it as SEQUENTIAL PHASES
- For parallel processing of similar items, use `parallel_config` (the orchestrator handles agent launching)
- Never include Task tool calls or `claude -p` commands in phase instructions
```

## Outputs
- Updated workflow-creator.md with clear parallel execution guidance

## Success Criteria
- [ ] Parallel execution constraint is unambiguous
- [ ] Clear distinction between phase instructions and orchestrator behavior

## Error Handling
- Maintain existing document structure
