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
      - path: "$PROJECT_ROOT/.claude/schemas/workflow-schema.yaml"
        description: "Fixed workflow schema (default_agent values)"
      - path: "$PROJECT_ROOT/.claude/schemas/phase-metadata-schema.yaml"
        description: "Fixed phase metadata schema (output parameter types)"
      - path: "$PROJECT_ROOT/.claude/docs/SPECIFICATION.md"
        description: "Updated specification (workflow types, parameter types)"
    parameters:
      - name: SCHEMA_FIXES_APPLIED
        description: "Number of schema-related fixes applied"
        type: integer

  preferred_agent: phase-executor
---

# Phase 2: Schema Harmonization

**Purpose**: Fix schema logical issues and harmonize type definitions across schemas and documentation.

## Prerequisites
- Phase 1 completed successfully (critical fixes applied)
- All schema and documentation files are accessible

## Tasks for Todo List
1. Fix default_agent enum to remove inappropriate values
2. Fix enum dependency logic inversion
3. Add `number` type to SPECIFICATION.md
4. Harmonize workflow types across all documents
5. Fix output parameter types to include file/directory
6. Add `required` field to output parameters schema

## Parameters Used
- `PROJECT_ROOT`: Base directory for all file operations
- `DRY_RUN`: If true, only show what would change

## Process

### Step 1: Fix default_agent Enum Values (Finding #12)

**File**: `$PROJECT_ROOT/.claude/schemas/workflow-schema.yaml`

**Location**: Lines 82-89

**Current (INCORRECT)**:
```yaml
      default_agent:
        type: string
        description: Default agent for all phases
        default: phase-executor
        enum:
          - phase-executor
          - workflow-creator
          - workflow-validator
```

**Replace with (CORRECT)**:
```yaml
      default_agent:
        type: string
        description: Default agent for executing phases. Only phase-executor is valid for phase execution.
        default: phase-executor
        enum:
          - phase-executor
```

**Rationale**: `workflow-creator` and `workflow-validator` are specialized agents for workflow generation and validation respectively, not for executing workflow phases. Only `phase-executor` should be a valid default agent.

### Step 2: Fix Enum Dependency Logic (Finding #15)

**File**: `$PROJECT_ROOT/.claude/schemas/workflow-schema.yaml`

**Location**: Lines 206-212 (in parameterObject definition)

**Current (INCORRECT)**:
```yaml
    dependencies:
      enum:
        properties:
          type:
            const: enum

    additionalProperties: false
```

**Replace with (CORRECT)**:
```yaml
    allOf:
      - if:
          properties:
            type:
              const: enum
          required:
            - type
        then:
          required:
            - enum

    additionalProperties: false
```

**Also update lines 263-269** (in parameterArray definition) with same fix:

**Current**:
```yaml
    dependencies:
      enum:
        properties:
          type:
            const: enum

    additionalProperties: false
```

**Replace with**:
```yaml
    allOf:
      - if:
          properties:
            type:
              const: enum
          required:
            - type
        then:
          required:
            - enum

    additionalProperties: false
```

**Rationale**: The original logic was inverted. It said "if `enum` field exists, `type` must be `enum`". The correct logic is "if `type` is `enum`, the `enum` array field is required".

### Step 3: Add `number` Type to SPECIFICATION.md (Finding #6)

**File**: `$PROJECT_ROOT/.claude/docs/SPECIFICATION.md`

**Location**: Line 91 (in workflow.yaml Structure section)

**Current (INCORRECT)**:
```markdown
    type: string               # string|boolean|integer|enum|file|directory
```

**Replace with (CORRECT)**:
```markdown
    type: string               # string|boolean|integer|number|enum|file|directory
```

**Also update the Parameter Types table** at lines 181-191:

**Current table**:
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
```

The table already has `number` - verify it exists. If missing, add it between `integer` and `enum`.

### Step 4: Harmonize Workflow Types (Finding #5)

**File**: `$PROJECT_ROOT/.claude/docs/SPECIFICATION.md`

**Location**: Line 108 (in metadata section)

**Current (INCOMPLETE)**:
```markdown
  workflow_type: string        # deployment|testing|migration|build|data-processing
```

**Replace with (COMPLETE)**:
```markdown
  workflow_type: string        # deployment|testing|migration|build|data-processing|requirements-processing|technical-planning|setup|automation
```

**Rationale**: Align with the full list in workflow-schema.yaml (lines 112-121).

### Step 5: Fix Output Parameter Types Asymmetry (Finding #7)

**File**: `$PROJECT_ROOT/.claude/schemas/phase-metadata-schema.yaml`

**Location**: Lines 233-241 (output parameter type enum)

**Current (ASYMMETRIC)**:
```yaml
                type:
                  type: string
                  description: Parameter type
                  enum:
                    - string
                    - boolean
                    - integer
                    - number
                    - array
```

**Replace with (SYMMETRIC)**:
```yaml
                type:
                  type: string
                  description: Parameter type
                  enum:
                    - string
                    - boolean
                    - integer
                    - number
                    - array
                    - enum
                    - file
                    - directory
```

**Rationale**: Output parameters should support the same types as input parameters for consistency. A phase might output a file path or enum value that subsequent phases need.

### Step 6: Add `required` Field to Output Parameters (Finding #17)

**File**: `$PROJECT_ROOT/.claude/schemas/phase-metadata-schema.yaml`

**Location**: Lines 212-243 (output parameters items)

**Current (MISSING required)**:
```yaml
              properties:
                name:
                  type: string
                  description: Parameter name for next phases
                  pattern: "^[A-Z][A-Z0-9_]*$"
                  ...

                description:
                  type: string
                  ...

                type:
                  type: string
                  ...
```

**Add `required` field after `name`**:
```yaml
              properties:
                name:
                  type: string
                  description: Parameter name for next phases
                  pattern: "^[A-Z][A-Z0-9_]*$"
                  examples:
                    - SPECS_COUNT
                    - VALIDATION_PASSED
                    - GENERATED_FILES

                required:
                  type: boolean
                  description: Whether this output parameter is guaranteed to be set
                  default: true

                description:
                  type: string
                  ...
```

**Rationale**: Output files have a `required` field; output parameters should too for consistency. This allows phases to declare optional output parameters.

## Outputs
- Updated workflow-schema.yaml with fixed default_agent and enum logic
- Updated phase-metadata-schema.yaml with symmetric types and required field
- Updated SPECIFICATION.md with complete type lists
- SCHEMA_FIXES_APPLIED = 6

## Success Criteria
- [ ] default_agent enum only contains `phase-executor`
- [ ] Enum dependency logic correctly requires `enum` array when `type: enum`
- [ ] SPECIFICATION.md includes `number` type in all relevant locations
- [ ] Workflow types list matches schema (9 types total)
- [ ] Output parameter types include all input parameter types
- [ ] Output parameters have optional `required` field
- [ ] All YAML files remain valid (no syntax errors)
- [ ] JSON Schema validation passes on modified schema files

## Error Handling
- **YAML syntax error**: Validate YAML after each edit, rollback if invalid
- **Schema validation fails**: Test schema against known-good workflow.yaml before committing
- **Pattern not found**: Report exact location expected and actual content found

## Rollback Plan
Restore schema files from Phase 0 backup:
```bash
cp $BACKUP_DIR/.claude/schemas/* $PROJECT_ROOT/.claude/schemas/
cp $BACKUP_DIR/.claude/docs/SPECIFICATION.md $PROJECT_ROOT/.claude/docs/
```

## Notes
- These schema fixes ensure validation works correctly
- The enum logic fix prevents invalid configurations from passing validation
- Type harmonization reduces confusion for workflow authors
