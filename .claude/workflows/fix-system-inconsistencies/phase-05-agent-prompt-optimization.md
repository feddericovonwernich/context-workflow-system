---
phase_metadata:
  execution_mode: sequential

  inputs:
    parameters:
      - name: PROJECT_ROOT
        required: true
        description: "Root directory of the context-workflow-system project"
      - name: DRY_RUN
        required: false
        default: false
        description: "Show changes without applying"

  outputs:
    files:
      - path: "$PROJECT_ROOT/.claude/agents/workflow/phase-executor.md"
        description: "Enhanced phase-executor with parallel mode and runtime-parameters guidance"
      - path: "$PROJECT_ROOT/.claude/agents/workflow/workflow-creator.md"
        description: "Optimized workflow-creator with reduced redundancy"
    parameters:
      - name: PROMPT_FIXES_APPLIED
        description: "Number of prompt optimization fixes applied"
        type: integer

  preferred_agent: phase-executor
---

# Phase 5: Agent Prompt Optimization

**Purpose**: Improve agent prompt effectiveness by adding missing guidance and reducing redundancy.

## Prerequisites
- Phase 4 completed successfully (specification completeness done)
- Agent prompt files accessible and writable

## Tasks for Todo List
1. Add parallel execution mode guidance to phase-executor.md
2. Add runtime-parameters.yaml format documentation to phase-executor.md
3. Consolidate redundant sections in workflow-creator.md
4. Improve prompt clarity and remove duplication

## Parameters Used
- `PROJECT_ROOT`: Base directory for all file operations
- `DRY_RUN`: If true, only show what would change

## Process

### Step 1: Add Parallel Mode Guidance to Phase-Executor (Finding #21)

**File**: `$PROJECT_ROOT/.claude/agents/workflow/phase-executor.md`

**Location**: After the "Input Format" section (around line 84), add new section:

**Add this content**:
```markdown
## Parallel Execution Context

When executing in parallel mode, you may receive context indicating you are one of multiple agents processing similar items:

```
## Phase: [Phase Name] - PARALLEL EXECUTION

### Parallel Context
- Work Item: [specific item assigned to you]
- Total Items: [N items being processed in parallel]
- Your Assignment: Process item [X] of [N]

### Your Input Files
- [path/to/specific/work-item.md] (WORK_ITEM_FILE)

### Common Parameters
- OUTPUT_DIR: /path/to/output
- OTHER_PARAM: value
```

**Important for Parallel Execution**:
1. Focus ONLY on your assigned work item
2. Do not attempt to process other items
3. Write outputs to the pattern specified (your outputs must not conflict with other agents)
4. Your completion report will be aggregated with others by the orchestrator
5. You still cannot invoke other agents - work directly on your item
```

### Step 2: Add Runtime-Parameters Format Documentation (Finding #21 continued)

**File**: `$PROJECT_ROOT/.claude/agents/workflow/phase-executor.md`

**Location**: After "Output Requirements" section (around line 91), add new section:

**Add this content**:
```markdown
## Runtime Parameters File

The orchestrator maintains a `runtime-parameters.yaml` file that tracks parameters through workflow execution. When you discover new parameters, they will be merged into this file.

**File Location**: `<workflow-directory>/runtime-parameters.yaml`

**Structure**:
```yaml
generated_at: "2025-01-13T10:30:00Z"
workflow_run_id: "wf-20250113-103000-abc123"

initial:                    # Parameters from workflow.yaml and CLI (unchanged)
  OUTPUT_DIR: "./outputs"
  ENVIRONMENT: "production"

discovered:                 # Parameters discovered during execution (cumulative)
  SPECS_COUNT: 12
  DATABASE_TYPE: "postgresql"

current:                    # Merged state (initial + discovered)
  OUTPUT_DIR: "./outputs"
  ENVIRONMENT: "production"
  SPECS_COUNT: 12
  DATABASE_TYPE: "postgresql"
```

**Your Role**: Report discovered parameters in your completion report. The orchestrator handles file updates.

```yaml
# In your completion report:
parameters_discovered:
  NEW_PARAM: "value discovered during execution"
  COUNT: 42
```
```

### Step 3: Consolidate Workflow-Creator Redundancy (Finding #22)

**File**: `$PROJECT_ROOT/.claude/agents/workflow/workflow-creator.md`

The "No Nested Agent Execution" constraint is mentioned 6+ times. Consolidate into a single, prominent section.

**Changes**:

1. **Keep the CRITICAL CONSTRAINT section** (lines 17-21) - this is the primary definition

2. **Remove redundant mentions**. Find and remove or consolidate these patterns:
   - "Remember: Phases cannot invoke agents"
   - "Agents CANNOT invoke other agents"
   - Repeated warnings about no nested execution in multiple sections

3. **In "Phase 4: Workflow Generation" section**, replace multiple warnings with a single reference:

**Find patterns like**:
```markdown
#### Proper Phase Design Without Nested Agents
Remember: Phases cannot invoke agents. Design complex work as sequential phases.
```

**Replace with**:
```markdown
#### Phase Design Principles
Design all phases to execute work directly. For constraints on agent invocation, see the CRITICAL CONSTRAINT section above.
```

4. **In "Red Flags to Avoid" section** (lines 379-401), this section is good and should remain as it provides actionable guidance, but update the intro:

**Current**:
```markdown
### Red Flags to Avoid in Phase Content
NEVER include these patterns in generated phases:
```

**Replace with**:
```markdown
### Patterns to Avoid in Generated Phases
Per the agent execution constraints, NEVER include these patterns:
```

5. **Remove duplicate workflow type tables**. The workflow type detection appears in multiple places. Keep only:
   - Phase 2: Workflow Type Detection (comprehensive list)
   - Workflow Categories & Templates (reference patterns)

   Remove inline repetitions elsewhere.

### Step 4: Improve Prompt Clarity

**File**: `$PROJECT_ROOT/.claude/agents/workflow/workflow-creator.md`

**Optimization**: Add a quick reference summary at the top for key decisions

**Location**: After the description metadata (line 7), add:

```markdown
## Quick Reference

| Aspect | Guideline |
|--------|-----------|
| Phase Count | Simple: 2-3, Medium: 4-5, Complex: 6+ |
| Naming | `phase-XX-descriptive-name.md` (XX = two digits) |
| Parameters | UPPER_SNAKE_CASE always |
| Outputs | `.claude/workflows/<name>/` directory |
| Constraint | Phases execute directly - NO agent delegation |

For detailed specifications, see `.claude/docs/SPECIFICATION.md`.
```

### Step 5: Add Input Parameter Type Requirement Clarification (Finding #18)

**File**: `$PROJECT_ROOT/.claude/agents/workflow/phase-executor.md`

**Location**: In the "Input Format" section, add clarification about parameter types:

**Find**:
```markdown
### Parameters
- PARAM1: value1
- PARAM2: value2
```

**Replace with**:
```markdown
### Parameters
Parameters are provided with resolved values. Types are for documentation:
- PARAM1: value1 (string)
- PARAM2: 42 (integer)
- PARAM3: true (boolean)
```

## Outputs
- Enhanced phase-executor.md with parallel mode and runtime-parameters guidance
- Optimized workflow-creator.md with reduced redundancy and quick reference
- PROMPT_FIXES_APPLIED = 5

## Success Criteria
- [ ] phase-executor.md explains parallel execution context
- [ ] phase-executor.md documents runtime-parameters.yaml format
- [ ] workflow-creator.md has no redundant "no nested agents" warnings
- [ ] workflow-creator.md has quick reference table at top
- [ ] Prompts are clearer and more focused
- [ ] No information loss from consolidation

## Error Handling
- **Content removal concerns**: Before removing content, verify it's truly redundant
- **Reference breaks**: Ensure removed sections aren't referenced elsewhere
- **Prompt too short**: Consolidation should not remove essential guidance

## Rollback Plan
Restore agent files from Phase 0 backup:
```bash
cp $BACKUP_DIR/.claude/agents/workflow/phase-executor.md $PROJECT_ROOT/.claude/agents/workflow/
cp $BACKUP_DIR/.claude/agents/workflow/workflow-creator.md $PROJECT_ROOT/.claude/agents/workflow/
```

## Notes
- Prompt optimization improves agent effectiveness
- Redundancy removal reduces token usage and confusion
- Clear quick references speed up agent orientation
- Parallel mode documentation enables future parallel execution features
