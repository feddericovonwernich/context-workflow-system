# Fix System Inconsistencies Workflow

Addresses all inconsistencies identified in the context workflow system analysis.

## Quick Start

```bash
/run-workflow .claude/workflows/fix-system-inconsistencies
```

## Phases Overview

| Phase | Name | Target Files | Fixes |
|-------|------|--------------|-------|
| 01 | Fix Schemas | `schemas/*.yaml` | Add missing `array` type |
| 02 | Fix Specification | `docs/SPECIFICATION.md` | Complete parameter types |
| 03 | Fix Validator Agent | `agents/workflow/workflow-validator.md` | Correct types, remove dead refs |
| 04 | Fix run-workflow | `commands/run-workflow.md` | Phase reqs, env vars, pseudocode note |
| 05 | Fix Introduction | `docs/INTRODUCTION.md` | Remove --params, add execution.log |
| 06 | Fix Creator Agent | `agents/workflow/workflow-creator.md` | Clarify parallel execution |
| 07 | Fix Reference | `docs/REFERENCE.md` | Directory structure, consistency |
| 08 | Validation | All files | Cross-check & summary report |

## Issues Addressed

### Critical (Schema/Spec)
- `array` type missing from SPECIFICATION.md
- Input/output parameter type mismatch in phase-metadata-schema.yaml
- workflow-validator.md has wrong type list

### High (Cross-File)
- Undocumented `--params` flag
- Minimum phase requirements contradiction
- Missing environment variable docs

### Medium (Prompt Effectiveness)
- Python syntax in Task examples
- Parallel execution constraint ambiguity
- "Constitution files" dead reference

### Low (Documentation)
- Missing runtime files in directory structures
- Redundant but inconsistent documentation

## Output

After completion, `docs/INCONSISTENCIES-FIXED.md` will contain a summary of all changes.
