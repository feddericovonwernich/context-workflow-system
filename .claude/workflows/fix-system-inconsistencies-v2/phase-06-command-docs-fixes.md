---
phase_metadata:
  execution_mode: sequential
  inputs:
    files:
      - name: CREATE_WORKFLOW_FILE
        required: true
        path: "$COMMANDS_DIR/create-workflow.md"
        description: "The create-workflow command documentation"
      - name: VALIDATE_WORKFLOW_FILE
        required: true
        path: "$COMMANDS_DIR/validate-workflow.md"
        description: "The validate-workflow command documentation"
    parameters:
      - name: COMMANDS_DIR
        required: true
        description: "Commands directory"
      - name: DRY_RUN
        required: false
        default: false
        description: "If true, only report without making changes"
      - name: RUN_WORKFLOW_FIXES_APPLIED
        required: true
        description: "Confirms run-workflow phase completed"
  outputs:
    files:
      - path: "$COMMANDS_DIR/create-workflow.md"
        description: "Updated create-workflow command documentation"
      - path: "$COMMANDS_DIR/validate-workflow.md"
        description: "Updated validate-workflow command documentation"
    parameters:
      - name: COMMAND_DOCS_FIXES_APPLIED
        description: "Number of command docs fixes applied"
---

# Phase 6: Command Documentation Fixes

**Purpose**: Fix the create-workflow.md and validate-workflow.md command documentation to clarify they are slash commands (not bash commands with CLI flags), add missing workflow types, and remove Constitution references.

## Prerequisites
- run-workflow fixes completed (RUN_WORKFLOW_FIXES_APPLIED confirmed)
- Write access to $COMMANDS_DIR

## Tasks for Todo List
1. Read current create-workflow.md
2. Read current validate-workflow.md
3. Clarify slash command nature in both files
4. Fix CLI options documentation in validate-workflow.md
5. Add missing workflow types to create-workflow.md table
6. Remove Constitution references from both files
7. Verify consistency with other documentation

## Parameters Used
- `COMMANDS_DIR`: Location of command files
- `DRY_RUN`: Whether to apply changes or just report
- `RUN_WORKFLOW_FIXES_APPLIED`: Confirms safe to proceed

## Process

### Step 1: Fix validate-workflow.md CLI Options

**Issue**: validate-workflow.md documents CLI options like `--strict-mode`, `--check-templates`, `--output-format` but these aren't real CLI flags - this is a slash command that launches an agent.

**Location**: Lines 29-31

**Current Text**:
```markdown
**Options:**
- `--strict-mode`: Treat warnings as errors (default: false)
- `--check-templates`: Verify template references (default: true)
- `--output-format`: Report format: detailed|summary|json (default: detailed)
```

**Change To**:
```markdown
**Arguments:**
- `WORKFLOW_DIR`: Path to workflow directory to validate

**Validation Modes** (specified in the prompt):
- Request strict validation: Include "strict mode" or "treat warnings as errors" in your request
- Request summary only: Ask for "summary" or "quick check"
- Request JSON output: Ask for "JSON format" for CI/CD integration

> **Note**: This is a slash command that launches the workflow-validator agent. Options are communicated through natural language in your request, not as CLI flags.
```

### Step 2: Fix create-workflow.md Slash Command Clarification

**Location**: Around line 21 (Usage section)

**Current Text**:
```markdown
## Usage

```bash
create-workflow <input-files...> --name <workflow-name> [--type <workflow-type>]
```
```

**Add Note After**:
```markdown
> **Note**: This is a slash command that launches the workflow-creator agent. Arguments are passed naturally - for example: `/create-workflow spec.md requirements.md --name my-workflow`
```

### Step 3: Add Missing Workflow Types to create-workflow.md

**Location**: Around line 130 (Workflow Type Detection table)

**Current Table**:
```markdown
| Content Patterns | Detected Type | Typical Phases |
|-----------------|---------------|----------------|
| deploy, release, rollout | deployment | setup → prepare → backup → deploy → validate |
| test, verify, quality | testing | setup → unit → integration → e2e → report |
| migrate, upgrade, transform | migration | analyze → backup → migrate → validate → cleanup |
| build, compile, package | build | setup → compile → test → package → publish |
| process, ETL, analyze | data-processing | ingest → validate → transform → process → output |
```

**Add Missing Types**:
```markdown
| requirements, features, specs | requirements-processing | extract → analyze → structure → validate → output |
| design, architecture, plan | technical-planning | research → design → document → review → finalize |
| install, configure, initialize | setup | discover → validate → configure → verify → document |
| automate, schedule, orchestrate | automation | define → configure → test → deploy → monitor |
```

### Step 4: Remove Constitution References from validate-workflow.md

**Location**: Multiple places

**Search and Remove/Replace**:

1. Line 17-18:
```markdown
- Constitutional compliance
```
**Change To**:
```markdown
- Specification compliance
```

2. Lines 88-93 (Quality Checks section):
```markdown
### Quality Checks
- Constitutional compliance
- Best practices followed
```
**Change To**:
```markdown
### Quality Checks
- SPECIFICATION.md compliance
- Best practices followed
```

3. Line 264:
```markdown
- Constitutional compliance
```
**Change To**:
```markdown
- Specification compliance
```

### Step 5: Remove Constitution References from create-workflow.md

**Search** for any "constitution" or "Constitutional" references and remove or replace with "specification".

### Step 6: Fix validate-workflow.md Examples

**Location**: Lines 35-66 (Examples section)

The examples show bash-style command invocations. Clarify these are slash command invocations:

**Current**:
```bash
# Validate a workflow with detailed report
validate-workflow .claude/workflows/technical-planning
```

**Change To**:
```markdown
# Validate a workflow with detailed report
/validate-workflow .claude/workflows/technical-planning
```

Apply the same `/` prefix fix to all examples in the section.

### Step 7: Fix create-workflow.md Examples

**Location**: Lines 29-86 (Examples section)

Similarly, ensure examples show slash command format:

**Current**:
```bash
# Generate a development workflow from a feature spec
create-workflow outputs/specs/SPEC-001-pr-fetching/feature-spec.md \
  --name pr-fetching-implementation
```

**Change To**:
```markdown
# Generate a development workflow from a feature spec
/create-workflow outputs/specs/SPEC-001-pr-fetching/feature-spec.md --name pr-fetching-implementation
```

### Step 8: Verify See Also Sections

Both files have "See Also" or integration sections. Verify they reference:
- Correct file paths
- Updated documentation (SPECIFICATION.md, INTRODUCTION.md)
- Other commands correctly

## Outputs
- Updated `$COMMANDS_DIR/create-workflow.md`
- Updated `$COMMANDS_DIR/validate-workflow.md`

## Success Criteria
- [ ] validate-workflow.md CLI options replaced with natural language guidance
- [ ] Both files clarified as slash commands
- [ ] create-workflow.md workflow types table complete (9 types)
- [ ] All Constitution references removed from both files
- [ ] Examples show `/command` format where appropriate
- [ ] See Also sections reference correct documents
- [ ] Both documents parse as valid markdown

## Error Handling
- If sections not found at expected locations, search entire document
- If table format differs, adapt changes to match existing format
- Report any inconsistencies that couldn't be resolved

## Rollback Plan
Restore files from:
- `$SYSTEM_ROOT/backups/pre-fix-backup-v2/commands/create-workflow.md`
- `$SYSTEM_ROOT/backups/pre-fix-backup-v2/commands/validate-workflow.md`
