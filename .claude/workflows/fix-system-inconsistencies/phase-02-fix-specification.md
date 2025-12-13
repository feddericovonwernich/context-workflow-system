---
phase_metadata:
  inputs:
    files:
      - name: SPECIFICATION
        required: true
        path: "$BASE_DIR/docs/SPECIFICATION.md"
        description: "Authoritative specification document"
    parameters:
      - name: BASE_DIR
        required: true
        description: "Base .claude directory"
  outputs:
    files:
      - path: "$BASE_DIR/docs/SPECIFICATION.md"
        description: "Fixed specification"
    parameters:
      - name: SPEC_FIXES
        description: "Number of specification fixes"
---

# Phase 02: Fix SPECIFICATION.md

**Purpose**: Update the authoritative specification to include all parameter types and fix inconsistencies.

## Prerequisites
- Phase 01 completed (schemas fixed)

## Tasks for Todo List
1. Add `array` to parameter types table
2. Verify parameter type list matches schema

## Process

### Fix 1: Add `array` Type to Parameter Types Section

Locate the Parameter Types table (around line 241-252) and add the `array` type:

**Add this row to the table**:
```markdown
| `array` | `["a", "b", "c"]` | Valid JSON/YAML array |
```

### Fix 2: Update Parameter Type List in workflow.yaml Structure

Locate line ~108 where parameter types are listed:

**Current**:
```yaml
type: string               # string|boolean|integer|number|enum|file|directory
```

**Fixed**:
```yaml
type: string               # string|boolean|integer|number|enum|file|directory|array
```

## Outputs
- Updated SPECIFICATION.md with complete type definitions

## Success Criteria
- [ ] Parameter types table includes `array` with example and description
- [ ] Inline type comment includes `array`

## Error Handling
- Preserve all existing content; only add/modify the specific sections identified
