# Workflow System Specification v1.0

This document is the authoritative specification for the Claude Workflow Orchestration System. All components (commands, agents, workflows) must conform to these specifications.

## Table of Contents
1. [System Architecture](#system-architecture)
2. [File Structure Requirements](#file-structure-requirements)
3. [Workflow Configuration Schema](#workflow-configuration-schema)
4. [Phase Metadata Schema](#phase-metadata-schema)
5. [Parameter Specifications](#parameter-specifications)
6. [Execution Modes](#execution-modes)
7. [Validation Rules](#validation-rules)
8. [Agent Constraints](#agent-constraints)

## System Architecture

### Core Components
- **Workflow Orchestrator**: Main execution engine (`run-workflow` command)
- **Workflow Creator**: Generates workflows from requirements (`create-workflow` command)
- **Phase Executor**: Isolated agent executing individual phases
- **Workflow Validator**: Validates workflow structure and metadata (`validate-workflow` command)

### Execution Flow
```
User → Command → Orchestrator → Phase Loop → Agent Execution → Output Collection
```

### Critical Architectural Constraints
1. **No Nested Agent Execution**: Agents CANNOT invoke other agents
2. **Phase Isolation**: Each phase executes in isolated context
3. **Explicit Dependencies**: All inputs/outputs must be declared
4. **Parameter Flow**: Parameters flow forward through phases

## File Structure Requirements

### Directory Layout
```
workflow-directory/
├── workflow.yaml           # REQUIRED: Workflow configuration
├── README.md              # RECOMMENDED: Human documentation
├── phase-00-*.md          # OPTIONAL: Setup/discovery phase
├── phase-01-*.md          # REQUIRED: First execution phase
├── phase-02-*.md          # REQUIRED: At least one more phase
├── phase-NN-*.md          # OPTIONAL: Additional phases
├── parameters.yaml        # GENERATED: Runtime parameters
├── execution.log          # GENERATED: Execution log
└── examples/              # OPTIONAL: Example configurations
    └── parameters.yaml    # Example parameter sets
```

### File Naming Conventions

#### Phase Files
- **Pattern**: `phase-XX-<descriptive-name>.md`
- **Rules**:
  - Must start with `phase-`
  - Followed by two-digit number (00-99)
  - Hyphen separator
  - Descriptive lowercase name (kebab-case)
  - Must end with `.md`
- **Examples**:
  - ✅ `phase-00-setup.md`
  - ✅ `phase-01-feature-extraction.md`
  - ❌ `phase-1-test.md` (single digit)
  - ❌ `Phase-01-Test.md` (uppercase)

#### Phase Numbering
- **Sequential**: No gaps allowed (01, 02, 03...)
- **Starting**: Must start with 00 or 01
- **Special**: Phase 00 reserved for setup/discovery

## Workflow Configuration Schema

### workflow.yaml Structure

```yaml
# REQUIRED FIELDS
name: string                    # Workflow identifier (kebab-case)
description: string             # Human-readable description
version: string                 # Semantic version (X.Y.Z)

# OPTIONAL SECTIONS
parameters:                     # Parameter definitions
  <parameter_name>:            # Or array format (see below)
    type: string               # string|boolean|integer|enum|file|directory
    required: boolean          # Is parameter required?
    description: string        # Human-readable description
    default: any              # Default value (type must match)
    enum: array               # Valid values (if type=enum)
    example: any              # Example value

phases:                        # Phase execution configuration
  require_confirmation: boolean  # Confirm before each phase (default: false)
  allow_retry: boolean          # Allow phase retry on failure (default: true)
  generate_logs: boolean        # Create execution.log (default: true)
  stop_on_failure: boolean      # Halt on phase failure (default: true)
  parallel_execution_supported: boolean  # Workflow supports parallel phases (default: false)

metadata:                      # Workflow metadata
  generated_from: array        # Source files used for generation
  generated_date: string       # ISO date of generation
  workflow_type: string        # deployment|testing|migration|build|data-processing
  complexity: string           # simple|medium|complex
  supported_agents: array      # List of specialized agents used
  architecture_notes: array    # Important architectural constraints
```

### Parameter Array Format
Parameters can also be defined as an array:
```yaml
parameters:
  - name: environment
    type: string
    required: true
    description: "Target environment"
    enum: ["dev", "staging", "prod"]
```

## Phase Metadata Schema

### Required Structure
Every phase file MUST begin with a YAML frontmatter section:

```yaml
---
phase_metadata:
  # Optional: Execution mode configuration
  execution_mode: string       # sequential (default) | parallel
  
  # Required for parallel execution
  parallel_config:
    agent_type: string         # Specialized agent to use
    discovery_pattern: string  # Glob pattern to find work items
    work_item_parameter: string # Parameter name for work item
    output_pattern: string     # Output path pattern with {placeholders}
    max_parallel: number|string # Max concurrent agents (0=unlimited, can be parameter reference)
  
  # Input specifications
  inputs:
    files:                     # Input file specifications
      - name: string          # Parameter name for file
        required: boolean     # Is this file required?
        path: string          # Optional: explicit path (can use parameters)
        description: string   # What this file contains
    
    parameters:               # Input parameter specifications
      - name: string         # Parameter name
        required: boolean    # Is this parameter required?
        default: any         # Optional: default value
        description: string  # Parameter purpose
  
  # Output specifications
  outputs:
    files:                   # Output file specifications
      - path: string        # Path where file will be created (can use parameters)
        description: string # What this file contains
    
    parameters:             # Output parameter specifications
      - name: string       # Parameter name for next phases
        description: string # What this parameter represents
  
  # Optional: Agent preferences
  preferred_agent: string   # Hint for orchestrator agent selection
---
```

### Parameter Interpolation
- Use `$PARAMETER_NAME` or `${PARAMETER_NAME}` in paths
- Parameters resolved from workflow.yaml, CLI, and previous phases
- Example: `path: "$OUTPUT_DIR/$SPECS_DIR/report.md"`

## Parameter Specifications

### Parameter Types

| Type | Description | Example | Validation |
|------|-------------|---------|------------|
| `string` | Text value | `"production"` | Any string |
| `boolean` | True/false | `true` | true/false only |
| `integer` | Whole number | `42` | Integer only |
| `enum` | Restricted choice | `"prod"` | Must match enum list |
| `file` | File path | `"./config.yaml"` | File should exist |
| `directory` | Directory path | `"./outputs"` | Directory should exist |

### Parameter Resolution Order
1. Command-line arguments (highest priority)
2. Environment variables (WORKFLOW_PARAM_NAME)
3. Previous phase outputs (runtime-parameters.yaml)
4. Default values in workflow.yaml
5. Default values in phase metadata

### Parameter Naming Conventions
- **Format**: UPPER_SNAKE_CASE for consistency
- **Examples**: `OUTPUT_DIR`, `MAX_RETRIES`, `ENABLE_LOGGING`
- **Reserved**: Avoid `PHASE_`, `WORKFLOW_`, `SYSTEM_` prefixes

## Execution Modes

### Sequential Execution (Default)
```yaml
phase_metadata:
  execution_mode: sequential  # Or omit for default
```
- Single agent executes phase
- Processes all work in sequence
- Standard phase-executor agent

### Parallel Execution
```yaml
phase_metadata:
  execution_mode: parallel
  parallel_config:
    agent_type: feature-specifier
    discovery_pattern: "$OUTPUT_DIR/features/FEAT-*.md"
    work_item_parameter: FEATURE_FILE
    output_pattern: "$OUTPUT_DIR/specs/SPEC-{number}-{name}/spec.md"
    max_parallel: 5
```
- Multiple agents execute concurrently
- One agent per discovered work item
- Orchestrator manages parallelization
- Results aggregated after completion

### Parallel Configuration Fields

| Field | Required | Description |
|-------|----------|-------------|
| `agent_type` | Yes | Specialized agent for the task |
| `discovery_pattern` | Yes | Glob pattern to find work items |
| `work_item_parameter` | Yes | Parameter name passed to each agent |
| `output_pattern` | No | Expected output path pattern |
| `max_parallel` | No | Maximum concurrent agents (0=unlimited) |

## Validation Rules

### Structural Validation

#### Required Elements
- [ ] workflow.yaml exists and is valid YAML
- [ ] At least two phase files exist (phase-01, phase-02)
- [ ] Phase files follow naming convention
- [ ] Sequential numbering without gaps

#### Recommended Elements
- [ ] README.md documentation exists
- [ ] Examples directory with sample parameters
- [ ] Phase 00 for parameter discovery (if needed)

### Metadata Validation

#### workflow.yaml Requirements
- [ ] `name` field present and valid (kebab-case)
- [ ] `description` field present and non-empty
- [ ] `version` field present and valid semver
- [ ] All parameters have required fields
- [ ] Parameter types are valid
- [ ] Default values match declared types

#### Phase Metadata Requirements
- [ ] phase_metadata section present (WARNING if missing)
- [ ] All required input parameters defined
- [ ] Output paths use valid parameter interpolation
- [ ] Parallel config complete if execution_mode=parallel

### Content Validation

#### Phase File Structure
Required sections in order:
1. Phase metadata (YAML frontmatter)
2. `# Phase N: Title` heading
3. `**Purpose**:` statement
4. `## Prerequisites` section
5. `## Tasks for Todo List` section
6. `## Process` section with steps
7. `## Outputs` section
8. `## Success Criteria` section
9. `## Error Handling` section

### Cross-File Validation

#### Parameter Flow
- [ ] Workflow parameters available to all phases
- [ ] Phase output parameters available to subsequent phases
- [ ] No undefined parameter references
- [ ] No orphaned parameters

#### Dependency Chain
- [ ] Input files reference available outputs
- [ ] No circular dependencies
- [ ] File paths are valid
- [ ] Required files generated before use

## Agent Constraints

### Fundamental Limitation
**Agents CANNOT invoke other agents**. This is enforced at the system level:
- Task tool not available within agents
- No `claude -p` commands allowed
- No nested execution possible
- Ensures system stability

### Design Implications
1. **Sequential Phases**: Break complex work into multiple phases
2. **Parallel Within Phase**: Use parallel execution for similar items
3. **Specialized Agents**: Orchestrator selects appropriate agent per phase
4. **No Delegation**: Agents must complete work directly

### Agent Selection
The orchestrator can use different agents for different phases:
- Default: `phase-executor` for isolation
- Specialized: Agent specified in `preferred_agent` field
- Parallel: Agent specified in `parallel_config.agent_type`

## Validation Severity Levels

### ERROR (Blocking)
- Missing workflow.yaml
- Invalid YAML syntax
- No phase files
- Non-sequential phase numbers
- Circular dependencies
- Invalid parameter types

### WARNING (Non-blocking)
- Missing phase_metadata sections
- No README.md
- Undefined parameters used
- Missing recommended sections
- Large phase files (>500 lines)

### INFO (Suggestions)
- Could use parallel execution
- Parameter naming inconsistencies
- Missing examples directory
- Documentation improvements
- Performance optimizations

## Schema Validation

Workflows can be validated against formal schemas:
- `workflow-schema.yaml` - Validates workflow.yaml structure
- `phase-metadata-schema.yaml` - Validates phase metadata
- Use `validate-workflow` command for comprehensive checks

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-01-12 | Initial specification |

## References
- [INTRODUCTION.md](.claude/workflows/INTRODUCTION.md) - Conceptual overview
- [workflow-schema.yaml](.claude/workflows/schemas/workflow-schema.yaml) - Formal schema
- [REFERENCE.md](.claude/workflows/REFERENCE.md) - Quick reference card