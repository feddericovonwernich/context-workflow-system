---
phase_metadata:
  execution_mode: sequential
  inputs:
    files:
      - name: PHASE_TEMPLATE_FILE
        required: true
        path: "$TEMPLATES_DIR/phase-template.md"
        description: "The phase template file"
    parameters:
      - name: TEMPLATES_DIR
        required: true
        description: "Templates directory"
      - name: DRY_RUN
        required: false
        default: false
        description: "If true, only report without making changes"
      - name: AGENT_PROMPTS_OPTIMIZED
        required: true
        description: "Confirms agent prompts phase completed"
  outputs:
    files:
      - path: "$TEMPLATES_DIR/phase-template.md"
        description: "Updated phase template with clarified placeholders"
    parameters:
      - name: TEMPLATE_FIXES_APPLIED
        description: "Number of template fixes applied"
---

# Phase 8: Template Fixes

**Purpose**: Update the phase template to clarify the distinction between template placeholders (for workflow-creator to fill) and runtime parameter interpolation syntax (resolved during execution).

## Prerequisites
- Agent prompts optimized (AGENT_PROMPTS_OPTIMIZED confirmed)
- Write access to $TEMPLATES_DIR

## Tasks for Todo List
1. Read current phase-template.md
2. Add clarifying comment about placeholder types
3. Distinguish template vars from runtime params
4. Verify template structure matches current spec
5. Add example showing both placeholder types

## Parameters Used
- `TEMPLATES_DIR`: Location of template files
- `DRY_RUN`: Whether to apply changes or just report
- `AGENT_PROMPTS_OPTIMIZED`: Confirms safe to proceed

## Process

### Step 1: Add Clarifying Header Comment

**Location**: At the very top of the file, before the YAML frontmatter

**Add**:
```markdown
<!--
PHASE TEMPLATE
==============
This template is used by workflow-creator to generate new phase files.

PLACEHOLDER TYPES:
1. Template Placeholders: ${VARIABLE_NAME} - Replaced by workflow-creator during generation
   Examples: ${PHASE_NUMBER}, ${PHASE_NAME}, ${INPUT_FILE_PARAM}

2. Runtime Parameters: $PARAM_NAME or ${PARAM_NAME} - Resolved during workflow execution
   Examples: $OUTPUT_DIR, $SPECS_DIR, ${FEATURE_FILE}

The workflow-creator replaces template placeholders with actual values.
Runtime parameters remain as $PARAM references in the generated phase file.
-->
```

### Step 2: Update Metadata Section Comments

**Location**: Lines 2-42 (phase_metadata section)

**Current** uses `${VARIABLE}` for all placeholders. Add inline comments to distinguish:

```yaml
---
phase_metadata:
  execution_mode: sequential

  inputs:
    files:
      # Template placeholder: workflow-creator fills this during generation
      - name: ${INPUT_FILE_PARAM}  # e.g., becomes "FEATURE_SPEC"
        required: true
        # Runtime parameter: resolved during execution
        path: "$OUTPUT_DIR/input.md"  # Uses $OUTPUT_DIR at runtime
        description: "${INPUT_FILE_DESC}"

    parameters:
      - name: ${INPUT_PARAM}  # Template placeholder
        required: true
        default: ${DEFAULT_VALUE}  # Template placeholder
        description: "${INPUT_PARAM_DESC}"

  outputs:
    files:
      # Runtime parameter in path - resolved during execution
      - path: "$OUTPUT_DIR/${OUTPUT_SUBDIR}/result.md"
        description: "${OUTPUT_FILE_DESC}"  # Template placeholder

    parameters:
      - name: ${OUTPUT_PARAM}  # Template placeholder
        description: "${OUTPUT_PARAM_DESC}"
---
```

### Step 3: Add Concrete Example Section

**Location**: At the end of the template file

**Add**:
```markdown
<!--
EXAMPLE: After workflow-creator processes this template

Template placeholders get replaced:
- ${PHASE_NUMBER} → "01"
- ${PHASE_NAME} → "Data Extraction"
- ${INPUT_FILE_PARAM} → "SOURCE_FILE"

Runtime parameters remain as references:
- $OUTPUT_DIR → stays as "$OUTPUT_DIR" (resolved at runtime)
- $SPECS_DIR → stays as "$SPECS_DIR" (resolved at runtime)

The generated phase file might look like:
```yaml
phase_metadata:
  inputs:
    files:
      - name: SOURCE_FILE
        path: "$OUTPUT_DIR/source.md"
```

When the workflow runs, $OUTPUT_DIR gets resolved to the actual path.
-->
```

### Step 4: Verify Required Sections Present

Confirm the template includes all required sections per SPECIFICATION.md:

1. `# Phase ${PHASE_NUMBER}: ${PHASE_NAME}` - Heading
2. `**Purpose**: ${PHASE_PURPOSE}` - Purpose statement
3. `## Prerequisites` - Prerequisites section
4. `## Tasks for Todo List` - Tasks section
5. `## Parameters Used` - Parameters section
6. `## Process` - Process section
7. `## Outputs` - Outputs section
8. `## Success Criteria` - Success criteria section
9. `## Error Handling` - Error handling section

Optional sections (verify present):
10. `## Rollback Plan` - Optional
11. `## Notes` - Optional

### Step 5: Ensure Consistent Placeholder Syntax

Verify all template placeholders follow the same pattern:
- Use `${VARIABLE}` for multi-word placeholders to fill
- Examples: `${PHASE_NAME}`, `${INPUT_FILE_DESC}`, `${PROCESS_STEPS}`

Runtime parameters should use:
- `$PARAM` or `${PARAM}` for values resolved at execution time
- Examples: `$OUTPUT_DIR`, `$FEATURE_FILE`

### Step 6: Add Type Hints in Placeholder Names

Where helpful, update placeholder names to indicate expected content type:

| Current | Clearer Alternative |
|---------|---------------------|
| `${PREREQUISITES_LIST}` | `${PREREQUISITES_MARKDOWN_LIST}` |
| `${TASKS_LIST}` | `${TASKS_NUMBERED_LIST}` |
| `${SUCCESS_CRITERIA}` | `${SUCCESS_CRITERIA_CHECKLIST}` |

**Decision**: Keep current names for brevity, but add comment hints:
```markdown
## Prerequisites
${PREREQUISITES_LIST}
<!-- Format: Markdown bullet list of prerequisite conditions -->
```

## Outputs
- Updated `$TEMPLATES_DIR/phase-template.md`

## Success Criteria
- [ ] Clarifying header comment added distinguishing placeholder types
- [ ] Inline comments added to metadata section
- [ ] Concrete example added at end of file
- [ ] All required sections present per SPECIFICATION.md
- [ ] Placeholder syntax consistent throughout
- [ ] Template parses as valid markdown (ignoring HTML comments)

## Error Handling
- If template structure has changed significantly, adapt changes accordingly
- Preserve any custom additions while adding clarifications
- Report if template is missing expected sections

## Rollback Plan
Restore `$TEMPLATES_DIR/phase-template.md` from `$SYSTEM_ROOT/backups/pre-fix-backup-v2/templates/phase-template.md`

## Notes
This phase addresses a subtle but important usability issue. Users generating workflows need to understand which `${VARIABLES}` are for the workflow-creator to fill versus which `$PARAMS` remain in the generated output for runtime resolution.
