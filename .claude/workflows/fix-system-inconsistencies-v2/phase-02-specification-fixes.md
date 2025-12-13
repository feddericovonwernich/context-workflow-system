---
phase_metadata:
  execution_mode: sequential
  inputs:
    files:
      - name: SPECIFICATION_FILE
        required: true
        path: "$DOCS_DIR/SPECIFICATION.md"
        description: "The authoritative specification document"
    parameters:
      - name: DOCS_DIR
        required: true
        description: "Documentation directory"
      - name: DRY_RUN
        required: false
        default: false
        description: "If true, only report without making changes"
      - name: SCHEMA_FIXES_APPLIED
        required: true
        description: "Confirms schema phase completed"
  outputs:
    files:
      - path: "$DOCS_DIR/SPECIFICATION.md"
        description: "Updated specification document"
    parameters:
      - name: SPEC_FIXES_APPLIED
        description: "Number of specification fixes applied"
---

# Phase 2: SPECIFICATION.md Fixes

**Purpose**: Update the authoritative specification document to document missing constraints, fix inconsistencies, clarify ambiguous requirements, and remove references to non-existent features.

## Prerequisites
- Schema fixes completed (SCHEMA_FIXES_APPLIED confirmed)
- Write access to $DOCS_DIR

## Tasks for Todo List
1. Read current SPECIFICATION.md
2. Fix minimum phase requirement language
3. Add constraint length documentation
4. Add `array` type to parameter types table
5. Remove `default_agent` from workflow configuration section
6. Document environment variable prefix convention
7. Document output file `required` field default
8. Remove Constitution references
9. Verify all changes maintain document coherence
10. Validate markdown syntax

## Parameters Used
- `DOCS_DIR`: Location of documentation files
- `DRY_RUN`: Whether to apply changes or just report
- `SCHEMA_FIXES_APPLIED`: Confirms safe to proceed

## Process

### Step 1: Fix Minimum Phase Requirement Language

**Location**: Around line 81

**Current Text**:
```markdown
- **Minimum Phases**: At least two execution phases required (e.g., `01` and `02`, or `00`, `01`, and `02`)
```

**Change To**:
```markdown
- **Minimum Phases**: At least two phase files required. Valid configurations:
  - `phase-01-*.md` and `phase-02-*.md` (standard minimum)
  - `phase-00-*.md` and `phase-01-*.md` (with setup phase)
  - Any sequential combination of 2+ phases with no gaps
```

### Step 2: Add Constraint Length Documentation

**Location**: After line 98 (after version field description), add new subsection:

**Add**:
```markdown
### Field Constraints

| Field | Min Length | Max Length | Format |
|-------|------------|------------|--------|
| `name` | 3 | 50 | kebab-case (`^[a-z][a-z0-9-]*$`) |
| `description` | 10 | 500 | Any text |
| `version` | - | - | Semantic version (`X.Y.Z`) |
| Parameter `description` | 5 | 200 | Any text |
| Phase file `description` | 5 | 200 | Any text |
```

### Step 3: Add `array` Type to Parameter Types Table

**Location**: Line 222-231 (Parameter Types table)

**Current Table** has types: string, boolean, integer, number, enum, file, directory

**Add Row**:
```markdown
| `array` | Array of values | `["a", "b"]` | Valid JSON array |
```

**Updated Table**:
```markdown
| Type | Description | Example | Validation |
|------|-------------|---------|------------|
| `string` | Text value | `"production"` | Any string |
| `boolean` | True/false | `true` | true/false only |
| `integer` | Whole number | `42` | Integer only |
| `number` | Decimal number | `3.14` | Any numeric value |
| `enum` | Restricted choice | `"prod"` | Must match enum list |
| `file` | File path | `"./config.yaml"` | File should exist |
| `directory` | Directory path | `"./outputs"` | Directory should exist |
| `array` | List of values | `["a", "b", "c"]` | Valid JSON/YAML array |
```

### Step 4: Remove default_agent from Workflow Configuration

**Location**: Lines 110-115 (phases configuration section)

**Remove** any reference to `default_agent` from the workflow.yaml structure documentation.

If there's a line like:
```markdown
default_agent: phase-executor  # Default agent type
```
Remove it entirely.

### Step 5: Document Environment Variable Prefix Convention

**Location**: Around line 205 (Parameter Resolution Order section)

**Current Text**:
```markdown
2. Environment variables (WORKFLOW_PARAM_NAME format)
```

**Expand To**:
```markdown
2. Environment variables with `WORKFLOW_` prefix (e.g., `WORKFLOW_OUTPUT_DIR` for parameter `OUTPUT_DIR`)
```

**Also Add** a new note after the resolution order list:
```markdown
**Environment Variable Convention**: To pass a parameter via environment variable, prefix the parameter name with `WORKFLOW_`. For example:
- Parameter `OUTPUT_DIR` → Environment variable `WORKFLOW_OUTPUT_DIR`
- Parameter `MAX_RETRIES` → Environment variable `WORKFLOW_MAX_RETRIES`
```

### Step 6: Document Output File Required Field Default

**Location**: In Phase Metadata Schema section (around line 173)

**Add** to the outputs.files specification:
```markdown
- path: string        # Path where file will be created (can use parameters)
- description: string # What this file contains
- required: boolean   # Whether output must be created (default: true)
```

### Step 7: Remove Constitution References

**Search and Remove** any references to:
- "Constitutional compliance"
- "Constitution file"
- "constitution.md"
- "Constitutional alignment"

These features do not exist in this system. If found, either:
- Remove the reference entirely, OR
- Replace with "specification compliance" if contextually appropriate

### Step 8: Verify Document Coherence

After all changes:
1. Read through the document to ensure logical flow
2. Verify no dangling references
3. Check all internal links still work
4. Ensure table of contents matches actual sections

## Outputs
- Updated `$DOCS_DIR/SPECIFICATION.md`

## Success Criteria
- [ ] Minimum phase requirement clearly states "2 phase files minimum"
- [ ] Field constraints table added with lengths
- [ ] `array` type added to parameter types table
- [ ] `default_agent` removed from documentation
- [ ] Environment variable prefix convention documented
- [ ] Output file `required` default documented
- [ ] No Constitution references remain
- [ ] Document parses as valid markdown
- [ ] All internal references valid

## Error Handling
- If section not found at expected location, search for it and report actual location
- If edit would break document structure, report and skip that edit
- Keep track of which edits succeeded vs failed

## Rollback Plan
Restore `$DOCS_DIR/SPECIFICATION.md` from `$SYSTEM_ROOT/backups/pre-fix-backup-v2/docs/SPECIFICATION.md`
