---
phase_metadata:
  execution_mode: sequential
  inputs:
    parameters:
      - name: SYSTEM_ROOT
        required: true
        description: "Root directory of the workflow system"
      - name: DOCS_DIR
        required: true
        description: "Documentation directory"
      - name: SCHEMAS_DIR
        required: true
        description: "Schemas directory"
      - name: AGENTS_DIR
        required: true
        description: "Agent prompts directory"
      - name: COMMANDS_DIR
        required: true
        description: "Commands directory"
      - name: TEMPLATES_DIR
        required: true
        description: "Templates directory"
      - name: DRY_RUN
        required: false
        default: false
        description: "If true, validation only"
      - name: TEMPLATE_FIXES_APPLIED
        required: true
        description: "Confirms template phase completed"
  outputs:
    files:
      - path: "$SYSTEM_ROOT/workflows/fix-system-inconsistencies-v2/validation-report.md"
        description: "Comprehensive validation report"
    parameters:
      - name: ALL_ISSUES_RESOLVED
        description: "Boolean indicating if all 27 issues were addressed"
      - name: ISSUES_RESOLVED_COUNT
        description: "Number of issues successfully resolved"
      - name: REMAINING_ISSUES
        description: "List of any issues that couldn't be resolved"
---

# Phase 9: Validation and Verification

**Purpose**: Perform comprehensive validation of all changes made across previous phases, verify all 27 identified inconsistencies have been addressed, cross-check document consistency, and generate a final validation report.

## Prerequisites
- All previous phases completed (TEMPLATE_FIXES_APPLIED confirmed)
- Read access to all system files

## Tasks for Todo List
1. Verify schema internal consistency
2. Verify SPECIFICATION.md updates complete
3. Verify INTRODUCTION.md contradiction removed
4. Verify REFERENCE.md updates complete
5. Verify run-workflow.md updates complete
6. Verify command docs updates complete
7. Verify agent prompts optimized
8. Verify template clarified
9. Cross-check all documents for consistency
10. Generate comprehensive validation report
11. Produce issue resolution summary

## Parameters Used
- All directory parameters for file access
- `DRY_RUN`: Mode indicator
- `TEMPLATE_FIXES_APPLIED`: Confirms all edits complete

## Process

### Step 1: Validate Schema Changes

Read both schema files and verify:

**workflow-schema.yaml**:
- [ ] `array` type present in `definitions.parameterObject.properties.type.enum`
- [ ] `array` type present in `definitions.parameterArray.properties.type.enum`
- [ ] `default_agent` field REMOVED from `properties.phases.properties`
- [ ] Schema parses as valid YAML
- [ ] No broken `$ref` references

**phase-metadata-schema.yaml**:
- [ ] Structure unchanged (was correct)
- [ ] `array` type present in output parameter types (line 247)
- [ ] Schema parses as valid YAML

### Step 2: Validate SPECIFICATION.md Changes

Read SPECIFICATION.md and verify:

- [ ] Minimum phase requirement clearly states "2 phase files minimum"
- [ ] Field constraints table added (name: 3-50, description: 10-500, param desc: 5-200)
- [ ] `array` type in parameter types table (8 types total)
- [ ] `default_agent` not mentioned in workflow.yaml structure
- [ ] Environment variable prefix documented (WORKFLOW_ prefix)
- [ ] Output file `required` default documented
- [ ] No "Constitution" or "Constitutional" references

### Step 3: Validate INTRODUCTION.md Changes

Read INTRODUCTION.md and verify:

- [ ] "Specialized Agents: Can be called within phases" REMOVED or FIXED
- [ ] "workflow command" changed to "run-workflow command" (around line 207)
- [ ] No Constitution references remain
- [ ] Troubleshooting section has agent invocation failure guidance
- [ ] Parameter types list includes `array`
- [ ] Cross-references to SPECIFICATION.md are valid

### Step 4: Validate REFERENCE.md Changes

Read REFERENCE.md and verify:

- [ ] Phase metadata marked "Recommended" not "Required"
- [ ] Note added about metadata being optional
- [ ] `array` type in parameter types table
- [ ] Environment variable prefix documented
- [ ] File references have context about relative paths
- [ ] Minimum phase count clarified
- [ ] Critical Rules section has 6 rules

### Step 5: Validate run-workflow.md Changes

Read run-workflow.md and verify:

- [ ] All "parameters.yaml" changed to "runtime-parameters.yaml"
- [ ] Parallel agent type allows phase-executor
- [ ] Minimum phase requirements note added
- [ ] No Constitution references
- [ ] Agent constraint documentation present (line 623 area)
- [ ] Backward compatibility note accurate

### Step 6: Validate Command Documentation Changes

**create-workflow.md**:
- [ ] Slash command clarification added
- [ ] Workflow types table has all 9 types
- [ ] No Constitution references

**validate-workflow.md**:
- [ ] CLI options replaced with natural language guidance
- [ ] Slash command clarification added
- [ ] Constitution references replaced with "specification"
- [ ] Examples show `/command` format

### Step 7: Validate Agent Prompt Changes

**workflow-creator.md**:
- [ ] Line count reduced (target: <350, verify current count)
- [ ] "No nested agents" consolidated to 2 locations
- [ ] Phase count guidance consistent (2-7 range)
- [ ] Quality Standards and Generation Guidelines consolidated

**phase-executor.md**:
- [ ] Line 49 conflict resolved (no longer says to update runtime-parameters.yaml directly)
- [ ] Completion report format not duplicated

**workflow-validator.md**:
- [ ] Explicit schema file references added
- [ ] ASCII art simplified
- [ ] Minimum phases says "two" not "one"
- [ ] Frontmatter consistent with other agents

### Step 8: Validate Template Changes

**phase-template.md**:
- [ ] Clarifying header comment present
- [ ] Distinguishes template placeholders from runtime params
- [ ] Example section added
- [ ] All required sections present

### Step 9: Cross-Document Consistency Check

Verify these values are consistent across ALL documents:

| Item | Expected Value | Check Locations |
|------|---------------|-----------------|
| Minimum phases | 2 | SPEC, INTRO, REF, run-workflow, validator |
| Parameter types | 8 (incl. array) | SPEC, INTRO, REF, schemas |
| Phase metadata | Recommended | SPEC, REF, run-workflow |
| Agent constraint | Cannot invoke | SPEC, INTRO, all agents |
| Env var prefix | WORKFLOW_ | SPEC, REF |
| Runtime params file | runtime-parameters.yaml | SPEC, run-workflow, phase-executor |

### Step 10: Generate Validation Report

Create `validation-report.md` with:

```markdown
# Inconsistency Fix Validation Report

Generated: [timestamp]
Workflow: fix-system-inconsistencies-v2

## Summary

- **Total Issues Identified**: 27
- **Issues Resolved**: [count]
- **Issues Remaining**: [count]
- **Resolution Rate**: [percentage]%

## Issue Resolution Status

### Critical Issues (4)
| # | Issue | Status | Verification |
|---|-------|--------|--------------|
| 1 | Minimum phase requirement conflict | [RESOLVED/REMAINING] | [details] |
| 2 | Phase metadata required/optional | [RESOLVED/REMAINING] | [details] |
| 3 | Output parameter type `array` missing | [RESOLVED/REMAINING] | [details] |
| 4 | Agent invocation contradiction | [RESOLVED/REMAINING] | [details] |

### Moderate Issues (6)
| # | Issue | Status | Verification |
|---|-------|--------|--------------|
| 5 | runtime-parameters.yaml naming | [RESOLVED/REMAINING] | [details] |
| 6 | default_agent field pointless | [RESOLVED/REMAINING] | [details] |
| 7 | Parallel agent type guidance | [RESOLVED/REMAINING] | [details] |
| 8 | Phase count inconsistency | [RESOLVED/REMAINING] | [details] |
| 9 | CLI options vs slash commands | [RESOLVED/REMAINING] | [details] |
| 10 | INTRODUCTION.md typo | [RESOLVED/REMAINING] | [details] |

### Schema Documentation Gaps (3)
| # | Issue | Status | Verification |
|---|-------|--------|--------------|
| 11 | Constraint lengths not documented | [RESOLVED/REMAINING] | [details] |
| 12 | Env var prefix not documented | [RESOLVED/REMAINING] | [details] |
| 13 | Output file required default | [RESOLVED/REMAINING] | [details] |

### Agent Prompt Issues (4)
| # | Issue | Status | Verification |
|---|-------|--------|--------------|
| 14 | workflow-creator.md too long | [RESOLVED/REMAINING] | [details] |
| 15 | phase-executor.md conflict | [RESOLVED/REMAINING] | [details] |
| 16 | workflow-validator.md schema refs | [RESOLVED/REMAINING] | [details] |
| 17 | Completion report redundancy | [RESOLVED/REMAINING] | [details] |

### Cross-Reference Issues (2)
| # | Issue | Status | Verification |
|---|-------|--------|--------------|
| 18 | Relative path references | [RESOLVED/REMAINING] | [details] |
| 19 | Template path inconsistency | [RESOLVED/REMAINING] | [details] |

### Minor Issues (8)
| # | Issue | Status | Verification |
|---|-------|--------|--------------|
| 20 | ASCII art complexity | [RESOLVED/REMAINING] | [details] |
| 21 | Template placeholder confusion | [RESOLVED/REMAINING] | [details] |
| 22-27 | Documentation polish | [RESOLVED/REMAINING] | [details] |

## Files Modified

| File | Changes Applied |
|------|-----------------|
| workflow-schema.yaml | [list] |
| SPECIFICATION.md | [list] |
| INTRODUCTION.md | [list] |
| REFERENCE.md | [list] |
| run-workflow.md | [list] |
| create-workflow.md | [list] |
| validate-workflow.md | [list] |
| workflow-creator.md | [list] |
| phase-executor.md | [list] |
| workflow-validator.md | [list] |
| phase-template.md | [list] |

## Remaining Work

[List any issues that could not be resolved and why]

## Recommendations

[Any additional improvements identified during validation]
```

## Outputs
- `$SYSTEM_ROOT/workflows/fix-system-inconsistencies-v2/validation-report.md`
- Parameter `ALL_ISSUES_RESOLVED`: true/false
- Parameter `ISSUES_RESOLVED_COUNT`: number
- Parameter `REMAINING_ISSUES`: array of issue descriptions

## Success Criteria
- [ ] All 27 issues verified as resolved or documented as remaining
- [ ] Cross-document consistency confirmed
- [ ] No new inconsistencies introduced
- [ ] Validation report generated with complete status
- [ ] All file modifications documented

## Error Handling
- If a file cannot be read, note in report and continue
- If verification fails, document specific failure and continue
- Complete full validation even if some checks fail
- Report should be generated regardless of individual check results

## Rollback Plan
This phase is read-only validation. If critical issues found:
1. Document in report
2. Recommend re-running specific phases
3. Backup remains available for full rollback

## Notes
This phase provides the quality assurance checkpoint for the entire workflow. The validation report serves as documentation of what was changed and verification that all identified issues were addressed.
