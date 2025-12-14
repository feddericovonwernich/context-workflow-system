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

Parameters flow unidirectionally: **CLI Args → Env Vars → workflow.yaml → Phase Outputs → Next Phases**

See `.claude/docs/SPECIFICATION.md` lines 273-279 for complete resolution priority order.

### Workflow Structure

Minimum requirements:
- At least 2 phase files (can start with `00` or `01`)
- Sequential numbering with no gaps
- Phase files have YAML frontmatter with metadata contract

See `.claude/docs/SPECIFICATION.md` lines 44-98 for complete file structure requirements.

## Common Development Commands

### Testing Workflows

```bash
# Validate workflow structure and compliance
/validate-workflow .claude/workflows/<workflow-name>

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
```

## Documentation Navigation

### Core Documentation (Read First)
- **`.claude/docs/SPECIFICATION.md`** - Authoritative specification - All components must conform to this
- **`.claude/docs/INTRODUCTION.md`** - Comprehensive conceptual overview and design rationale
- **`.claude/docs/REFERENCE.md`** - Quick reference card for syntax and structure

**Documentation Hierarchy**: SPECIFICATION.md is authoritative. If docs conflict, SPECIFICATION.md is correct.

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

Key metadata fields: `inputs.files`, `inputs.parameters`, `outputs.files`, `outputs.parameters`, `success_criteria`

See SPECIFICATION.md lines 169-217 for complete phase metadata schema.

### Parallel Execution

For phases that process multiple items in parallel, use `execution_mode: parallel` with `parallel_config`. The orchestrator launches one agent per work item and aggregates results.

See SPECIFICATION.md lines 472-508 for complete parallel execution configuration.

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

See SPECIFICATION.md lines 314-343 for complete details.

### Phase 00 Special Semantics

Phase 00 is reserved for setup/discovery:
- Parameter initialization
- Environment validation
- Dynamic workflow configuration
- Optional - not all workflows need it

### Parameter Discovery Pattern

Phases can discover new parameters during execution and pass them forward via the phase completion report. The orchestrator writes these to `runtime-parameters.yaml` for subsequent phases.

See SPECIFICATION.md lines 346-378 for phase completion protocol.

### Execution Modes

- **Sequential Mode** (default): One agent executes entire phase
- **Parallel Mode** (via `parallel_config`): Orchestrator launches multiple agents simultaneously, one per work item

## Key Design Principles

Understanding these principles helps when extending the system:

1. **Separation of Concerns**: Generation ≠ Execution ≠ Validation
2. **Explicit over Implicit**: All dependencies declared in metadata
3. **Isolation by Default**: No shared state between phases
4. **Progressive Disclosure**: Simple workflows → Complex workflows
5. **Fail-Safe Design**: Clear error handling and rollback procedures
6. **Documentation-Driven**: Specs drive implementation, not vice versa

## Validation Severity Levels

- **ERROR**: Violations of SPECIFICATION.md rules - workflow cannot execute
- **WARNING**: Deviations from best practices - workflow may have issues
- **INFO**: Suggestions for improvement - workflow will work but could be better

Always fix ERRORs before running workflows. See SPECIFICATION.md lines 1017-1040 for complete severity definitions.

## Future Features (Not Yet Implemented)

These are documented in SPECIFICATION.md but NOT implemented:
- Phase groups (concurrent phase execution)
- Dynamic phase generation
- Cross-workflow dependencies

Do not implement or reference these features - they're reserved for future versions.
