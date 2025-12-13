---
phase_metadata:
  inputs:
    files:
      - name: REFERENCE
        required: true
        path: "$BASE_DIR/docs/REFERENCE.md"
        description: "Quick reference documentation"
    parameters:
      - name: BASE_DIR
        required: true
        description: "Base .claude directory"
  outputs:
    files:
      - path: "$BASE_DIR/docs/REFERENCE.md"
        description: "Fixed reference"
    parameters:
      - name: REFERENCE_FIXES
        description: "Number of reference fixes"
---

# Phase 07: Fix REFERENCE.md

**Purpose**: Add runtime-parameters.yaml and execution.log to directory structure, ensure consistency with SPECIFICATION.md.

## Prerequisites
- All authoritative documents now correct

## Tasks for Todo List
1. Add generated files to directory structure
2. Verify parameter types match specification

## Process

### Fix 1: Update Directory Structure (lines 16-24)

**Current**:
```markdown
## Directory Structure
```
workflow-directory/
├── workflow.yaml          # REQUIRED: Configuration
├── phase-01-*.md         # REQUIRED: First phase
├── phase-02-*.md         # REQUIRED: Second phase
├── phase-00-*.md         # Optional: Setup phase
├── README.md             # Recommended: Documentation
└── examples/             # Optional: Examples
```
```

**Fixed**:
```markdown
## Directory Structure
```
workflow-directory/
├── workflow.yaml              # REQUIRED: Configuration
├── phase-XX-*.md             # REQUIRED: At least 2 phases
├── README.md                  # Recommended: Documentation
├── runtime-parameters.yaml    # GENERATED: Runtime state
├── execution.log              # GENERATED: Execution log
└── examples/                  # Optional: Examples
```

> **Minimum Phases**: 2 required. Can be `phase-00` + `phase-01` OR `phase-01` + `phase-02`.
```

### Fix 2: Verify Parameter Types Table Matches

Ensure the Parameter Types table (lines 115-126) includes all 8 types:

| Type | Example | Description |
|------|---------|-------------|
| `string` | `"text"` | Text value |
| `boolean` | `true` | True/false |
| `integer` | `42` | Whole number |
| `number` | `3.14` | Decimal number |
| `enum` | `"prod"` | From list |
| `file` | `"./file"` | File path |
| `directory` | `"./dir"` | Dir path |
| `array` | `["a","b"]` | List of values |

(Array should already be there - verify it exists)

## Outputs
- Updated REFERENCE.md with complete directory structure

## Success Criteria
- [ ] Directory structure shows generated files
- [ ] Minimum phase note matches SPECIFICATION.md
- [ ] All 8 parameter types listed

## Error Handling
- This is a quick reference - keep it concise
