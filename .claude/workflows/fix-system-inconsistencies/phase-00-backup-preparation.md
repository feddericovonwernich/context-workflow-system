---
phase_metadata:
  execution_mode: sequential

  inputs:
    parameters:
      - name: PROJECT_ROOT
        required: true
        description: "Root directory of the context-workflow-system project"
      - name: BACKUP_ENABLED
        required: false
        default: true
        description: "Whether to create backups"
      - name: DRY_RUN
        required: false
        default: false
        description: "Show changes without applying"

  outputs:
    files:
      - path: "$PROJECT_ROOT/.claude/workflows/fix-system-inconsistencies/backup-manifest.yaml"
        description: "Manifest of all backed up files"
    parameters:
      - name: BACKUP_DIR
        description: "Directory containing backup files"
        type: string
      - name: FILES_TO_MODIFY
        description: "Count of files that will be modified"
        type: integer

  preferred_agent: phase-executor
---

# Phase 0: Backup and Preparation

**Purpose**: Create backups of all files that will be modified and establish the working context for subsequent phases.

## Prerequisites
- PROJECT_ROOT must be a valid directory containing the context-workflow-system
- Write access to PROJECT_ROOT/.claude/ directory
- All target files must exist and be readable

## Tasks for Todo List
1. Verify PROJECT_ROOT structure is valid
2. Identify all files to be modified (15 files total)
3. Create timestamped backup directory
4. Copy all target files to backup
5. Generate backup manifest
6. Verify backup integrity

## Parameters Used
- `PROJECT_ROOT`: Base directory for all operations
- `BACKUP_ENABLED`: Whether to create backups (default: true)
- `DRY_RUN`: If true, only report what would be done

## Process

### Step 1: Validate Project Structure
Verify the following files exist at PROJECT_ROOT:
```
.claude/
├── schemas/
│   ├── workflow-schema.yaml
│   └── phase-metadata-schema.yaml
├── docs/
│   ├── INTRODUCTION.md
│   ├── SPECIFICATION.md
│   └── REFERENCE.md
├── commands/
│   ├── create-workflow.md
│   ├── run-workflow.md
│   └── validate-workflow.md
├── agents/workflow/
│   ├── workflow-creator.md
│   ├── phase-executor.md
│   └── workflow-validator.md
└── templates/
    └── phase-template.md
```

If any file is missing, report which files are missing and fail the phase.

### Step 2: Create Backup Directory
If BACKUP_ENABLED is true:
- Create directory: `$PROJECT_ROOT/.claude/backups/fix-inconsistencies-YYYYMMDD-HHMMSS/`
- Use current timestamp for unique identification

If DRY_RUN is true:
- Report: "Would create backup directory at [path]"
- Continue without creating

### Step 3: Backup All Target Files
Copy these 12 files to the backup directory (preserving directory structure):

**Schemas (2 files)**:
- `.claude/schemas/workflow-schema.yaml`
- `.claude/schemas/phase-metadata-schema.yaml`

**Documentation (3 files)**:
- `.claude/docs/INTRODUCTION.md`
- `.claude/docs/SPECIFICATION.md`
- `.claude/docs/REFERENCE.md`

**Commands (3 files)**:
- `.claude/commands/create-workflow.md`
- `.claude/commands/run-workflow.md`
- `.claude/commands/validate-workflow.md`

**Agents (3 files)**:
- `.claude/agents/workflow/workflow-creator.md`
- `.claude/agents/workflow/phase-executor.md`
- `.claude/agents/workflow/workflow-validator.md`

**Templates (1 file)**:
- `.claude/templates/phase-template.md`

### Step 4: Generate Backup Manifest
Create `backup-manifest.yaml` with:
```yaml
backup_created: "YYYY-MM-DDTHH:MM:SSZ"
backup_directory: "[full path]"
workflow_version: "1.0.0"
files_backed_up:
  - original: "[path]"
    backup: "[backup path]"
    sha256: "[checksum]"
  # ... for each file
total_files: 12
```

### Step 5: Verify Backup Integrity
For each backed up file:
- Verify file exists in backup location
- Compare checksums to ensure exact copy
- Report any discrepancies

## Outputs
- Backup directory with all 12 files (if BACKUP_ENABLED)
- `backup-manifest.yaml` documenting all backups
- BACKUP_DIR parameter for potential rollback
- FILES_TO_MODIFY count (12)

## Success Criteria
- [ ] All 12 target files verified to exist
- [ ] Backup directory created (if enabled)
- [ ] All files copied to backup (if enabled)
- [ ] Backup manifest generated
- [ ] All checksums verified (if enabled)

## Error Handling
- **Missing file**: Report which file is missing, suggest checking PROJECT_ROOT
- **Permission denied**: Report permission issue, suggest running with appropriate access
- **Disk space**: Check available space before backup, warn if < 10MB free
- **Checksum mismatch**: Retry copy, if still fails abort with details

## Rollback Plan
This is the preparation phase - no rollback needed.
If subsequent phases fail, backups can be used to restore original state.

## Notes
- Backup manifest serves as audit trail
- Checksums enable verification even after workflow completes
- Timestamp in directory name allows multiple runs without conflict
