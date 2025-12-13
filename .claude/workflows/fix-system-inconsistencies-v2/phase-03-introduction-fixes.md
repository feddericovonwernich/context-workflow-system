---
phase_metadata:
  execution_mode: sequential
  inputs:
    files:
      - name: INTRODUCTION_FILE
        required: true
        path: "$DOCS_DIR/INTRODUCTION.md"
        description: "The introduction/overview document"
    parameters:
      - name: DOCS_DIR
        required: true
        description: "Documentation directory"
      - name: DRY_RUN
        required: false
        default: false
        description: "If true, only report without making changes"
      - name: SPEC_FIXES_APPLIED
        required: true
        description: "Confirms specification phase completed"
  outputs:
    files:
      - path: "$DOCS_DIR/INTRODUCTION.md"
        description: "Updated introduction document"
    parameters:
      - name: INTRO_FIXES_APPLIED
        description: "Number of introduction fixes applied"
---

# Phase 3: INTRODUCTION.md Fixes

**Purpose**: Fix critical contradictions and errors in the introduction document, particularly the agent invocation statement that directly contradicts the core architectural constraint.

## Prerequisites
- Specification fixes completed (SPEC_FIXES_APPLIED confirmed)
- Write access to $DOCS_DIR

## Tasks for Todo List
1. Read current INTRODUCTION.md
2. Fix critical agent invocation contradiction (lines 513-516)
3. Fix "workflow command" typo (line 207)
4. Remove all Constitution references
5. Ensure consistency with updated SPECIFICATION.md
6. Verify document coherence

## Parameters Used
- `DOCS_DIR`: Location of documentation files
- `DRY_RUN`: Whether to apply changes or just report
- `SPEC_FIXES_APPLIED`: Confirms safe to proceed

## Process

### Step 1: Fix Critical Agent Invocation Contradiction

**Issue**: This is the most critical fix. INTRODUCTION.md contradicts the core architectural constraint.

**Location**: Lines 513-516 (in "Integration Points" > "With AI Agents" section)

**Current Text** (WRONG):
```markdown
### With AI Agents

- **Specialized Agents**: Can be called within phases
- **Tool Access**: Phases can use all available tools
- **Context Management**: Orchestrator handles state
- **Error Recovery**: Agents report failures clearly
```

**Change To** (CORRECT):
```markdown
### With AI Agents

- **Orchestrator Control**: The orchestrator invokes agents for each phase
- **No Nested Agents**: Phases cannot invoke other agents (see SPECIFICATION.md#agent-constraints)
- **Tool Access**: Phase executors have access to standard tools (file operations, bash, etc.)
- **Context Management**: Orchestrator manages parameter flow between phases
- **Error Recovery**: Agents report failures via structured completion reports
```

**Rationale**: The statement "Specialized Agents: Can be called within phases" directly contradicts the fundamental constraint documented in SPECIFICATION.md:538-542 that agents CANNOT invoke other agents.

### Step 2: Fix "workflow command" Typo

**Location**: Around line 207 (in System Architecture diagram)

**Current Text**:
```markdown
[workflow command]
```

**Change To**:
```markdown
[run-workflow command]
```

This appears in the Component Interaction Flow ASCII diagram. Ensure the full line reads correctly after the fix.

### Step 3: Remove Constitution References

**Search for and handle** these patterns:

1. **Line 349-356** (Constitution section):
```markdown
### Constitution

Architectural principles enforced across workflows:
- Library-first architecture
- Test-first development
- Integration-first testing
- Observability requirements
- Simplicity (YAGNI)
- Compatibility contracts
```

**Replace with**:
```markdown
### Architectural Principles

Best practices encouraged in workflows:
- Clear separation of concerns
- Explicit dependencies between phases
- Comprehensive error handling
- Measurable success criteria
- Documentation-driven design
- Compliance with SPECIFICATION.md
```

2. **Any other "Constitution" or "Constitutional" references**:
   - Search for "constitution" (case-insensitive)
   - Remove or replace with "specification" as appropriate

### Step 4: Verify Troubleshooting Section

**Location**: Around lines 552-556

**Current Text** may have:
```markdown
**"Agent invocation failed" or "Task tool not available"**
- This indicates a phase is trying to invoke a sub-agent (not supported)
```

**Verify** this text exists and is accurate. If missing, add it to the troubleshooting section.

### Step 5: Ensure Parameter Types Match SPECIFICATION.md

**Location**: Lines 702-710 (Parameter Types section at end)

**Verify** the parameter types list matches the updated SPECIFICATION.md:
- string
- boolean
- integer
- number
- enum
- file
- directory
- array (ADD if missing)

### Step 6: Verify Cross-References

Check all references to SPECIFICATION.md use correct anchor format:
- `[SPECIFICATION.md](SPECIFICATION.md#agent-constraints)` - should work
- Verify anchor names match actual section IDs in SPECIFICATION.md

### Step 7: Document Coherence Check

After all edits:
1. Read through the Integration Points section to ensure it flows logically
2. Verify the Core Philosophy section aligns with the fixes
3. Check Best Practices section doesn't contradict the agent constraint
4. Ensure Quick Reference at end is accurate

## Outputs
- Updated `$DOCS_DIR/INTRODUCTION.md`

## Success Criteria
- [ ] Agent invocation contradiction fixed - no more "Can be called within phases"
- [ ] "workflow command" typo fixed to "run-workflow command"
- [ ] All Constitution references removed or replaced
- [ ] Troubleshooting section includes agent invocation failure guidance
- [ ] Parameter types include `array`
- [ ] All cross-references to SPECIFICATION.md are valid
- [ ] Document parses as valid markdown

## Error Handling
- If contradictory text not found at expected line, search entire document
- If Constitution section has been moved, locate and update accordingly
- Report any references that couldn't be updated

## Rollback Plan
Restore `$DOCS_DIR/INTRODUCTION.md` from `$SYSTEM_ROOT/backups/pre-fix-backup-v2/docs/INTRODUCTION.md`

## Notes
The agent invocation fix is the highest priority item in this phase. The original text would cause users to believe they can call agents from within phases, which would lead to runtime failures and confusion.
