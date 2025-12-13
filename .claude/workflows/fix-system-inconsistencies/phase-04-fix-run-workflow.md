---
phase_metadata:
  inputs:
    files:
      - name: RUN_WORKFLOW
        required: true
        path: "$BASE_DIR/commands/run-workflow.md"
        description: "Run workflow command documentation"
    parameters:
      - name: BASE_DIR
        required: true
        description: "Base .claude directory"
  outputs:
    files:
      - path: "$BASE_DIR/commands/run-workflow.md"
        description: "Fixed run-workflow command"
    parameters:
      - name: RUN_FIXES
        description: "Number of run-workflow fixes"
---

# Phase 04: Fix run-workflow.md

**Purpose**: Fix minimum phase requirements, add environment variable documentation, and correct Task tool examples.

## Prerequisites
- Specification fixes complete

## Tasks for Todo List
1. Fix minimum phase requirements to allow phase-00 + phase-01
2. Add environment variable resolution to Parameter Resolution section
3. Add note that Python Task examples are pseudocode

## Process

### Fix 1: Correct Required Files Section (lines 44-55)

**Current**:
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

**Fixed**:
```markdown
### Required Files
Each workflow directory must contain:
```
workflow-directory/
├── workflow.yaml           # Workflow metadata and parameter definitions
├── phase-XX-*.md          # At least 2 phase files (see note below)
```

> **Minimum Phases**: A workflow requires at least 2 phase files. Valid configurations:
> - `phase-01-*.md` + `phase-02-*.md` (standard)
> - `phase-00-*.md` + `phase-01-*.md` (with setup phase)
```

### Fix 2: Add Environment Variables to Parameter Resolution (after line 223)

Add this section after "Check command-line arguments":

```markdown
3. Check environment variables:
   - Parameters can be set via environment variables with `WORKFLOW_` prefix
   - Example: `WORKFLOW_OUTPUT_DIR` sets the `OUTPUT_DIR` parameter
   - Environment variables take precedence over defaults but not CLI args
```

### Fix 3: Add Pseudocode Note to Task Examples (around line 335)

Before the Python-style Task examples, add:

```markdown
> **Note**: The following examples use pseudocode syntax to illustrate the Task tool invocation pattern. The actual Claude Code tool call syntax differs.
```

## Outputs
- Updated run-workflow.md with correct requirements and documentation

## Success Criteria
- [ ] Minimum phase requirements match SPECIFICATION.md
- [ ] Environment variable resolution is documented
- [ ] Task examples have pseudocode disclaimer

## Error Handling
- Search for exact text if line numbers have shifted
