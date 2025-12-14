# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **workflow orchestration framework for Claude Code agents**. It transforms Claude from a conversational AI into an orchestrated workflow engine that can execute complex, multi-phase processes with full traceability and isolated execution contexts.

The framework is designed to be installed into any repository and provides:
- Intelligent workflow generation from requirements/specifications
- Agent-based execution with isolated phase contexts
- Explicit parameter contracts and dependency management
- Built-in validation against architectural principles

## Core Architecture

### Three-Layer Agent Orchestration

The system implements a strict three-layer architecture:

```
User Commands (Slash Commands)
        ↓
Orchestrator Layer (/run-workflow command)
        ↓
Isolated Agent Execution (phase-executor agents)
```

**Critical Constraint: NO NESTED AGENT EXECUTION**
- Agents CANNOT invoke other agents (strictly enforced)
- Only the orchestrator launches agents via the Task tool
- Phases execute in complete isolation
- This ensures predictable execution and debuggability

### Phase Isolation Pattern

Each phase receives ONLY:
- Explicitly declared input files (via phase metadata)
- Resolved parameter values
- Phase instructions (markdown content)
- Expected output specifications

Phases CANNOT access:
- Conversation history from previous phases
- Other phase outputs (unless explicitly declared in metadata)
- Undeclared parameters
- Implicit context

This isolation is fundamental to reproducibility and traceability.

### Parameter Flow Architecture

Parameters flow unidirectionally through the system:

```
CLI Args → Env Vars → workflow.yaml → Phase Outputs → Next Phases
```

Resolution priority (highest to lowest):
1. Command-line arguments (`/run-workflow <dir> --param=value`)
2. Environment variables (prefixed with `WORKFLOW_*`)
3. Previous phase outputs (stored in `runtime-parameters.yaml`)
4. `workflow.yaml` defaults
5. Phase metadata defaults

### Workflow Structure

Workflows are declarative, multi-phase processes:

```
.claude/workflows/<name>/
├── workflow.yaml              # Configuration, parameters, metadata
├── README.md                  # Human-readable documentation
├── phase-00-*.md             # Optional: Setup/discovery phase
├── phase-01-*.md             # First execution phase (required)
├── phase-02-*.md             # Subsequent phases (at least one more)
├── runtime-parameters.yaml   # Generated: Parameter state tracking
└── execution.log             # Generated: Execution audit trail
```

**Minimum Requirements:**
- At least 2 phase files (can start with `00` or `01`)
- Sequential numbering with no gaps
- Phase files have YAML frontmatter with metadata contract

## Common Development Commands

### Testing Workflows

```bash
# Validate workflow structure and compliance
/validate-workflow .claude/workflows/<workflow-name>

# Validate with strict mode (more rigorous checks)
/validate-workflow .claude/workflows/<workflow-name> --mode=strict

# Run a workflow
/run-workflow .claude/workflows/<workflow-name>

# Run with custom parameters
/run-workflow .claude/workflows/<workflow-name> --param1=value --param2=value
```

### Creating Workflows

```bash
# Generate a workflow from input files (specs, requirements, docs)
/create-workflow

# The workflow-creator agent will analyze your files and generate:
# - workflow.yaml (configuration)
# - phase-*.md files (execution phases)
# - README.md (documentation)
```

### Installation

```bash
# Quick install into any repository
curl -sSL https://raw.githubusercontent.com/feddericovonwernich/context-workflow-system/main/install.sh | bash

# Preview changes without installing
./install.sh --dry-run

# Install from specific branch
./install.sh --branch develop

# Force overwrite without backups
./install.sh --force
```

## Critical Files and Their Purposes

### Documentation (Read These First)
- `.claude/docs/SPECIFICATION.md` - **Authoritative specification** (724 lines) - All components must conform to this
- `.claude/docs/INTRODUCTION.md` - Comprehensive conceptual overview (685 lines)
- `.claude/docs/REFERENCE.md` - Quick reference card (236 lines)

### Commands (User Entry Points)
- `.claude/commands/create-workflow.md` - Generates workflows from input files using AI
- `.claude/commands/run-workflow.md` - **Main orchestrator** - Executes multi-phase workflows
- `.claude/commands/validate-workflow.md` - Validates workflow structure and metadata

### Agents (Specialized Execution Contexts)
- `.claude/agents/workflow/workflow-creator.md` - Analyzes requirements and generates complete workflows
- `.claude/agents/workflow/phase-executor.md` - **Isolated executor** - Runs individual phases in clean context
- `.claude/agents/workflow/workflow-validator.md` - Validates against SPECIFICATION.md rules

### Schemas (Validation)
- `.claude/schemas/workflow-schema.yaml` - Validates `workflow.yaml` structure
- `.claude/schemas/phase-metadata-schema.yaml` - Validates phase file metadata sections

### Templates
- `.claude/templates/phase-template.md` - Base template for generating new phase files

## Working with Workflows

### Modifying Existing Workflows

When editing workflows, ensure:

1. **Phase metadata contract matches content**:
   - If phase content references a file, declare it in `inputs.files`
   - If phase creates output, declare it in `outputs.files`
   - If phase uses/creates parameters, declare them

2. **Sequential phase numbering**:
   - No gaps allowed (01, 02, 03... OR 00, 01, 02...)
   - At least 2 phase files required

3. **Phase completion protocol**:
   - Phases must output structured YAML completion reports
   - Include status, outputs_created, parameters_discovered, errors

4. **Validation before execution**:
   ```bash
   /validate-workflow .claude/workflows/<name>
   ```

### Creating New Phases

Use the template:
```bash
cp .claude/templates/phase-template.md .claude/workflows/<name>/phase-XX-<name>.md
```

Key metadata fields:
- `inputs.files` - Files this phase reads
- `inputs.parameters` - Parameters this phase requires
- `outputs.files` - Files this phase creates
- `outputs.parameters` - Parameters this phase discovers/generates
- `success_criteria` - Verifiable completion conditions
- `phase_type` - One of: setup, execution, validation, finalization

### Parallel Execution

For phases that need to process multiple items in parallel:

```yaml
parallel_config:
  enabled: true
  work_items_parameter: FEATURE_FILES  # Parameter containing array of items
  max_concurrency: 3
  results_aggregation: merge  # or: collect, first_success
```

The orchestrator will launch one agent per work item and aggregate results.

## Non-Obvious Patterns

### Template vs Runtime Parameters

**Template placeholders** (`${VARIABLE}`):
- Used during workflow GENERATION (in phase-template.md)
- Replaced by workflow-creator agent
- Never appear in final workflow files

**Runtime parameters** (`$PARAM` or `${PARAM}`):
- Resolved during workflow EXECUTION
- Interpolated by orchestrator before phase execution
- Stored in runtime-parameters.yaml

### Phase 00 Special Semantics

Phase 00 is reserved for setup/discovery:
- Parameter initialization
- Environment validation
- Dynamic workflow configuration
- Optional - not all workflows need it

### Parameter Discovery Pattern

Phases can discover new parameters during execution and pass them forward:

```yaml
phase_completion:
  parameters_discovered:
    NEW_PARAM: "discovered-value"
```

The orchestrator writes these to `runtime-parameters.yaml` for subsequent phases.

### Execution Modes

**Sequential Mode** (default):
- One agent executes entire phase
- Standard workflow execution

**Parallel Mode** (via `parallel_config`):
- Orchestrator launches multiple agents simultaneously
- One agent per work item
- Results aggregated by orchestrator

## Validation Severity Levels

The validator reports issues at three levels:

- **ERROR**: Violations of SPECIFICATION.md rules - workflow cannot execute
- **WARNING**: Deviations from best practices - workflow may have issues
- **INFO**: Suggestions for improvement - workflow will work but could be better

Always fix ERRORs before running workflows.

## Documentation Hierarchy

When resolving questions:

1. **SPECIFICATION.md** - Authoritative source for all rules and schemas
2. **INTRODUCTION.md** - Conceptual explanations and design rationale
3. **REFERENCE.md** - Quick lookups for syntax and structure
4. **README.md** - User-facing overview and installation

If SPECIFICATION.md and other docs conflict, SPECIFICATION.md is correct.

## Key Design Principles

Understanding these principles helps when extending the system:

1. **Separation of Concerns**: Generation ≠ Execution ≠ Validation
2. **Explicit over Implicit**: All dependencies declared in metadata
3. **Isolation by Default**: No shared state between phases
4. **Progressive Disclosure**: Simple workflows → Complex workflows
5. **Fail-Safe Design**: Clear error handling and rollback procedures
6. **Documentation-Driven**: Specs drive implementation, not vice versa

## Future Features (Not Yet Implemented)

These are documented in SPECIFICATION.md but NOT implemented:
- Phase groups (concurrent phase execution)
- Dynamic phase generation
- Cross-workflow dependencies
- Conditional phase execution

Do not implement or reference these features - they're reserved for future versions.
