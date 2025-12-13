---
phase_metadata:
  inputs:
    files:
      - name: VALIDATOR_AGENT
        required: true
        path: "$BASE_DIR/agents/workflow/workflow-validator.md"
        description: "Workflow validator agent prompt"
    parameters:
      - name: BASE_DIR
        required: true
        description: "Base .claude directory"
  outputs:
    files:
      - path: "$BASE_DIR/agents/workflow/workflow-validator.md"
        description: "Fixed validator agent"
    parameters:
      - name: VALIDATOR_FIXES
        description: "Number of validator fixes"
---

# Phase 03: Fix Workflow Validator Agent

**Purpose**: Correct the validator agent's hardcoded parameter type list and remove dead references.

## Prerequisites
- Specification is now authoritative and correct

## Tasks for Todo List
1. Fix parameter type enum list
2. Remove "Constitution files" reference

## Process

### Fix 1: Correct Parameter Types (lines 74-79)

**Current**:
```markdown
Each parameter must have:
- name: string (valid identifier)
- type: enum [string, boolean, integer, enum, file, directory]
```

**Fixed**:
```markdown
Each parameter must have:
- name: string (valid identifier)
- type: enum [string, boolean, integer, number, enum, file, directory, array]
```

Note: Added `number` and `array` which were missing.

### Fix 2: Remove Constitution Files Reference (line 159)

**Current**:
```markdown
- Constitution files exist
```

**Fixed**: Remove this line entirely - no constitution files exist in this system.

## Outputs
- Updated workflow-validator.md with correct validation rules

## Success Criteria
- [ ] Parameter type list includes all 8 types
- [ ] No reference to "constitution files"

## Error Handling
- If lines have shifted, search for the exact text content to locate fixes
