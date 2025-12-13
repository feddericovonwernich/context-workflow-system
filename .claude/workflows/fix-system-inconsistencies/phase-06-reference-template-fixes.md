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
      - path: "$PROJECT_ROOT/.claude/docs/REFERENCE.md"
        description: "Fixed REFERENCE.md with complete parallel config and consistent examples"
      - path: "$PROJECT_ROOT/.claude/docs/SPECIFICATION.md"
        description: "Updated SPECIFICATION.md with parameter interpolation clarity"
      - path: "$PROJECT_ROOT/.claude/docs/INTRODUCTION.md"
        description: "Updated INTRODUCTION.md with examples directory documentation"
    parameters:
      - name: MINOR_FIXES_APPLIED
        description: "Number of minor fixes applied"
        type: integer

  preferred_agent: phase-executor
---

# Phase 6: Reference and Template Fixes

**Purpose**: Apply remaining minor fixes to reference documentation, examples, and template files.

## Prerequisites
- Phase 5 completed successfully (prompt optimization done)
- Documentation files accessible and writable

## Tasks for Todo List
1. Add output_pattern to REFERENCE.md parallel config example
2. Document parameter interpolation syntax consistently
3. Document examples/ directory purpose
4. Update schema $id URLs or add disclaimer
5. Document duration_seconds field in SPECIFICATION.md
6. Remove or update non-functional schema URLs

## Parameters Used
- `PROJECT_ROOT`: Base directory for all file operations
- `DRY_RUN`: If true, only show what would change

## Process

### Step 1: Fix REFERENCE.md Parallel Config (Finding #27)

**File**: `$PROJECT_ROOT/.claude/docs/REFERENCE.md`

**Location**: Lines 52-57 (parallel_config example)

**Current (INCOMPLETE)**:
```yaml
  parallel_config:
    agent_type: feature-specifier
    discovery_pattern: "$DIR/*.md"
    work_item_parameter: WORK_FILE
    max_parallel: 5
```

**Replace with (COMPLETE)**:
```yaml
  parallel_config:
    agent_type: feature-specifier
    discovery_pattern: "$OUTPUT_DIR/features/*.md"
    work_item_parameter: FEATURE_FILE
    output_pattern: "$OUTPUT_DIR/specs/{name}-spec.md"
    max_parallel: 5
```

### Step 2: Document Parameter Interpolation Consistency (Finding #25)

**File**: `$PROJECT_ROOT/.claude/docs/SPECIFICATION.md`

**Location**: Lines 173-176 (Parameter Interpolation section)

**Current (BRIEF)**:
```markdown
### Parameter Interpolation
- Use `$PARAMETER_NAME` or `${PARAMETER_NAME}` in paths
- Parameters resolved from workflow.yaml, CLI, and previous phases
- Example: `path: "$OUTPUT_DIR/$SPECS_DIR/report.md"`
```

**Replace with (DETAILED)**:
```markdown
### Parameter Interpolation

Parameters can be interpolated in paths and configuration values using two equivalent syntaxes:

**Syntax Options**:
- `$PARAMETER_NAME` - Simple form, works in most cases
- `${PARAMETER_NAME}` - Explicit form, required when parameter is adjacent to other characters

**When to Use Each**:
```yaml
# Simple form (preferred when unambiguous)
path: "$OUTPUT_DIR/report.md"

# Explicit form (required when adjacent to other text)
path: "${OUTPUT_DIR}_backup/report.md"
filename: "${PREFIX}report.md"
```

**Resolution Sources** (in priority order):
1. Command-line arguments
2. Environment variables (WORKFLOW_PARAM_NAME format)
3. Previous phase outputs (from runtime-parameters.yaml)
4. Default values in workflow.yaml
5. Default values in phase metadata

**Example**:
```yaml
path: "$OUTPUT_DIR/$SPECS_DIR/report.md"
# With OUTPUT_DIR=./outputs and SPECS_DIR=specs
# Resolves to: ./outputs/specs/report.md
```

**Note**: Both syntaxes are functionally equivalent. Use `${}` form when the parameter name would otherwise be ambiguous in context.
```

### Step 3: Document Examples Directory Purpose (Finding #26)

**File**: `$PROJECT_ROOT/.claude/docs/INTRODUCTION.md`

**Location**: After the workflow directory structure section (around line 57), add documentation:

**Find the workflow structure**:
```markdown
workflow-directory/
├── workflow.yaml           # Metadata and parameter definitions
├── README.md              # Human-readable documentation
├── phase-00-*.md          # Optional setup/discovery phase
├── phase-01-*.md          # First execution phase
├── phase-02-*.md          # Subsequent phases
└── examples/
    └── parameters.yaml    # Example parameter sets
```

**After this structure, add explanation**:
```markdown
#### Examples Directory

The `examples/` directory contains sample parameter files for running the workflow:

**examples/parameters.yaml**:
```yaml
# Example parameters for development environment
ENVIRONMENT: "development"
OUTPUT_DIR: "./outputs/dev"
BACKUP_ENABLED: false
MAX_RETRIES: 3

# Example parameters for production environment (commented)
# ENVIRONMENT: "production"
# OUTPUT_DIR: "./outputs/prod"
# BACKUP_ENABLED: true
# MAX_RETRIES: 5
```

**Purpose**:
- Provides ready-to-use parameter configurations
- Documents expected parameter values and formats
- Enables quick testing without manual parameter entry
- Serves as documentation for workflow users

**Usage**:
```bash
# Use example parameters directly
run-workflow .claude/workflows/my-workflow --params examples/parameters.yaml
```
```

### Step 4: Add Schema URL Disclaimer (Finding #23)

**File**: `$PROJECT_ROOT/.claude/schemas/workflow-schema.yaml`

**Location**: Lines 3-4 (after $schema declaration)

**Current**:
```yaml
$schema: http://json-schema.org/draft-07/schema#
$id: https://claude.ai/workflows/schemas/workflow.yaml
```

**Replace with**:
```yaml
$schema: http://json-schema.org/draft-07/schema#
# Note: $id is a local identifier for schema references, not a resolvable URL
$id: https://claude.ai/workflows/schemas/workflow.yaml
```

**Also update `phase-metadata-schema.yaml`** similarly:

**Current**:
```yaml
$schema: http://json-schema.org/draft-07/schema#
$id: https://claude.ai/workflows/schemas/phase-metadata.yaml
```

**Replace with**:
```yaml
$schema: http://json-schema.org/draft-07/schema#
# Note: $id is a local identifier for schema references, not a resolvable URL
$id: https://claude.ai/workflows/schemas/phase-metadata.yaml
```

### Step 5: Document duration_seconds Field (Finding #24)

**File**: `$PROJECT_ROOT/.claude/docs/SPECIFICATION.md`

**Location**: In the "Phase Completion Protocol" section (around lines 219-220)

**Find**:
```markdown
**Optional Fields**:
- `notes`: Array of observation strings
- `duration_seconds`: Execution time estimate
```

**Replace with (expanded)**:
```markdown
**Optional Fields**:
- `notes`: Array of observation strings - useful observations, warnings, or suggestions for subsequent phases
- `duration_seconds`: Approximate execution time in seconds - used for logging and performance analysis

**Field Details**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `status` | string | Yes | `SUCCESS` or `FAILURE` |
| `outputs_created` | array | Yes | List of `{path, exists}` objects |
| `parameters_discovered` | object | Yes | Key-value pairs (empty `{}` if none) |
| `success_criteria` | array | Yes | List of `{criterion, met}` objects |
| `errors` | array | Yes | Error messages (empty `[]` if success) |
| `notes` | array | No | Observations or warnings |
| `duration_seconds` | integer | No | Execution time for logging |
```

### Step 6: Fix Run-Workflow Runtime Parameters References

**File**: `$PROJECT_ROOT/.claude/commands/run-workflow.md`

Search for all occurrences of `parameters.yaml` that refer to runtime parameters (NOT `examples/parameters.yaml`) and ensure consistency with `runtime-parameters.yaml`.

**Locations to check**:
- Line 57: Already fixed in Phase 3
- Line 214-219: Check parameter resolution section
- Line 285: Check process section

Verify all runtime parameter references use `runtime-parameters.yaml`.

## Outputs
- Fixed REFERENCE.md with complete parallel config
- Updated SPECIFICATION.md with interpolation details and field documentation
- Updated INTRODUCTION.md with examples directory documentation
- Updated schema files with URL disclaimers
- MINOR_FIXES_APPLIED = 6

## Success Criteria
- [ ] REFERENCE.md parallel config includes output_pattern
- [ ] Parameter interpolation syntax fully documented with both forms
- [ ] Examples directory purpose and usage documented
- [ ] Schema files have disclaimer about non-resolvable URLs
- [ ] duration_seconds field documented in completion protocol
- [ ] All runtime-parameters.yaml references consistent

## Error Handling
- **Content not found**: Search for similar patterns, report findings
- **Multiple locations**: Update all found locations consistently
- **Unclear context**: Preserve existing valid content, add clarifications

## Rollback Plan
Restore documentation files from Phase 0 backup:
```bash
cp $BACKUP_DIR/.claude/docs/* $PROJECT_ROOT/.claude/docs/
cp $BACKUP_DIR/.claude/schemas/* $PROJECT_ROOT/.claude/schemas/
```

## Notes
- These minor fixes improve overall documentation quality
- Consistent examples prevent user confusion
- Schema disclaimers prevent debugging non-issues
- Complete documentation reduces support questions
