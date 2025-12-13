---
phase_metadata:
  execution_mode: sequential
  inputs:
    files:
      - name: REFERENCE_FILE
        required: true
        path: "$DOCS_DIR/REFERENCE.md"
        description: "The quick reference document"
    parameters:
      - name: DOCS_DIR
        required: true
        description: "Documentation directory"
      - name: DRY_RUN
        required: false
        default: false
        description: "If true, only report without making changes"
      - name: INTRO_FIXES_APPLIED
        required: true
        description: "Confirms introduction phase completed"
  outputs:
    files:
      - path: "$DOCS_DIR/REFERENCE.md"
        description: "Updated reference document"
    parameters:
      - name: REFERENCE_FIXES_APPLIED
        description: "Number of reference fixes applied"
---

# Phase 4: REFERENCE.md Fixes

**Purpose**: Update the quick reference document to fix the phase_metadata requirement statement, add missing information, and ensure consistency with the updated SPECIFICATION.md.

## Prerequisites
- Introduction fixes completed (INTRO_FIXES_APPLIED confirmed)
- Write access to $DOCS_DIR

## Tasks for Todo List
1. Read current REFERENCE.md
2. Fix phase_metadata "Required" statement
3. Add `array` type to parameter types table
4. Add environment variable prefix documentation
5. Fix relative path references
6. Add minimum phase count clarification
7. Verify all information matches SPECIFICATION.md

## Parameters Used
- `DOCS_DIR`: Location of documentation files
- `DRY_RUN`: Whether to apply changes or just report
- `INTRO_FIXES_APPLIED`: Confirms safe to proceed

## Process

### Step 1: Fix Phase Metadata "Required" Statement

**Issue**: REFERENCE.md says phase_metadata is "Required" but SPECIFICATION.md treats it as WARNING (recommended but not blocking).

**Location**: Line 46

**Current Text**:
```markdown
## Phase Metadata (Required at top of each phase file)
```

**Change To**:
```markdown
## Phase Metadata (Recommended at top of each phase file)
```

**Also Add** a note after the metadata block example (around line 78):
```markdown
> **Note**: Phase metadata is strongly recommended for explicit input/output contracts. Phases without metadata will still execute but with implicit parameter passing.
```

### Step 2: Add `array` Type to Parameter Types Table

**Location**: Lines 111-120 (Parameter Types table)

**Current Table**:
```markdown
| Type | Example | Description |
|------|---------|-------------|
| `string` | `"text"` | Text value |
| `boolean` | `true` | True/false |
| `integer` | `42` | Whole number |
| `number` | `3.14` | Decimal number |
| `enum` | `"prod"` | From list |
| `file` | `"./file"` | File path |
| `directory` | `"./dir"` | Dir path |
```

**Add Row**:
```markdown
| `array` | `["a","b"]` | List of values |
```

### Step 3: Add Environment Variable Prefix Documentation

**Location**: After Parameter Resolution Order section (around line 127)

**Add New Section**:
```markdown
## Environment Variables

Parameters can be set via environment variables using the `WORKFLOW_` prefix:

| Parameter | Environment Variable |
|-----------|---------------------|
| `OUTPUT_DIR` | `WORKFLOW_OUTPUT_DIR` |
| `MAX_RETRIES` | `WORKFLOW_MAX_RETRIES` |
| `ENVIRONMENT` | `WORKFLOW_ENVIRONMENT` |
```

### Step 4: Fix Relative Path References

**Location**: Lines 186-189 (File References section)

**Current Text**:
```markdown
## File References
- [Full Specification](SPECIFICATION.md)
- [Introduction](INTRODUCTION.md)
- [Workflow Schema](../schemas/workflow-schema.yaml)
- [Phase Schema](../schemas/phase-metadata-schema.yaml)
```

**Change To** (add context note):
```markdown
## File References

Paths relative to `.claude/docs/`:
- [Full Specification](SPECIFICATION.md)
- [Introduction](INTRODUCTION.md)
- [Workflow Schema](../schemas/workflow-schema.yaml)
- [Phase Schema](../schemas/phase-metadata-schema.yaml)

From project root, use:
- `.claude/docs/SPECIFICATION.md`
- `.claude/docs/INTRODUCTION.md`
- `.claude/schemas/workflow-schema.yaml`
- `.claude/schemas/phase-metadata-schema.yaml`
```

### Step 5: Add Minimum Phase Count Clarification

**Location**: In Directory Structure section (around line 17)

**Current Text**:
```markdown
## Directory Structure
```
```
workflow-directory/
├── workflow.yaml          # REQUIRED: Configuration
├── phase-01-*.md         # REQUIRED: First phase
├── phase-02-*.md         # REQUIRED: Second phase
├── phase-00-*.md         # Optional: Setup phase
├── README.md             # Recommended: Documentation
└── examples/             # Optional: Examples
```

**Add Note After**:
```markdown
> **Minimum**: 2 phase files required. Can be `phase-00` + `phase-01` OR `phase-01` + `phase-02`.
```

### Step 6: Update Critical Rules Section

**Location**: Lines 148-154 (Critical Rules section)

**Current Text**:
```markdown
## Critical Rules
1. **No Nested Agents**: Agents cannot invoke other agents
2. **Sequential Phases**: No gaps in numbering
3. **Parameter Names**: UPPER_SNAKE_CASE
4. **File Names**: phase-XX-name.md format
5. **Explicit Dependencies**: All inputs declared
```

**Change To** (add minimum phases rule):
```markdown
## Critical Rules
1. **No Nested Agents**: Agents cannot invoke other agents
2. **Minimum Phases**: At least 2 phase files required
3. **Sequential Numbering**: No gaps allowed (01, 02, 03... not 01, 03)
4. **Parameter Names**: UPPER_SNAKE_CASE
5. **File Names**: `phase-XX-name.md` format (XX = two digits)
6. **Explicit Dependencies**: All inputs should be declared in metadata
```

### Step 7: Verify Troubleshooting Table

**Location**: Lines 191-199 (Troubleshooting section)

**Verify** the table includes agent-related issues:

```markdown
| Issue | Solution |
|-------|----------|
| "Phase not found" | Check naming: phase-XX-*.md |
| "Parameter undefined" | Add to workflow.yaml |
| "Missing metadata" | Add phase_metadata section |
| "Agent failed" | Check phase can't invoke agents |
| "Sequence gap" | Ensure sequential numbering |
```

If "Sequence gap" row is missing, add it.

### Step 8: Verify Consistency with Updated Docs

Cross-check that all information in REFERENCE.md aligns with:
- Updated SPECIFICATION.md (from Phase 2)
- Updated INTRODUCTION.md (from Phase 3)

Report any remaining inconsistencies found.

## Outputs
- Updated `$DOCS_DIR/REFERENCE.md`

## Success Criteria
- [ ] Phase metadata marked as "Recommended" not "Required"
- [ ] Note added explaining metadata is optional but encouraged
- [ ] `array` type added to parameter types table
- [ ] Environment variable prefix documented
- [ ] File references have context about relative paths
- [ ] Minimum phase count clarified
- [ ] Critical Rules section updated with 6 rules
- [ ] Document parses as valid markdown

## Error Handling
- If sections not found at expected locations, search and report actual locations
- If table format differs, adapt changes to match existing format
- Report any inconsistencies that couldn't be resolved

## Rollback Plan
Restore `$DOCS_DIR/REFERENCE.md` from `$SYSTEM_ROOT/backups/pre-fix-backup-v2/docs/REFERENCE.md`
