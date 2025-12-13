---
phase_metadata:
  execution_mode: sequential
  inputs:
    parameters:
      - name: SCHEMAS_DIR
        required: true
        description: "Directory containing schema files"
      - name: DRY_RUN
        required: false
        default: false
        description: "If true, only report without making changes"
      - name: BACKUP_CREATED
        required: true
        description: "Confirmation that backup exists"
  outputs:
    files:
      - path: "$SCHEMAS_DIR/workflow-schema.yaml"
        description: "Updated workflow schema"
      - path: "$SCHEMAS_DIR/phase-metadata-schema.yaml"
        description: "Verified phase metadata schema"
    parameters:
      - name: SCHEMA_FIXES_APPLIED
        description: "Number of schema fixes applied"
---

# Phase 1: Schema Fixes

**Purpose**: Fix inconsistencies in the JSON schema files to ensure internal consistency and alignment with documented behavior.

## Prerequisites
- Backup completed (BACKUP_CREATED = true)
- Write access to $SCHEMAS_DIR

## Tasks for Todo List
1. Read current workflow-schema.yaml
2. Add `array` type to output parameter definitions
3. Remove or repurpose default_agent field
4. Verify phase-metadata-schema.yaml consistency
5. Validate YAML syntax after changes
6. Document all changes made

## Parameters Used
- `SCHEMAS_DIR`: Location of schema files
- `DRY_RUN`: Whether to apply changes or just report
- `BACKUP_CREATED`: Confirms safe to proceed

## Process

### Step 1: Fix workflow-schema.yaml - Add `array` Type

**Issue**: Output parameters can be arrays (e.g., list of files), but `array` is missing from workflow-schema.yaml while present in phase-metadata-schema.yaml.

**Location**: `workflow-schema.yaml` lines 156-166 (parameterObject) and 230-240 (parameterArray)

**Change**: Add `array` to the type enum in both parameter definitions:

```yaml
type:
  type: string
  enum:
    - string
    - boolean
    - integer
    - number
    - enum
    - file
    - directory
    - array  # ADD THIS
  description: Parameter data type
```

Apply this change to BOTH:
1. `definitions.parameterObject.properties.type.enum` (around line 158)
2. `definitions.parameterArray.properties.type.enum` (around line 232)

### Step 2: Fix workflow-schema.yaml - Remove default_agent Field

**Issue**: The `default_agent` field has `enum: [phase-executor]` with only ONE option, making it pointless.

**Location**: `workflow-schema.yaml` lines 83-88

**Change**: Remove the entire `default_agent` property from the `phases` object:

```yaml
# REMOVE THIS ENTIRE BLOCK:
default_agent:
  type: string
  description: Default agent for executing phases. Only phase-executor is valid for phase execution.
  default: phase-executor
  enum:
    - phase-executor
```

**Rationale**:
- The field provides no value with a single-option enum
- Agent selection is handled by phase metadata's `preferred_agent` or `parallel_config.agent_type`
- Removing reduces schema complexity

### Step 3: Verify phase-metadata-schema.yaml

Read and verify `phase-metadata-schema.yaml` has:
1. `array` type in output parameters (line 247) - should already exist
2. Consistent structure with workflow-schema.yaml after our changes

**Expected**: No changes needed to phase-metadata-schema.yaml (it's the more complete one)

### Step 4: Validate YAML Syntax

After making changes, verify:
1. YAML parses without errors
2. JSON Schema structure is valid
3. No broken references

If DRY_RUN is true, report what changes WOULD be made without applying them.

### Step 5: Document Changes

Create a change summary:
```
Schema Changes Applied:
1. workflow-schema.yaml: Added 'array' to parameterObject.type.enum
2. workflow-schema.yaml: Added 'array' to parameterArray.type.enum
3. workflow-schema.yaml: Removed 'default_agent' from phases properties
```

## Outputs
- Updated `$SCHEMAS_DIR/workflow-schema.yaml`
- Unchanged `$SCHEMAS_DIR/phase-metadata-schema.yaml` (verified consistent)

## Success Criteria
- [ ] `array` type present in workflow-schema.yaml parameterObject
- [ ] `array` type present in workflow-schema.yaml parameterArray
- [ ] `default_agent` field removed from workflow-schema.yaml
- [ ] Both schema files parse as valid YAML
- [ ] No broken internal references in schemas

## Error Handling
- If YAML syntax error after edit, restore from backup and report issue
- If schema validation fails, report specific validation error
- If file not writable, report permission issue

## Rollback Plan
Restore `$SCHEMAS_DIR/workflow-schema.yaml` from `$SYSTEM_ROOT/backups/pre-fix-backup-v2/schemas/workflow-schema.yaml`
