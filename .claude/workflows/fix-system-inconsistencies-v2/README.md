# Fix System Inconsistencies Workflow v2

A comprehensive 10-phase workflow to address all 27 identified inconsistencies in the Context Workflow System documentation, schemas, and agent prompts.

## Overview

This workflow systematically fixes inconsistencies across:
- JSON schemas (workflow-schema.yaml, phase-metadata-schema.yaml)
- Documentation (SPECIFICATION.md, INTRODUCTION.md, REFERENCE.md)
- Command documentation (run-workflow.md, create-workflow.md, validate-workflow.md)
- Agent prompts (workflow-creator.md, phase-executor.md, workflow-validator.md)
- Templates (phase-template.md)

## Issues Addressed

### Critical Issues (4)
1. **Minimum phase requirement conflict** - Different docs state 1, 2, or "at least two execution phases"
2. **Phase metadata required vs optional** - Conflicting statements about whether metadata is required
3. **Output parameter type `array` missing** - Present in phase schema but not workflow schema
4. **Agent invocation contradiction** - INTRODUCTION.md says agents can be called within phases (wrong)

### Moderate Issues (6)
5. **runtime-parameters.yaml naming** - Some docs reference "parameters.yaml" instead
6. **default_agent field pointless** - Single-option enum serves no purpose
7. **Parallel agent type guidance** - Incorrectly restricts phase-executor from parallel use
8. **Phase count inconsistency** - Different ranges stated (2-3, 3-7, 4-6)
9. **CLI options vs slash commands** - Documents CLI flags for slash commands
10. **INTRODUCTION.md typo** - "workflow command" instead of "run-workflow command"

### Schema Documentation Gaps (3)
11. **Constraint lengths not documented** - Schema has min/max lengths not in spec
12. **Environment variable prefix** - WORKFLOW_ prefix not fully documented
13. **Output file required default** - Default value not documented

### Agent Prompt Issues (4)
14. **workflow-creator.md too long** - 470 lines with redundancy
15. **phase-executor.md conflict** - Conflicting instructions about runtime-parameters.yaml
16. **workflow-validator.md schema refs** - Missing explicit schema file references
17. **Completion report redundancy** - Format explained twice

### Cross-Reference Issues (2)
18. **Relative path references** - May not work from all contexts
19. **Template path consistency** - Minor path reference issue

### Minor Issues (8)
20-27. ASCII art complexity, template placeholders, documentation polish, Constitution references (feature doesn't exist)

## Phases

| Phase | Name | Purpose |
|-------|------|---------|
| 00 | Backup and Decisions | Create safety backup, establish canonical decisions |
| 01 | Schema Fixes | Add `array` type, remove `default_agent` |
| 02 | SPECIFICATION.md Fixes | Document constraints, fix requirements, add `array` type |
| 03 | INTRODUCTION.md Fixes | Fix agent contradiction, remove Constitution refs |
| 04 | REFERENCE.md Fixes | Fix metadata requirement, add missing info |
| 05 | run-workflow.md Fixes | Fix file naming, parallel guidance |
| 06 | Command Docs Fixes | Clarify slash commands, remove Constitution refs |
| 07 | Agent Prompt Optimization | Reduce redundancy, fix conflicts |
| 08 | Template Fixes | Clarify placeholder types |
| 09 | Validation | Verify all 27 issues resolved |

## Usage

```bash
/run-workflow .claude/workflows/fix-system-inconsistencies-v2
```

### With Dry Run (report only, no changes)
```bash
/run-workflow .claude/workflows/fix-system-inconsistencies-v2 --DRY_RUN=true
```

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `SYSTEM_ROOT` | directory | Yes | `.claude` | Root directory of workflow system |
| `DOCS_DIR` | directory | No | `.claude/docs` | Documentation directory |
| `SCHEMAS_DIR` | directory | No | `.claude/schemas` | Schemas directory |
| `AGENTS_DIR` | directory | No | `.claude/agents/workflow` | Agent prompts directory |
| `COMMANDS_DIR` | directory | No | `.claude/commands` | Commands directory |
| `TEMPLATES_DIR` | directory | No | `.claude/templates` | Templates directory |
| `DRY_RUN` | boolean | No | `false` | Report only, no changes |

## Expected Outputs

After successful execution:

1. **Backup** at `.claude/backups/pre-fix-backup-v2/`
2. **Updated schemas** with `array` type and without `default_agent`
3. **Consistent documentation** across all files
4. **Optimized agent prompts** (workflow-creator.md <350 lines)
5. **Clarified template** with placeholder type documentation
6. **Validation report** at workflow directory

## Rollback

If issues occur, restore from backup:
```bash
cp -r .claude/backups/pre-fix-backup-v2/* .claude/
```

## Success Criteria

- All 27 issues resolved (verified in Phase 09)
- Cross-document consistency confirmed
- No new inconsistencies introduced
- All files parse correctly (valid YAML/Markdown)

## Files Modified

| File | Changes |
|------|---------|
| `schemas/workflow-schema.yaml` | Add `array` type, remove `default_agent` |
| `docs/SPECIFICATION.md` | Document constraints, fix requirements, add types |
| `docs/INTRODUCTION.md` | Fix agent contradiction, typo, Constitution refs |
| `docs/REFERENCE.md` | Fix metadata requirement, add env var docs |
| `commands/run-workflow.md` | Fix file naming, parallel guidance |
| `commands/create-workflow.md` | Clarify slash command, add workflow types |
| `commands/validate-workflow.md` | Clarify slash command, fix Constitution refs |
| `agents/workflow/workflow-creator.md` | Consolidate, reduce length |
| `agents/workflow/phase-executor.md` | Fix conflicting instructions |
| `agents/workflow/workflow-validator.md` | Add schema refs, simplify ASCII |
| `templates/phase-template.md` | Add placeholder clarification |

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-01-13 | Initial workflow addressing 27 inconsistencies |
