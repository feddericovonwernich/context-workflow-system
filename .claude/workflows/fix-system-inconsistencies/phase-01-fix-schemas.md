---
phase_metadata:
  inputs:
    files:
      - name: WORKFLOW_SCHEMA
        required: true
        path: "$BASE_DIR/schemas/workflow-schema.yaml"
        description: "Workflow configuration schema"
      - name: PHASE_SCHEMA
        required: true
        path: "$BASE_DIR/schemas/phase-metadata-schema.yaml"
        description: "Phase metadata schema"
    parameters:
      - name: BASE_DIR
        required: true
        description: "Base .claude directory"
  outputs:
    files:
      - path: "$BASE_DIR/schemas/workflow-schema.yaml"
        description: "Fixed workflow schema"
      - path: "$BASE_DIR/schemas/phase-metadata-schema.yaml"
        description: "Fixed phase metadata schema"
    parameters:
      - name: SCHEMAS_FIXED
        description: "Number of schema fixes applied"
---

# Phase 01: Fix Schema Inconsistencies

**Purpose**: Resolve internal schema inconsistencies and missing type definitions.

## Prerequisites
- Schema files exist and are valid YAML

## Tasks for Todo List
1. Add missing `array` type to phase-metadata-schema.yaml input parameters
2. Verify both schemas have consistent type enums

## Process

### Fix 1: phase-metadata-schema.yaml - Add `array` to Input Parameter Types

In `phase-metadata-schema.yaml`, locate the input parameters type enum (around line 155-166) and add `array`:

**Current** (inputs.parameters.type):
```yaml
type:
  enum:
    - string
    - boolean
    - integer
    - number
    - enum
    - file
    - directory
```

**Fixed**:
```yaml
type:
  enum:
    - string
    - boolean
    - integer
    - number
    - enum
    - file
    - directory
    - array
```

This aligns input parameters with output parameters which already includes `array`.

## Outputs
- Updated phase-metadata-schema.yaml with consistent type enums

## Success Criteria
- [ ] Input parameters type enum includes `array`
- [ ] Input and output parameter type enums match

## Error Handling
- If schema file is malformed, report the YAML error and stop
