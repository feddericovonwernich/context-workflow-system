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
      - path: "$PROJECT_ROOT/.claude/commands/run-workflow.md"
        description: "Fixed run-workflow command (removed agent invocation claim)"
      - path: "$PROJECT_ROOT/.claude/agents/workflow/workflow-creator.md"
        description: "Fixed workflow-creator agent (corrected template path)"
      - path: "$PROJECT_ROOT/.claude/agents/workflow/workflow-validator.md"
        description: "Fixed workflow-validator agent (corrected docs path)"
      - path: "$PROJECT_ROOT/.claude/docs/REFERENCE.md"
        description: "Fixed REFERENCE.md (corrected parameter casing)"
    parameters:
      - name: CRITICAL_FIXES_APPLIED
        description: "Number of critical fixes applied"
        type: integer

  preferred_agent: phase-executor
---

# Phase 1: Critical Path Fixes

**Purpose**: Fix the 4 critical issues that block functionality or cause immediate failures.

## Prerequisites
- Phase 0 completed successfully (backups created)
- All target files are readable and writable
- PROJECT_ROOT parameter is valid

## Tasks for Todo List
1. Fix agent invocation contradiction in run-workflow.md
2. Fix template path in workflow-creator.md
3. Fix docs path in workflow-validator.md
4. Fix parameter casing in REFERENCE.md

## Parameters Used
- `PROJECT_ROOT`: Base directory for all file operations
- `DRY_RUN`: If true, only show what would change

## Process

### Step 1: Fix Agent Invocation Contradiction (Finding #1)

**File**: `$PROJECT_ROOT/.claude/commands/run-workflow.md`

**Location**: Lines 617-620

**Current (INCORRECT)**:
```markdown
## Integration with Other Commands

Phases executed via agents can still use other Claude commands and tools:
- Agents can call specialized sub-agents
- Use search and analysis tools within phase execution
- Maintain composability while ensuring isolation
```

**Replace with (CORRECT)**:
```markdown
## Integration with Other Commands

Phases executed via agents have access to Claude's built-in tools:
- File operations (read, write, edit)
- Bash commands and script execution
- Search and analysis tools
- Web requests via appropriate tools

**Important**: Agents CANNOT invoke other agents. The Task tool is not available within phase execution. All work must be completed directly by the phase-executor agent.
```

**Rationale**: This aligns with the fundamental architectural constraint documented in SPECIFICATION.md and all agent definitions.

### Step 2: Fix Template Path (Finding #2)

**File**: `$PROJECT_ROOT/.claude/agents/workflow/workflow-creator.md`

**Location**: Line 34

**Current (INCORRECT)**:
```markdown
- **Templates**: `.claude/templates/workflows/` and `.claude/templates/workflows/phase-template.md`
```

**Replace with (CORRECT)**:
```markdown
- **Templates**: `.claude/templates/phase-template.md`
```

**Rationale**: The template file exists at `.claude/templates/phase-template.md`, not in a `workflows/` subdirectory.

### Step 3: Fix Docs Path (Finding #3)

**File**: `$PROJECT_ROOT/.claude/agents/workflow/workflow-validator.md`

**Location**: Line 25 (in Phase 1: System Understanding section)

**Current (INCORRECT)**:
```markdown
### Phase 1: System Understanding
1. Read `.claude/workflows/INTRODUCTION.md` to understand workflow system
```

**Replace with (CORRECT)**:
```markdown
### Phase 1: System Understanding
1. Read `.claude/docs/INTRODUCTION.md` to understand workflow system
```

**Rationale**: INTRODUCTION.md is located in `.claude/docs/`, not `.claude/workflows/`.

### Step 4: Fix Parameter Casing in REFERENCE.md (Finding #4)

**File**: `$PROJECT_ROOT/.claude/docs/REFERENCE.md`

**Location**: Lines 33-37 (in workflow.yaml Structure section)

**Current (INCORRECT)**:
```yaml
parameters:               # Optional: parameters
  param_name:
    type: string         # string|boolean|integer|enum|file|directory
    required: true       # Is required?
    default: value       # Default value
    description: "..."   # Description
```

**Replace with (CORRECT)**:
```yaml
parameters:               # Optional: parameters
  PARAM_NAME:
    type: string         # string|boolean|integer|number|enum|file|directory
    required: true       # Is required?
    default: value       # Default value
    description: "..."   # Description
```

**Rationale**:
1. Parameter names must be UPPER_SNAKE_CASE per schema pattern `"^[A-Z][A-Z0-9_]*$"`
2. Also added `number` type to the comment for completeness

## Outputs
- 4 modified files with critical fixes applied
- CRITICAL_FIXES_APPLIED = 4

## Success Criteria
- [ ] run-workflow.md no longer claims agents can invoke sub-agents
- [ ] workflow-creator.md references correct template path `.claude/templates/phase-template.md`
- [ ] workflow-validator.md references correct docs path `.claude/docs/INTRODUCTION.md`
- [ ] REFERENCE.md uses UPPER_SNAKE_CASE parameter names in examples
- [ ] All modified files remain valid markdown
- [ ] No syntax errors introduced

## Error Handling
- **String not found**: If the exact text to replace isn't found, the file may have been modified. Report the issue and show surrounding context.
- **Multiple matches**: If the search string appears multiple times, be precise about which occurrence to replace.
- **Permission denied**: Verify file permissions, report if unable to write.

## Rollback Plan
Restore from backup directory created in Phase 0:
```bash
cp $BACKUP_DIR/.claude/commands/run-workflow.md $PROJECT_ROOT/.claude/commands/
cp $BACKUP_DIR/.claude/agents/workflow/workflow-creator.md $PROJECT_ROOT/.claude/agents/workflow/
cp $BACKUP_DIR/.claude/agents/workflow/workflow-validator.md $PROJECT_ROOT/.claude/agents/workflow/
cp $BACKUP_DIR/.claude/docs/REFERENCE.md $PROJECT_ROOT/.claude/docs/
```

## Notes
- These 4 fixes are the highest priority as they cause immediate failures
- The agent invocation fix is especially important as it contradicts a fundamental architectural constraint
- After this phase, basic workflow creation and validation should work correctly
