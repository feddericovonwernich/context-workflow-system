---
phase_metadata:
  execution_mode: sequential
  inputs:
    files:
      - name: WORKFLOW_CREATOR_FILE
        required: true
        path: "$AGENTS_DIR/workflow-creator.md"
        description: "The workflow-creator agent prompt"
      - name: PHASE_EXECUTOR_FILE
        required: true
        path: "$AGENTS_DIR/phase-executor.md"
        description: "The phase-executor agent prompt"
      - name: WORKFLOW_VALIDATOR_FILE
        required: true
        path: "$AGENTS_DIR/workflow-validator.md"
        description: "The workflow-validator agent prompt"
    parameters:
      - name: AGENTS_DIR
        required: true
        description: "Agent prompts directory"
      - name: DRY_RUN
        required: false
        default: false
        description: "If true, only report without making changes"
      - name: COMMAND_DOCS_FIXES_APPLIED
        required: true
        description: "Confirms command docs phase completed"
  outputs:
    files:
      - path: "$AGENTS_DIR/workflow-creator.md"
        description: "Optimized workflow-creator agent prompt"
      - path: "$AGENTS_DIR/phase-executor.md"
        description: "Fixed phase-executor agent prompt"
      - path: "$AGENTS_DIR/workflow-validator.md"
        description: "Enhanced workflow-validator agent prompt"
    parameters:
      - name: AGENT_PROMPTS_OPTIMIZED
        description: "Number of agent prompt optimizations applied"
---

# Phase 7: Agent Prompt Optimization

**Purpose**: Optimize agent prompts for effectiveness and efficiency by removing redundancy, fixing conflicting instructions, adding explicit schema references, and reducing unnecessary length.

## Prerequisites
- Command docs fixes completed (COMMAND_DOCS_FIXES_APPLIED confirmed)
- Write access to $AGENTS_DIR

## Tasks for Todo List
1. Read and analyze workflow-creator.md (470 lines - too long)
2. Read and analyze phase-executor.md
3. Read and analyze workflow-validator.md
4. Fix workflow-creator.md redundancy and length
5. Fix phase-executor.md conflicting instructions
6. Add explicit schema references to workflow-validator.md
7. Simplify ASCII art in workflow-validator.md
8. Align phase count guidance in workflow-creator.md
9. Verify all prompts are internally consistent

## Parameters Used
- `AGENTS_DIR`: Location of agent prompt files
- `DRY_RUN`: Whether to apply changes or just report
- `COMMAND_DOCS_FIXES_APPLIED`: Confirms safe to proceed

## Process

### Step 1: Fix workflow-creator.md Redundancy

**Issue**: The prompt is 470 lines with significant redundancy. Target is <350 lines.

#### 1a. Consolidate "No Nested Agents" References

The constraint about no nested agents appears 5+ times. Consolidate to 2 strategic locations:

1. **Keep**: The "CRITICAL CONSTRAINT" section near the top (lines 29-33)
2. **Keep**: The "Patterns to Avoid" section (lines 391-413)
3. **Remove/Simplify**: Other repetitive mentions

Specifically, reduce these redundant mentions:
- Line 15: "Constraint | Phases execute directly - NO agent delegation" → Keep (Quick Reference)
- Line 225: "Design all phases to execute work directly" → Simplify to reference the critical constraint section

#### 1b. Consolidate Quality Standards and Generation Guidelines

**Lines 270-294** (Quality Standards) and **Lines 354-389** (Generation Guidelines) have overlapping content.

**Merge into one section** called "Quality Standards":
```markdown
## Quality Standards

### Workflow Requirements
- Clear objective and description
- 2-7 well-defined phases (simple: 2-3, medium: 4-5, complex: 6+)
- Complete parameter definitions
- Error handling in each phase
- Validation/verification phase

### Phase Requirements
- 5-10 specific tasks per phase
- Clear prerequisites
- Detailed process steps
- Success criteria
- Error handling section
- Output artifacts defined

### Documentation Requirements
- README with usage examples
- Parameter descriptions with types
- Troubleshooting guidance
```

Remove the separate "Generation Guidelines" section or merge key unique points into Quality Standards.

#### 1c. Fix Phase Count Inconsistency

**Issue**: Quick Reference says "3-7" but earlier text varies.

**Location**: Line 11 (Quick Reference) and line 275-276 (Quality Standards)

**Harmonize To**:
- Quick Reference: "Simple: 2-3, Medium: 4-5, Complex: 6+"
- Quality Standards: "2-7 well-defined phases"

Both now align on the range 2-7 with complexity breakdown.

#### 1d. Consider Externalizing Examples

**Lines 311-352** contain detailed examples. These could be:
1. Shortened to brief summaries
2. Referenced to external documentation

**Recommendation**: Keep examples but shorten each to 5-6 lines maximum instead of 10+ lines.

### Step 2: Fix phase-executor.md Conflicting Instructions

**Issue**: Line 49 says to "Update runtime-parameters.yaml" but line 148 correctly says "The orchestrator handles file updates."

**Location**: Line 49

**Current Text**:
```markdown
- Update runtime-parameters.yaml if new parameters are discovered
```

**Change To**:
```markdown
- Report discovered parameters in your completion report (orchestrator handles file updates)
```

**Also verify** line 148 text remains:
```markdown
**Your Role**: Report discovered parameters in your completion report. The orchestrator handles file updates.
```

### Step 3: Remove Completion Report Format Redundancy in phase-executor.md

**Issue**: The completion report format is explained twice (prose description + full YAML example).

**Location**: Lines 186-235

**Keep**: The full YAML example block (lines 190-219)
**Simplify**: The prose explanation before it

**Change** the section to:
```markdown
## Completion Report

At the end of execution, output a structured completion report in this exact YAML format:

```yaml
---
phase_completion:
  status: SUCCESS  # or FAILURE

  outputs_created:
    - path: "/absolute/path/to/output1.md"
      exists: true

  parameters_discovered:
    PARAM_NAME: "value"

  success_criteria:
    - criterion: "Description"
      met: true

  errors: []  # List of error messages if FAILURE

  notes:
    - "Optional observations"

  duration_seconds: 45
---
```

The orchestrator parses this to verify outputs, extract parameters, and log results.
```

This removes the redundant field-by-field explanation (lines 221-228).

### Step 4: Add Explicit Schema References to workflow-validator.md

**Issue**: The validator should explicitly reference the schema files for validation.

**Location**: Near the beginning, after "Validation Standards" section (around line 14)

**Enhance To**:
```markdown
## Validation Standards

All validation must be performed according to:
- **Specification**: `.claude/docs/SPECIFICATION.md` - Authoritative rules and requirements
- **Workflow Schema**: `.claude/schemas/workflow-schema.yaml` - workflow.yaml validation
- **Phase Schema**: `.claude/schemas/phase-metadata-schema.yaml` - Phase metadata validation

**Important**: Read and parse these schema files to validate:
1. workflow.yaml structure against workflow-schema.yaml
2. Phase metadata sections against phase-metadata-schema.yaml
3. Parameter types match schema-defined enums
4. Required fields are present per schema requirements
```

### Step 5: Simplify ASCII Art in workflow-validator.md

**Issue**: Lines 164-187 have elaborate ASCII box borders that add length without functionality.

**Location**: Lines 164-187 (Report Format Structure)

**Current**:
```markdown
```
╔════════════════════════════════════════════════════════════╗
║           WORKFLOW VALIDATION REPORT                        ║
╚════════════════════════════════════════════════════════════╝

Workflow: [name]
Version: [version]
...
```
```

**Simplify To**:
```markdown
```
=== WORKFLOW VALIDATION REPORT ===

Workflow: [name]
Version: [version]
Path: [workflow-dir]

--- SUMMARY ---
Status: [VALID | WARNINGS | INVALID]
Checks: [passed]/[total] ([percentage]%)

--- DETAILS ---
[Categorized findings]
```
```

This reduces visual complexity while maintaining clarity.

### Step 6: Fix workflow-validator.md Minimum Phase Check

**Issue**: Line 35 says "At least one phase-*.md file exists" but should be "at least two".

**Location**: Line 35

**Current Text**:
```markdown
- At least one phase-*.md file exists
```

**Change To**:
```markdown
- At least two phase-*.md files exist (minimum workflow requirement)
```

### Step 7: Verify Agent Frontmatter Consistency

All three agent files should have consistent frontmatter:

```yaml
---
name: <agent-name>
description: <description>
model: sonnet
---
```

Verify all three have this structure.

### Step 8: Final Review for Internal Consistency

After all changes, verify each agent prompt:
1. Does not contradict itself
2. References correct file paths
3. Uses consistent terminology
4. Has no orphaned references

## Outputs
- Optimized `$AGENTS_DIR/workflow-creator.md` (target: <350 lines)
- Fixed `$AGENTS_DIR/phase-executor.md`
- Enhanced `$AGENTS_DIR/workflow-validator.md`

## Success Criteria
- [ ] workflow-creator.md reduced to <350 lines
- [ ] "No nested agents" consolidated to 2 locations in workflow-creator.md
- [ ] Phase count guidance consistent (2-7 range)
- [ ] phase-executor.md line 49 conflict resolved
- [ ] phase-executor.md completion report not duplicated
- [ ] workflow-validator.md has explicit schema references
- [ ] workflow-validator.md ASCII art simplified
- [ ] workflow-validator.md minimum phases says "two"
- [ ] All frontmatter consistent
- [ ] All prompts parse as valid markdown

## Error Handling
- If line numbers have shifted, search for content by text
- Track original line count vs final line count
- Report any changes that couldn't be applied

## Rollback Plan
Restore files from:
- `$SYSTEM_ROOT/backups/pre-fix-backup-v2/agents/workflow/workflow-creator.md`
- `$SYSTEM_ROOT/backups/pre-fix-backup-v2/agents/workflow/phase-executor.md`
- `$SYSTEM_ROOT/backups/pre-fix-backup-v2/agents/workflow/workflow-validator.md`

## Notes
The workflow-creator.md optimization is the most impactful change. A 470-line prompt risks context dilution and reduced effectiveness. Target <350 lines while preserving all essential guidance.
