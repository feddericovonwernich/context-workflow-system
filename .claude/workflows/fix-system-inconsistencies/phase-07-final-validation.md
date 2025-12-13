---
phase_metadata:
  execution_mode: sequential

  inputs:
    parameters:
      - name: PROJECT_ROOT
        required: true
        description: "Root directory of the context-workflow-system project"
      - name: STRICT_MODE
        required: false
        default: true
        description: "Fail on any validation error"
      - name: CRITICAL_FIXES_APPLIED
        required: false
        description: "Count from Phase 1"
        type: integer
      - name: SCHEMA_FIXES_APPLIED
        required: false
        description: "Count from Phase 2"
        type: integer
      - name: CROSSREF_FIXES_APPLIED
        required: false
        description: "Count from Phase 3"
        type: integer
      - name: SPEC_FIXES_APPLIED
        required: false
        description: "Count from Phase 4"
        type: integer
      - name: PROMPT_FIXES_APPLIED
        required: false
        description: "Count from Phase 5"
        type: integer
      - name: MINOR_FIXES_APPLIED
        required: false
        description: "Count from Phase 6"
        type: integer

  outputs:
    files:
      - path: "$PROJECT_ROOT/.claude/workflows/fix-system-inconsistencies/validation-report.md"
        description: "Comprehensive validation report"
    parameters:
      - name: VALIDATION_STATUS
        description: "Overall validation result (PASS/FAIL)"
        type: string
      - name: TOTAL_FIXES_APPLIED
        description: "Total number of fixes applied across all phases"
        type: integer
      - name: NEW_ISSUES_FOUND
        description: "Number of new issues introduced (should be 0)"
        type: integer

  preferred_agent: phase-executor
---

# Phase 7: Final Validation

**Purpose**: Verify all fixes were applied correctly, no new inconsistencies were introduced, and the system is now internally consistent.

## Prerequisites
- Phases 1-6 completed successfully
- All modified files are readable
- Original findings document available for cross-reference

## Tasks for Todo List
1. Validate all 27 original findings are addressed
2. Check for new inconsistencies introduced by fixes
3. Verify schema files are valid YAML
4. Cross-reference all documentation for consistency
5. Generate comprehensive validation report
6. Calculate total fixes applied

## Parameters Used
- `PROJECT_ROOT`: Base directory for all file operations
- `STRICT_MODE`: If true, any validation failure is an error
- Fix counts from previous phases for summary

## Process

### Step 1: Verify Critical Fixes (Findings #1-4)

Check each critical fix was applied:

**Finding #1 - Agent Invocation Contradiction**:
- [ ] File: `$PROJECT_ROOT/.claude/commands/run-workflow.md`
- [ ] Verify: No mention of "Agents can call specialized sub-agents"
- [ ] Verify: Contains warning that agents CANNOT invoke other agents

**Finding #2 - Template Path**:
- [ ] File: `$PROJECT_ROOT/.claude/agents/workflow/workflow-creator.md`
- [ ] Verify: References `.claude/templates/phase-template.md` (not `.claude/templates/workflows/`)

**Finding #3 - Docs Path**:
- [ ] File: `$PROJECT_ROOT/.claude/agents/workflow/workflow-validator.md`
- [ ] Verify: References `.claude/docs/INTRODUCTION.md` (not `.claude/workflows/`)

**Finding #4 - Parameter Casing**:
- [ ] File: `$PROJECT_ROOT/.claude/docs/REFERENCE.md`
- [ ] Verify: Example uses `PARAM_NAME` (UPPER_SNAKE_CASE)

### Step 2: Verify Schema Fixes (Findings #5-7, #12, #15, #17)

**Finding #5 - Workflow Types Consistency**:
- [ ] Count workflow types in `workflow-schema.yaml`: Should be 9
- [ ] Count workflow types in `SPECIFICATION.md`: Should be 9
- [ ] Count workflow types in `INTRODUCTION.md`: Should be 9
- [ ] Count workflow types in `create-workflow.md`: Should be 9

**Finding #6 - Number Type**:
- [ ] Verify `SPECIFICATION.md` includes `number` in parameter types

**Finding #7 - Output Parameter Types**:
- [ ] Verify `phase-metadata-schema.yaml` output parameter types include: string, boolean, integer, number, array, enum, file, directory

**Finding #12 - Default Agent**:
- [ ] Verify `workflow-schema.yaml` default_agent enum only contains `phase-executor`

**Finding #15 - Enum Logic**:
- [ ] Verify `workflow-schema.yaml` uses `allOf/if/then` pattern for enum requirement

**Finding #17 - Output Parameter Required Field**:
- [ ] Verify `phase-metadata-schema.yaml` output parameters have `required` field

### Step 3: Verify Documentation Fixes (Findings #8-11)

**Finding #8 - Runtime Parameters Filename**:
- [ ] Grep for `parameters.yaml` in docs (excluding `examples/parameters.yaml`)
- [ ] All runtime parameter references should be `runtime-parameters.yaml`

**Finding #9 - Command Reference**:
- [ ] Verify `validate-workflow.md` references `run-workflow` not `workflow`

**Finding #10 - Missing validate-workflow**:
- [ ] Verify `INTRODUCTION.md` file structure includes `validate-workflow.md`

**Finding #11 - Agent Types**:
- [ ] Verify `INTRODUCTION.md` lists all 3 agents: workflow-creator, phase-executor, workflow-validator

### Step 4: Verify Specification Fixes (Findings #13-14, #16, #19)

**Finding #13 - Required Sections**:
- [ ] Verify `SPECIFICATION.md` lists 10 required + 2 optional sections

**Finding #14 - Complexity Ranges**:
- [ ] Verify `workflow-creator.md` complexity ranges don't overlap
- [ ] Expected: Simple (2-3), Medium (4-5), Complex (6+)

**Finding #16 - Phase Numbering**:
- [ ] Verify `SPECIFICATION.md` has clear phase numbering rules with examples

**Finding #19 - Prerequisites Syntax**:
- [ ] Verify `SPECIFICATION.md` has Conditional Execution section with syntax documentation

### Step 5: Verify Prompt Fixes (Findings #18, #21-22)

**Finding #18 - Input Parameter Type**:
- [ ] Verify `phase-executor.md` clarifies parameter types in input format

**Finding #21 - Parallel Mode**:
- [ ] Verify `phase-executor.md` has Parallel Execution Context section
- [ ] Verify `phase-executor.md` has Runtime Parameters File section

**Finding #22 - Redundancy**:
- [ ] Verify `workflow-creator.md` has Quick Reference table
- [ ] Count "No Nested Agent" mentions: Should be reduced (ideally 1-2 primary locations)

### Step 6: Verify Minor Fixes (Findings #23-27)

**Finding #23 - Schema URLs**:
- [ ] Verify both schema files have comment about $id being local identifier

**Finding #24 - Duration Field**:
- [ ] Verify `SPECIFICATION.md` documents duration_seconds in completion protocol

**Finding #25 - Interpolation Syntax**:
- [ ] Verify `SPECIFICATION.md` documents both `$PARAM` and `${PARAM}` forms

**Finding #26 - Examples Directory**:
- [ ] Verify `INTRODUCTION.md` explains examples/ directory purpose

**Finding #27 - Parallel Config**:
- [ ] Verify `REFERENCE.md` parallel config includes output_pattern

### Step 7: Check for New Inconsistencies

Perform cross-reference validation:

1. **Schema Consistency**:
   - Load `workflow-schema.yaml` and verify valid YAML
   - Load `phase-metadata-schema.yaml` and verify valid YAML
   - Check no new required fields contradict documentation

2. **Documentation Consistency**:
   - Cross-reference all file paths mentioned in docs
   - Verify all referenced files exist
   - Check parameter names use consistent casing

3. **Agent Prompt Consistency**:
   - Verify agent descriptions match their documented capabilities
   - Check no conflicting instructions across agents

4. **Command Consistency**:
   - Verify command usage examples are valid
   - Check argument descriptions match implementation

### Step 8: Generate Validation Report

Create `$PROJECT_ROOT/.claude/workflows/fix-system-inconsistencies/validation-report.md`:

```markdown
# Validation Report: Fix System Inconsistencies

Generated: [timestamp]
Workflow Version: 1.0.0

## Executive Summary

- **Overall Status**: [PASS/FAIL]
- **Total Fixes Applied**: [sum of all phases]
- **New Issues Found**: [count]

## Fix Summary by Phase

| Phase | Description | Fixes Applied | Status |
|-------|-------------|---------------|--------|
| Phase 1 | Critical Fixes | [count] | [PASS/FAIL] |
| Phase 2 | Schema Harmonization | [count] | [PASS/FAIL] |
| Phase 3 | Documentation Cross-Refs | [count] | [PASS/FAIL] |
| Phase 4 | Specification Completeness | [count] | [PASS/FAIL] |
| Phase 5 | Agent Prompt Optimization | [count] | [PASS/FAIL] |
| Phase 6 | Reference & Template Fixes | [count] | [PASS/FAIL] |
| **Total** | | **[total]** | |

## Findings Verification

### Critical Findings (4)
| # | Finding | File | Status |
|---|---------|------|--------|
| 1 | Agent invocation contradiction | run-workflow.md | [✓/✗] |
| 2 | Template path | workflow-creator.md | [✓/✗] |
| 3 | Docs path | workflow-validator.md | [✓/✗] |
| 4 | Parameter casing | REFERENCE.md | [✓/✗] |

### High Severity Findings (8)
[Table for findings 5-12]

### Medium Severity Findings (9)
[Table for findings 13-21]

### Low Severity Findings (6)
[Table for findings 22-27]

## Cross-Reference Validation

| Check | Result |
|-------|--------|
| Workflow types consistent (9 types) | [✓/✗] |
| Parameter types consistent | [✓/✗] |
| File paths all valid | [✓/✗] |
| Agent capabilities consistent | [✓/✗] |
| No new contradictions | [✓/✗] |

## New Issues Found

[List any new inconsistencies discovered during validation]

## Conclusion

[Summary statement about validation results]

## Recommendations

[Any follow-up actions if needed]
```

## Outputs
- validation-report.md with comprehensive results
- VALIDATION_STATUS: PASS or FAIL
- TOTAL_FIXES_APPLIED: Sum of all phase fix counts
- NEW_ISSUES_FOUND: Count of any new issues (target: 0)

## Success Criteria
- [ ] All 27 original findings verified as addressed
- [ ] No new inconsistencies introduced
- [ ] All schema files are valid YAML
- [ ] All file path references are correct
- [ ] Documentation is internally consistent
- [ ] VALIDATION_STATUS = PASS

## Error Handling
- **Finding not addressed**: Report which finding and current state
- **New inconsistency found**: Document in report, set VALIDATION_STATUS = FAIL if STRICT_MODE
- **File not found**: Report missing file and expected location
- **Schema invalid**: Report YAML syntax error and location

## Rollback Plan
If validation fails and STRICT_MODE is true:
1. Review validation-report.md for specific failures
2. Identify which phase introduced the issue
3. Either fix the specific issue or restore from Phase 0 backup
4. Re-run validation

Complete rollback to original state:
```bash
cp -r $BACKUP_DIR/.claude/* $PROJECT_ROOT/.claude/
```

## Notes
- This phase is critical for ensuring the fixes don't introduce new problems
- The validation report serves as audit documentation
- STRICT_MODE should be true for production use
- Keep validation-report.md for future reference
