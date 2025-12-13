---
phase_metadata:
  execution_mode: sequential

  inputs:
    parameters:
      - name: PROJECT_ROOT
        required: true
        description: "Root directory of the context-workflow-system project"
      - name: DRY_RUN
        required: false
        default: false
        description: "Show changes without applying"

  outputs:
    files:
      - path: "$PROJECT_ROOT/.claude/docs/INTRODUCTION.md"
        description: "Fixed INTRODUCTION.md (file structure, agent types, workflow types)"
      - path: "$PROJECT_ROOT/.claude/docs/SPECIFICATION.md"
        description: "Fixed SPECIFICATION.md (runtime parameters filename)"
      - path: "$PROJECT_ROOT/.claude/commands/validate-workflow.md"
        description: "Fixed validate-workflow.md (command reference)"
    parameters:
      - name: CROSSREF_FIXES_APPLIED
        description: "Number of cross-reference fixes applied"
        type: integer

  preferred_agent: phase-executor
---

# Phase 3: Documentation Cross-References

**Purpose**: Fix all cross-reference errors between documentation files, ensuring consistency in file paths, agent lists, workflow types, and parameter file names.

## Prerequisites
- Phase 2 completed successfully (schema harmonization done)
- Documentation files are accessible and writable

## Tasks for Todo List
1. Fix runtime parameters file name inconsistency
2. Fix INTRODUCTION.md file structure diagram
3. Add validate-workflow to INTRODUCTION.md commands list
4. Fix agent types list in INTRODUCTION.md
5. Fix workflow types list in INTRODUCTION.md
6. Fix command reference in validate-workflow.md

## Parameters Used
- `PROJECT_ROOT`: Base directory for all file operations
- `DRY_RUN`: If true, only show what would change

## Process

### Step 1: Standardize Runtime Parameters Filename (Finding #8)

**Decision**: Use `runtime-parameters.yaml` (more descriptive, matches SPECIFICATION.md main reference)

**File 1**: `$PROJECT_ROOT/.claude/docs/SPECIFICATION.md`

**Location**: Lines 51-54 (File Structure Requirements section)

**Current (INCONSISTENT)**:
```markdown
├── parameters.yaml        # GENERATED: Runtime parameters
```

**Replace with**:
```markdown
├── runtime-parameters.yaml  # GENERATED: Runtime parameters
```

**File 2**: `$PROJECT_ROOT/.claude/commands/run-workflow.md`

**Location**: Line 57

**Current (INCONSISTENT)**:
```markdown
├── parameters.yaml        # Generated runtime parameters
```

**Replace with**:
```markdown
├── runtime-parameters.yaml  # Generated runtime parameters
```

**Also in run-workflow.md**, search for any other occurrences of `parameters.yaml` that refer to runtime parameters and update them to `runtime-parameters.yaml`. Exception: `examples/parameters.yaml` is a different file and should NOT be changed.

### Step 2: Fix INTRODUCTION.md File Structure (Finding #20)

**File**: `$PROJECT_ROOT/.claude/docs/INTRODUCTION.md`

**Location**: Lines 625-640 (Quick Reference - File Structure section)

**Current (INCORRECT)**:
```markdown
### File Structure

```
.claude/
├── commands/
│   ├── create-workflow.md
│   └── run-workflow.md
├── workflows/
│   └── <workflow-name>/
│       ├── workflow.yaml
│       ├── README.md
│       ├── phase-*.md
│       └── examples/
└── templates/
    └── workflows/
        ├── phase-template.md
        └── *-workflow-template.yaml
```
```

**Replace with (CORRECT)**:
```markdown
### File Structure

```
.claude/
├── commands/
│   ├── create-workflow.md
│   ├── run-workflow.md
│   └── validate-workflow.md
├── agents/workflow/
│   ├── workflow-creator.md
│   ├── phase-executor.md
│   └── workflow-validator.md
├── docs/
│   ├── INTRODUCTION.md
│   ├── SPECIFICATION.md
│   └── REFERENCE.md
├── schemas/
│   ├── workflow-schema.yaml
│   └── phase-metadata-schema.yaml
├── templates/
│   └── phase-template.md
└── workflows/
    └── <workflow-name>/
        ├── workflow.yaml
        ├── README.md
        ├── phase-*.md
        ├── runtime-parameters.yaml
        └── examples/
```
```

### Step 3: Fix Agent Types List (Finding #11)

**File**: `$PROJECT_ROOT/.claude/docs/INTRODUCTION.md`

**Location**: Lines 644-646 (Quick Reference - Agent Types section)

**Current (INCOMPLETE)**:
```markdown
### Agent Types

- **workflow-creator**: Generates workflows from requirements
- **phase-executor**: Executes individual phases in isolation
```

**Replace with (COMPLETE)**:
```markdown
### Agent Types

- **workflow-creator**: Analyzes input files and generates complete multi-phase workflows
- **phase-executor**: Executes individual workflow phases in isolated context
- **workflow-validator**: Validates workflow structure, metadata, and documentation coherence
```

### Step 4: Fix Workflow Types List (Finding #5 continued)

**File**: `$PROJECT_ROOT/.claude/docs/INTRODUCTION.md`

**Location**: Lines 649-655 (Quick Reference - Workflow Types section)

**Current (INCOMPLETE)**:
```markdown
### Workflow Types

- `deployment` - Application deployment workflows
- `testing` - Quality assurance workflows
- `migration` - Data/schema migration workflows
- `build` - Build and packaging workflows
- `data-processing` - ETL and analysis workflows
```

**Replace with (COMPLETE)**:
```markdown
### Workflow Types

- `deployment` - Application deployment workflows
- `testing` - Quality assurance workflows
- `migration` - Data/schema migration workflows
- `build` - Build and packaging workflows
- `data-processing` - ETL and analysis workflows
- `requirements-processing` - Requirements analysis and transformation workflows
- `technical-planning` - Technical design and planning workflows
- `setup` - Environment setup and initialization workflows
- `automation` - General automation and orchestration workflows
```

### Step 5: Fix Command Reference (Finding #9)

**File**: `$PROJECT_ROOT/.claude/commands/validate-workflow.md`

**Location**: Lines 267-271 (See Also section)

**Current (INCORRECT)**:
```markdown
## See Also

- `create-workflow`: Generate workflows
- `workflow`: Execute workflows
- `.claude/workflows/INTRODUCTION.md`: System overview
- `.claude/agents/workflow/workflow-validator.md`: Validator details
```

**Replace with (CORRECT)**:
```markdown
## See Also

- `create-workflow`: Generate workflows from input files
- `run-workflow`: Execute multi-phase workflows
- `.claude/docs/INTRODUCTION.md`: System overview
- `.claude/docs/SPECIFICATION.md`: Formal specification
- `.claude/agents/workflow/workflow-validator.md`: Validator agent details
```

### Step 6: Update create-workflow.md Workflow Types (Finding #5 continued)

**File**: `$PROJECT_ROOT/.claude/commands/create-workflow.md`

**Location**: Line 27

**Current (INCOMPLETE)**:
```markdown
- `--type`: Optional workflow type hint (deployment/testing/migration/build/data-processing)
```

**Replace with (COMPLETE)**:
```markdown
- `--type`: Optional workflow type hint (deployment|testing|migration|build|data-processing|requirements-processing|technical-planning|setup|automation)
```

## Outputs
- Updated INTRODUCTION.md with correct file structure, agent types, and workflow types
- Updated SPECIFICATION.md with consistent filename
- Updated run-workflow.md with consistent filename
- Updated validate-workflow.md with correct command references
- Updated create-workflow.md with complete workflow types
- CROSSREF_FIXES_APPLIED = 6

## Success Criteria
- [ ] All references to runtime parameters file use `runtime-parameters.yaml`
- [ ] INTRODUCTION.md file structure accurately reflects actual project structure
- [ ] All 3 agent types listed in INTRODUCTION.md
- [ ] All 9 workflow types listed consistently across all documents
- [ ] validate-workflow.md references `run-workflow` not `workflow`
- [ ] All file path references are correct

## Error Handling
- **Section not found**: Report expected content and actual content at location
- **Multiple matches**: Identify each match location and update all appropriately
- **File not found**: Verify file exists at expected path

## Rollback Plan
Restore documentation files from Phase 0 backup:
```bash
cp $BACKUP_DIR/.claude/docs/* $PROJECT_ROOT/.claude/docs/
cp $BACKUP_DIR/.claude/commands/validate-workflow.md $PROJECT_ROOT/.claude/commands/
cp $BACKUP_DIR/.claude/commands/create-workflow.md $PROJECT_ROOT/.claude/commands/
```

## Notes
- Cross-reference consistency is essential for usability
- Users following documentation should not encounter "file not found" errors
- Consistent naming reduces cognitive load
