# Fix System Inconsistencies Workflow

A comprehensive workflow to address all 27 identified inconsistencies in the Context Workflow System documentation, schemas, agents, and commands.

## Overview

This workflow was generated from a technical analysis that identified inconsistencies across 12 files in the system. The fixes are organized into 7 phases, progressing from critical blockers to minor improvements.

## Findings Summary

| Severity | Count | Description |
|----------|-------|-------------|
| 🔴 Critical | 4 | Blocks functionality or causes failures |
| 🟠 High | 8 | Creates confusion, validation failures |
| 🟡 Medium | 9 | Edge cases, incomplete specifications |
| 🟢 Low | 6 | Style, efficiency, minor clarity |
| **Total** | **27** | |

## Phases

### Phase 0: Backup and Preparation
Creates backups of all 12 files that will be modified and generates a backup manifest.

### Phase 1: Critical Path Fixes
Addresses the 4 critical issues:
1. Agent invocation contradiction in `run-workflow.md`
2. Template path error in `workflow-creator.md`
3. Docs path error in `workflow-validator.md`
4. Parameter casing in `REFERENCE.md`

### Phase 2: Schema Harmonization
Fixes schema logical issues:
1. `default_agent` enum values
2. Enum dependency logic
3. `number` type in SPECIFICATION.md
4. Workflow types across documents
5. Output parameter types
6. Output parameter `required` field

### Phase 3: Documentation Cross-References
Fixes cross-reference errors:
1. Runtime parameters filename
2. INTRODUCTION.md file structure
3. Agent types list
4. Workflow types list
5. Command references

### Phase 4: Specification Completeness
Fills specification gaps:
1. Required phase sections
2. Complexity phase ranges
3. Phase numbering rules
4. Prerequisites condition syntax

### Phase 5: Agent Prompt Optimization
Improves agent effectiveness:
1. Parallel mode guidance
2. Runtime-parameters.yaml format
3. Redundancy reduction
4. Prompt clarity

### Phase 6: Reference and Template Fixes
Minor documentation fixes:
1. Parallel config examples
2. Parameter interpolation syntax
3. Examples directory documentation
4. Schema URL disclaimers

### Phase 7: Final Validation
Verifies all fixes and generates validation report.

## Usage

```bash
# Run the workflow
run-workflow .claude/workflows/fix-system-inconsistencies

# Run with custom parameters
run-workflow .claude/workflows/fix-system-inconsistencies \
  --PROJECT_ROOT=/path/to/project \
  --BACKUP_ENABLED=true \
  --STRICT_MODE=true

# Dry run (show changes without applying)
run-workflow .claude/workflows/fix-system-inconsistencies \
  --DRY_RUN=true
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `PROJECT_ROOT` | directory | Yes | Current directory | Root of context-workflow-system |
| `BACKUP_ENABLED` | boolean | No | true | Create backups before modifying |
| `STRICT_MODE` | boolean | No | true | Fail on any validation error |
| `DRY_RUN` | boolean | No | false | Show changes without applying |

## Files Modified

This workflow modifies 12 files:

**Schemas (2)**:
- `.claude/schemas/workflow-schema.yaml`
- `.claude/schemas/phase-metadata-schema.yaml`

**Documentation (3)**:
- `.claude/docs/INTRODUCTION.md`
- `.claude/docs/SPECIFICATION.md`
- `.claude/docs/REFERENCE.md`

**Commands (3)**:
- `.claude/commands/create-workflow.md`
- `.claude/commands/run-workflow.md`
- `.claude/commands/validate-workflow.md`

**Agents (3)**:
- `.claude/agents/workflow/workflow-creator.md`
- `.claude/agents/workflow/phase-executor.md`
- `.claude/agents/workflow/workflow-validator.md`

**Templates (1)**:
- `.claude/templates/phase-template.md`

## Outputs

After successful execution:
- `backup-manifest.yaml` - Record of all backed up files
- `validation-report.md` - Comprehensive validation results
- All 12 files updated with fixes

## Rollback

If issues occur, restore from backup:

```bash
# Full rollback
cp -r .claude/backups/fix-inconsistencies-[timestamp]/.claude/* .claude/

# Partial rollback (specific file)
cp .claude/backups/fix-inconsistencies-[timestamp]/.claude/docs/SPECIFICATION.md .claude/docs/
```

## Success Criteria

- All 27 findings addressed
- No new inconsistencies introduced
- All schema files valid YAML
- Documentation internally consistent
- Validation report shows PASS status

## Technical Details

### Critical Findings Addressed

| # | Issue | Impact |
|---|-------|--------|
| 1 | `run-workflow.md` claims agents can call sub-agents | Contradicts fundamental constraint |
| 2 | `workflow-creator.md` references non-existent template path | Agent fails to find templates |
| 3 | `workflow-validator.md` references wrong docs path | Validator fails to load context |
| 4 | `REFERENCE.md` uses lowercase parameter names | Example fails schema validation |

### Schema Changes

- `default_agent` now only allows `phase-executor`
- Enum logic correctly requires `enum` array when `type: enum`
- Output parameters support full type set including `array`, `file`, `directory`
- Output parameters have optional `required` field

### Documentation Improvements

- Consistent use of `runtime-parameters.yaml` filename
- Complete workflow type list (9 types) across all documents
- Full agent list (3 agents) in INTRODUCTION.md
- Clear phase numbering rules with examples
- Prerequisites condition syntax documentation

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-01-13 | Initial workflow addressing 27 findings |
