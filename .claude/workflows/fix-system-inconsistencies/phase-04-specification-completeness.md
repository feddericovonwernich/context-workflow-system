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
      - path: "$PROJECT_ROOT/.claude/docs/SPECIFICATION.md"
        description: "Updated specification with complete section requirements and clarifications"
      - path: "$PROJECT_ROOT/.claude/templates/phase-template.md"
        description: "Updated template aligned with specification"
      - path: "$PROJECT_ROOT/.claude/agents/workflow/workflow-creator.md"
        description: "Updated with clarified complexity ranges"
    parameters:
      - name: SPEC_FIXES_APPLIED
        description: "Number of specification completeness fixes applied"
        type: integer

  preferred_agent: phase-executor
---

# Phase 4: Specification Completeness

**Purpose**: Fill gaps in specifications, clarify ambiguities, and align templates with documented requirements.

## Prerequisites
- Phase 3 completed successfully (cross-references fixed)
- SPECIFICATION.md and templates accessible

## Tasks for Todo List
1. Add Rollback Plan and Notes to required phase sections
2. Fix complexity phase ranges overlap
3. Clarify phase numbering rules
4. Document prerequisites condition syntax
5. Align phase template with updated specification

## Parameters Used
- `PROJECT_ROOT`: Base directory for all file operations
- `DRY_RUN`: If true, only show what would change

## Process

### Step 1: Update Required Phase Sections (Finding #13)

**File**: `$PROJECT_ROOT/.claude/docs/SPECIFICATION.md`

**Location**: Lines 389-401 (Phase File Structure - Required sections)

**Current (INCOMPLETE)**:
```markdown
#### Phase File Structure
Required sections in order:
1. Phase metadata (YAML frontmatter)
2. `# Phase N: Title` heading
3. `**Purpose**:` statement
4. `## Prerequisites` section
5. `## Tasks for Todo List` section
6. `## Process` section with steps
7. `## Outputs` section
8. `## Success Criteria` section
9. `## Error Handling` section
```

**Replace with (COMPLETE)**:
```markdown
#### Phase File Structure
Required sections in order:
1. Phase metadata (YAML frontmatter)
2. `# Phase N: Title` heading
3. `**Purpose**:` statement
4. `## Prerequisites` section
5. `## Tasks for Todo List` section
6. `## Parameters Used` section
7. `## Process` section with steps
8. `## Outputs` section
9. `## Success Criteria` section
10. `## Error Handling` section

Optional sections (recommended for complex phases):
- `## Rollback Plan` - Recovery procedures if phase or subsequent phases fail
- `## Notes` - Additional context, warnings, or implementation notes
```

### Step 2: Fix Complexity Phase Ranges (Finding #14)

**File**: `$PROJECT_ROOT/.claude/agents/workflow/workflow-creator.md`

**Location**: Lines 68-70 (Complexity assessment section)

**Current (OVERLAPPING)**:
```markdown
2. **Complexity assessment**:
   - Simple (3-4 phases): Single objective, few dependencies
   - Medium (5-6 phases): Multiple steps, some dependencies
   - Complex (6-7 phases): Many dependencies, multiple validation points
```

**Replace with (NON-OVERLAPPING)**:
```markdown
2. **Complexity assessment**:
   - Simple (2-3 phases): Single objective, minimal dependencies
   - Medium (4-5 phases): Multiple steps, some dependencies
   - Complex (6+ phases): Many dependencies, multiple validation points, parallel opportunities
```

**Rationale**: Ranges should not overlap. 6 phases was both "Medium" and "Complex".

### Step 3: Clarify Phase Numbering Rules (Finding #16)

**File**: `$PROJECT_ROOT/.claude/docs/SPECIFICATION.md`

**Location**: Lines 74-76 (Phase Numbering section)

**Current (AMBIGUOUS)**:
```markdown
#### Phase Numbering
- **Sequential**: No gaps allowed (01, 02, 03...)
- **Starting**: Must start with 00 or 01
- **Special**: Phase 00 reserved for setup/discovery
```

**Replace with (CLEAR)**:
```markdown
#### Phase Numbering
- **Sequential**: No gaps allowed in numbering sequence
- **Starting Options**:
  - Start with `01` for workflows without setup phase
  - Start with `00` for workflows that need setup/discovery
- **Phase 00**: Reserved for setup, discovery, or parameter initialization
  - If present, must be followed by `01`, `02`, etc.
  - Optional - not all workflows need a phase 00
- **Minimum Phases**: At least two execution phases required (e.g., `01` and `02`, or `00`, `01`, and `02`)
- **Valid Examples**:
  - `phase-01-*.md`, `phase-02-*.md` (no setup phase)
  - `phase-00-*.md`, `phase-01-*.md`, `phase-02-*.md` (with setup phase)
- **Invalid Examples**:
  - `phase-01-*.md` only (needs at least two phases)
  - `phase-00-*.md`, `phase-02-*.md` (gap - missing 01)
  - `phase-01-*.md`, `phase-03-*.md` (gap - missing 02)
```

### Step 4: Document Prerequisites Condition Syntax (Finding #19)

**File**: `$PROJECT_ROOT/.claude/docs/SPECIFICATION.md`

**Location**: After line 401 (after Phase File Structure section), add new section:

**Add new section**:
```markdown
### Conditional Execution (Prerequisites)

Phase files can include conditional prerequisites that control execution flow:

```yaml
phase_metadata:
  prerequisites:
    - condition: "$ENVIRONMENT == 'production'"
      action: require_approval
    - condition: "$SKIP_TESTS == true"
      action: skip_phase
```

#### Condition Syntax

Conditions use simple expression syntax with parameter interpolation:

**Comparison Operators**:
- `==` - Equality (string or numeric)
- `!=` - Inequality
- `>`, `<`, `>=`, `<=` - Numeric comparison

**Logical Operators**:
- `&&` - Logical AND
- `||` - Logical OR
- `!` - Logical NOT (prefix)

**Parameter References**:
- `$PARAM_NAME` - Simple reference
- `${PARAM_NAME}` - Explicit boundary reference

**Literal Values**:
- Strings: `'value'` or `"value"`
- Numbers: `42`, `3.14`
- Booleans: `true`, `false`

**Examples**:
```yaml
# Single condition
condition: "$ENVIRONMENT == 'production'"

# Compound condition
condition: "$ENVIRONMENT == 'production' && $BACKUP_ENABLED == true"

# Numeric comparison
condition: "$RETRY_COUNT >= 3"

# Negation
condition: "!$SKIP_VALIDATION"
```

#### Available Actions

| Action | Description |
|--------|-------------|
| `require_approval` | Pause and ask user for confirmation before proceeding |
| `skip_phase` | Skip this phase entirely, continue with next phase |
| `fail_phase` | Immediately fail the phase with condition as reason |
| `warning` | Log a warning but continue execution |
```

### Step 5: Align Phase Template with Specification

**File**: `$PROJECT_ROOT/.claude/templates/phase-template.md`

**Changes needed**:

1. **Add `## Parameters Used` section** (missing from template but required by spec):

After the `## Tasks for Todo List` section, verify this exists:
```markdown
## Parameters Used
${PARAMETERS_LIST}
```

2. **Mark optional sections clearly**:

Update the Rollback Plan and Notes sections to indicate they are optional:

**Current**:
```markdown
## Rollback Plan
${ROLLBACK_PLAN}

## Notes
${ADDITIONAL_NOTES}
```

**Replace with**:
```markdown
## Rollback Plan
<!-- Optional: Include for phases with destructive or hard-to-reverse operations -->
${ROLLBACK_PLAN}

## Notes
<!-- Optional: Additional context, warnings, or implementation guidance -->
${ADDITIONAL_NOTES}
```

## Outputs
- Updated SPECIFICATION.md with complete section list and condition syntax
- Updated workflow-creator.md with non-overlapping complexity ranges
- Updated phase-template.md aligned with specification
- SPEC_FIXES_APPLIED = 5

## Success Criteria
- [ ] SPECIFICATION.md lists all 10 required sections plus 2 optional
- [ ] Complexity ranges in workflow-creator.md don't overlap
- [ ] Phase numbering rules are unambiguous with examples
- [ ] Prerequisites condition syntax is fully documented
- [ ] Phase template includes all required sections
- [ ] Template clearly marks optional sections

## Error Handling
- **Section not found**: Search for similar section headers, report findings
- **Conflicting content**: Preserve existing valid content, append new content
- **Template malformed**: Validate template structure after changes

## Rollback Plan
Restore from Phase 0 backup:
```bash
cp $BACKUP_DIR/.claude/docs/SPECIFICATION.md $PROJECT_ROOT/.claude/docs/
cp $BACKUP_DIR/.claude/templates/phase-template.md $PROJECT_ROOT/.claude/templates/
cp $BACKUP_DIR/.claude/agents/workflow/workflow-creator.md $PROJECT_ROOT/.claude/agents/workflow/
```

## Notes
- Clear specifications reduce implementation errors
- Condition syntax documentation enables advanced workflow patterns
- Template alignment ensures generated phases match requirements
