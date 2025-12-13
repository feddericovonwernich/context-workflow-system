---
phase_metadata:
  inputs:
    files:
      - name: INTRODUCTION
        required: true
        path: "$BASE_DIR/docs/INTRODUCTION.md"
        description: "Introduction documentation"
    parameters:
      - name: BASE_DIR
        required: true
        description: "Base .claude directory"
  outputs:
    files:
      - path: "$BASE_DIR/docs/INTRODUCTION.md"
        description: "Fixed introduction"
    parameters:
      - name: INTRO_FIXES
        description: "Number of introduction fixes"
---

# Phase 05: Fix INTRODUCTION.md

**Purpose**: Remove undocumented `--params` flag and add execution.log to directory structure.

## Prerequisites
- Core specification is now correct

## Tasks for Todo List
1. Remove or fix `--params` flag example
2. Add execution.log to directory structure

## Process

### Fix 1: Fix --params Flag Example (line 88)

**Current**:
```bash
# Use example parameters directly
run-workflow .claude/workflows/my-workflow --params examples/parameters.yaml
```

**Fixed** (update to match actual command syntax):
```bash
# Run workflow with explicit parameters
run-workflow .claude/workflows/my-workflow --OUTPUT_DIR=./outputs
```

Or add a note that --params is a planned feature:
```markdown
> **Note**: Direct parameter file loading (`--params`) is planned for a future release.
```

### Fix 2: Add execution.log to Directory Structure (around line 682)

In the workflow directory structure, ensure `execution.log` is listed:

```markdown
└── workflows/
    └── <workflow-name>/
        ├── workflow.yaml
        ├── README.md
        ├── phase-*.md
        ├── runtime-parameters.yaml  # GENERATED
        ├── execution.log            # GENERATED
        └── examples/
```

## Outputs
- Updated INTRODUCTION.md with correct examples

## Success Criteria
- [ ] No undocumented --params flag usage
- [ ] execution.log shown in directory structure

## Error Handling
- Preserve document structure and formatting
