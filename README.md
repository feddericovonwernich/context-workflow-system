# Context Workflow System

A reusable workflow orchestration framework for Claude Code agents. This system enables the creation and execution of multi-phase, agent-based workflows with isolated execution contexts, explicit parameter contracts, and full traceability.

## Overview

The Context Workflow System provides:

- **Intelligent Workflow Generation**: Automatically create structured workflows from specifications, requirements, or documentation
- **Agent-Based Execution**: Each phase runs in an isolated agent context with explicit inputs/outputs
- **Full Traceability**: Complete audit trail of decisions, parameters, and outputs
- **Constitutional Compliance**: Built-in validation against architectural principles
- **Progressive Enhancement**: Workflows evolve from simple to complex through iterative refinement

## Installation

Copy the `.claude/` directory contents to your project's `.claude/` directory:

```bash
# Clone this repository
git clone https://github.com/feddericovonwernich/context-workflow-system.git

# Copy to your project
cp -r context-workflow-system/.claude/* your-project/.claude/
```

## Directory Structure

```
.claude/
├── commands/                    # Slash commands
│   ├── create-workflow.md       # Generate workflows from input files
│   ├── run-workflow.md          # Execute multi-phase workflows
│   └── validate-workflow.md     # Validate workflow structure
├── agents/
│   └── workflow/                # Workflow system agents
│       ├── workflow-creator.md  # Master workflow generator
│       ├── phase-executor.md    # Isolated phase execution
│       └── workflow-validator.md # Workflow validation
├── docs/                        # Documentation
│   ├── INTRODUCTION.md          # Comprehensive system overview
│   ├── SPECIFICATION.md         # Formal specification and schemas
│   └── REFERENCE.md             # Quick reference card
├── schemas/                     # YAML schemas
│   ├── workflow-schema.yaml     # Workflow configuration schema
│   └── phase-metadata-schema.yaml # Phase metadata schema
└── templates/
    └── phase-template.md        # Base template for phase files
```

## Usage

### Creating a Workflow

Use the `/create-workflow` command to generate a workflow from input files:

```
/create-workflow
```

The system will analyze your input files and generate a complete workflow structure.

### Running a Workflow

Execute a workflow with the `/run-workflow` command:

```
/run-workflow .claude/workflows/my-workflow
```

### Validating a Workflow

Validate workflow structure and metadata:

```
/validate-workflow .claude/workflows/my-workflow
```

## Core Concepts

### Workflows

A workflow is a collection of ordered phases that accomplish a complex objective:

```
workflow-directory/
├── workflow.yaml           # Metadata and parameter definitions
├── README.md               # Human-readable documentation
├── phase-00-*.md           # Optional setup/discovery phase
├── phase-01-*.md           # First execution phase
├── phase-02-*.md           # Subsequent phases
└── examples/
    └── parameters.yaml     # Example parameter sets
```

### Phases

A phase is an atomic unit of work with:
- **Clear Objective**: Single, well-defined goal
- **Explicit Dependencies**: Declared inputs and prerequisites
- **Isolated Execution**: Runs in clean agent context
- **Measurable Outputs**: Files, parameters, or state changes
- **Success Criteria**: Verifiable completion conditions

### Phase Metadata

Each phase file contains a metadata section defining its contract:

```yaml
---
phase_metadata:
  inputs:
    files:
      - name: INPUT_FILE
        required: true
        description: "Source file to process"
    parameters:
      - name: OUTPUT_DIR
        required: true
        description: "Where to store results"
  outputs:
    files:
      - path: "$OUTPUT_DIR/report.md"
        description: "Analysis report"
    parameters:
      - name: RESULT_STATUS
        description: "Processing result status"
---
```

## Documentation

For detailed documentation, see:

- [Introduction](/.claude/docs/INTRODUCTION.md) - Comprehensive system overview
- [Specification](/.claude/docs/SPECIFICATION.md) - Formal specification and schemas
- [Reference](/.claude/docs/REFERENCE.md) - Quick reference card

## License

MIT License
