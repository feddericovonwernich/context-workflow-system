---
phase_metadata:
  execution_mode: sequential
  inputs:
    files:
      - name: RUN_WORKFLOW_FILE
        required: true
        path: "$COMMANDS_DIR/run-workflow.md"
        description: "The run-workflow command documentation"
    parameters:
      - name: COMMANDS_DIR
        required: true
        description: "Commands directory"
      - name: DRY_RUN
        required: false
        default: false
        description: "If true, only report without making changes"
      - name: REFERENCE_FIXES_APPLIED
        required: true
        description: "Confirms reference phase completed"
  outputs:
    files:
      - path: "$COMMANDS_DIR/run-workflow.md"
        description: "Updated run-workflow command documentation"
    parameters:
      - name: RUN_WORKFLOW_FIXES_APPLIED
        description: "Number of run-workflow fixes applied"
---

# Phase 5: run-workflow.md Fixes

**Purpose**: Fix inconsistencies in the run-workflow command documentation including file naming, parallel agent guidance, and parameter resolution references.

## Prerequisites
- Reference fixes completed (REFERENCE_FIXES_APPLIED confirmed)
- Write access to $COMMANDS_DIR

## Tasks for Todo List
1. Read current run-workflow.md
2. Fix "parameters.yaml" reference to "runtime-parameters.yaml"
3. Fix parallel agent type guidance
4. Clarify minimum phase requirements
5. Remove or update Constitution references
6. Ensure consistency with SPECIFICATION.md

## Parameters Used
- `COMMANDS_DIR`: Location of command files
- `DRY_RUN`: Whether to apply changes or just report
- `REFERENCE_FIXES_APPLIED`: Confirms safe to proceed

## Process

### Step 1: Fix parameters.yaml Reference

**Issue**: Line 217 references "parameters.yaml" but the canonical file name is "runtime-parameters.yaml".

**Location**: Around line 217 (Parameter Resolution section)

**Search For**:
```markdown
- Store discovered values in parameters.yaml
```

**Change To**:
```markdown
- Store discovered values in runtime-parameters.yaml
```

**Also verify** all other references use "runtime-parameters.yaml" consistently:
- Line 243-244 should reference "runtime-parameters.yaml"
- Any other occurrences should be checked

### Step 2: Fix Parallel Agent Type Guidance

**Issue**: Line 326 says "Use specified agent_type (not phase-executor)" but phase-executor CAN be used for parallel execution.

**Location**: Around line 326 (Parallel Phase Execution section)

**Current Text**:
```markdown
- Use specified agent_type (not phase-executor)
```

**Change To**:
```markdown
- Use the agent_type specified in parallel_config (can be phase-executor or a specialized agent)
```

**Rationale**: The phase-metadata-schema.yaml explicitly shows phase-executor as a valid example for parallel agent_type. The restriction is unnecessary.

### Step 3: Clarify Minimum Phase Requirements

**Location**: Lines 41-58 (Workflow Structure section)

**Current Structure Shows**:
```markdown
### Required Files
Each workflow directory must contain:
```
workflow-directory/
├── workflow.yaml           # Workflow metadata and parameter definitions
├── phase-01-*.md          # First phase (required)
└── phase-02-*.md          # Subsequent phases (at least one more)
```
```

**Add Clarifying Note**:
```markdown
> **Minimum Phases**: A workflow requires at least 2 phase files. Valid configurations:
> - `phase-01-*.md` + `phase-02-*.md` (standard)
> - `phase-00-*.md` + `phase-01-*.md` (with setup phase)
```

### Step 4: Verify Runtime Files Section

**Location**: Around lines 51-58 (Optional Files section)

**Current Text**:
```markdown
### Optional Files
```
workflow-directory/
├── phase-00-setup.md      # Optional setup/discovery phase
├── runtime-parameters.yaml  # Generated runtime parameters
└── execution.log         # Generated execution log
```
```

**Verify** this shows "runtime-parameters.yaml" (not "parameters.yaml").

### Step 5: Check Backward Compatibility Note

**Location**: Lines 625-630 (Backward Compatibility Note section)

**Current Text**:
```markdown
## Backward Compatibility Note

Existing phase files without metadata sections will still work:
- Orchestrator will use legacy parameter extraction
- All parameters will be passed to the agent
- Gradual migration to metadata format recommended
```

**Verify** this is accurate and aligns with our decision that phase_metadata is recommended but not required.

### Step 6: Remove Constitution References

**Search** for any references to:
- "Constitutional compliance"
- "constitution"
- "Constitution"

If found, remove or replace with "specification compliance" or "workflow validation".

### Step 7: Verify Agent Constraint Documentation

**Location**: Line 623

**Current Text**:
```markdown
**Important**: Agents CANNOT invoke other agents. The Task tool is not available within phase execution. All work must be completed directly by the phase-executor agent.
```

**Verify** this text is present and accurate. This is correct and should remain.

### Step 8: Fix Execution Flow Numbering

**Location**: Lines 199-289 (Execution Flow section)

Review the execution flow documentation to ensure:
1. Phase numbering examples are consistent
2. Parameter resolution order matches SPECIFICATION.md
3. All file names are consistent (runtime-parameters.yaml)

### Step 9: Verify Parallel Execution Documentation

**Location**: Lines 291-358 (4a. Parallel Phase Execution section)

Ensure the parallel execution documentation:
1. Uses consistent terminology
2. Doesn't restrict agent_type unnecessarily
3. Shows correct file patterns

## Outputs
- Updated `$COMMANDS_DIR/run-workflow.md`

## Success Criteria
- [ ] All "parameters.yaml" references changed to "runtime-parameters.yaml"
- [ ] Parallel agent type guidance allows phase-executor
- [ ] Minimum phase requirements clarified with note
- [ ] No Constitution references remain
- [ ] Agent constraint documentation verified present
- [ ] Backward compatibility note accurate
- [ ] Document parses as valid markdown

## Error Handling
- If referenced text not found at expected line, search entire document
- Report any sections that have moved or been significantly modified
- If conflicting information found, prioritize SPECIFICATION.md

## Rollback Plan
Restore `$COMMANDS_DIR/run-workflow.md` from `$SYSTEM_ROOT/backups/pre-fix-backup-v2/commands/run-workflow.md`
