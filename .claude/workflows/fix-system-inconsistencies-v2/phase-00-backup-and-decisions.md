---
phase_metadata:
  execution_mode: sequential
  inputs:
    parameters:
      - name: SYSTEM_ROOT
        required: true
        description: "Root directory of the workflow system"
      - name: DRY_RUN
        required: false
        default: false
        description: "If true, only report without making changes"
  outputs:
    files:
      - path: "$SYSTEM_ROOT/backups/pre-fix-backup-v2/"
        description: "Complete backup of all files before modifications"
    parameters:
      - name: BACKUP_CREATED
        description: "Whether backup was successfully created"
      - name: CANONICAL_DECISIONS
        description: "JSON object of canonical decisions for each conflict"
---

# Phase 0: Backup and Canonical Decisions

**Purpose**: Create a safety backup of all system files and establish canonical decisions for each identified conflict before making any modifications.

## Prerequisites
- Write access to $SYSTEM_ROOT directory
- Sufficient disk space for backup

## Tasks for Todo List
1. Create timestamped backup directory
2. Copy all documentation files to backup
3. Copy all schema files to backup
4. Copy all agent prompt files to backup
5. Copy all command files to backup
6. Copy template files to backup
7. Document canonical decisions for all 27 inconsistencies
8. Verify backup integrity

## Parameters Used
- `SYSTEM_ROOT`: Root directory containing all system files
- `DRY_RUN`: Whether to execute or just report

## Process

### Step 1: Create Backup Directory

Create a timestamped backup directory at `$SYSTEM_ROOT/backups/pre-fix-backup-v2/`:

```
$SYSTEM_ROOT/backups/pre-fix-backup-v2/
├── docs/
│   ├── INTRODUCTION.md
│   ├── SPECIFICATION.md
│   └── REFERENCE.md
├── schemas/
│   ├── workflow-schema.yaml
│   └── phase-metadata-schema.yaml
├── agents/workflow/
│   ├── workflow-creator.md
│   ├── phase-executor.md
│   └── workflow-validator.md
├── commands/
│   ├── create-workflow.md
│   ├── run-workflow.md
│   └── validate-workflow.md
├── templates/
│   └── phase-template.md
└── backup-manifest.yaml
```

### Step 2: Copy All Files to Backup

Copy each file preserving directory structure. Create a manifest file listing all backed up files with their checksums.

### Step 3: Document Canonical Decisions

For each conflict, establish the canonical (correct) value that all documents must conform to:

#### Critical Decisions (Must Resolve)

**Decision 1: Minimum Phase Requirement**
- **Canonical Rule**: A workflow requires a MINIMUM of 2 phase files
- **Valid combinations**:
  - `phase-01-*.md` + `phase-02-*.md` (minimum without setup)
  - `phase-00-*.md` + `phase-01-*.md` (minimum with setup)
  - Any sequential set of 2+ phases
- **Update targets**: SPECIFICATION.md, workflow-validator.md, REFERENCE.md, run-workflow.md

**Decision 2: Phase Metadata Requirement**
- **Canonical Rule**: Phase metadata is RECOMMENDED (WARNING if missing), not required
- **Rationale**: Backward compatibility per run-workflow.md:627-630
- **Update targets**: REFERENCE.md (remove "Required"), ensure SPECIFICATION.md says WARNING

**Decision 3: Output Parameter Type `array`**
- **Canonical Rule**: ADD `array` to workflow-schema.yaml to match phase-metadata-schema.yaml
- **Rationale**: Output parameters may legitimately be arrays (e.g., list of generated files)
- **Update targets**: workflow-schema.yaml, SPECIFICATION.md parameter types table

**Decision 4: Agent Invocation Constraint**
- **Canonical Rule**: Agents CANNOT invoke other agents (no exceptions)
- **Update targets**: INTRODUCTION.md line 513-516 must be removed/reworded

#### Moderate Decisions

**Decision 5: Runtime Parameters File Name**
- **Canonical Name**: `runtime-parameters.yaml`
- **Update targets**: run-workflow.md (fix line 217 reference to "parameters.yaml")

**Decision 6: default_agent Field**
- **Canonical Decision**: REMOVE the field entirely (it serves no purpose with single enum value)
- **Update targets**: workflow-schema.yaml, SPECIFICATION.md

**Decision 7: Parallel Agent Type Guidance**
- **Canonical Rule**: Any agent type can be used for parallel execution, including phase-executor
- **Update targets**: run-workflow.md (remove "not phase-executor" guidance)

**Decision 8: Phase Count Guidance**
- **Canonical Guidance**: Simple (2-3), Medium (4-6), Complex (7+)
- **Update targets**: workflow-creator.md (align Quick Reference with body text)

**Decision 9: Command Documentation**
- **Canonical Rule**: Document these as slash commands, not CLI tools with flags
- **Update targets**: validate-workflow.md, create-workflow.md

**Decision 10: INTRODUCTION.md Typo**
- **Fix**: Change "workflow command" to "run-workflow command" at line 207

#### Schema Documentation Decisions

**Decision 11: Document Constraint Lengths**
- **Add to SPECIFICATION.md**: name (3-50 chars), description (10-500 chars), parameter descriptions (5-200 chars)

**Decision 12: Environment Variable Prefix**
- **Document**: WORKFLOW_ prefix convention in SPECIFICATION.md and REFERENCE.md

**Decision 13: Output File Required Default**
- **Document**: Default is `true` in SPECIFICATION.md

#### Agent Prompt Decisions

**Decision 14: workflow-creator.md Length**
- **Action**: Consolidate redundant sections, target <350 lines

**Decision 15: phase-executor.md Conflict**
- **Canonical Rule**: Orchestrator handles runtime-parameters.yaml updates
- **Fix**: Remove line 49 instruction about updating the file

**Decision 16: workflow-validator.md Schema References**
- **Action**: Add explicit schema file references

**Decision 17: Completion Report Redundancy**
- **Action**: Remove duplicate format explanation in phase-executor.md

#### Cross-Reference Decisions

**Decision 18: Relative Paths**
- **Action**: Keep relative paths but add note about context

**Decision 19: Template Path**
- **Keep**: Singular reference is correct (only one template exists)

#### Minor Decisions

**Decision 20: ASCII Art**
- **Action**: Simplify but keep for visual clarity

**Decision 21: Template Placeholders**
- **Action**: Add comment distinguishing template vars from runtime params

**Decision 22-27: Documentation Polish**
- **Actions**: Fix capitalization, quote consistency, add missing workflow types, remove Constitution references

### Step 4: Create Backup Manifest

Create `backup-manifest.yaml` with:
- Timestamp of backup
- List of all files with paths
- SHA256 checksums for each file
- Total file count

## Outputs
- Complete backup at `$SYSTEM_ROOT/backups/pre-fix-backup-v2/`
- `backup-manifest.yaml` with file checksums
- Canonical decisions documented (in this phase's execution log)

## Success Criteria
- [ ] Backup directory created with correct structure
- [ ] All 12 system files copied to backup
- [ ] Backup manifest created with checksums
- [ ] All 27 canonical decisions documented
- [ ] Backup integrity verified (files readable)

## Error Handling
- If backup directory already exists, append timestamp suffix
- If file copy fails, report which file and abort
- If disk space insufficient, report required space and abort

## Rollback Plan
This phase creates backups - no rollback needed. If later phases fail, restore from this backup.
