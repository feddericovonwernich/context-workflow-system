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

### Terminology

- **Workflow directory**: The folder containing all files for a single workflow (e.g., `.claude/workflows/my-workflow/`)
- **`WORKFLOW_DIR`**: Parameter/variable name referring to the workflow directory path
- **Phase file**: A markdown file defining one phase (e.g., `phase-01-setup.md`)

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
.claude/workflows/<workflow-name>/
├── workflow.yaml           # REQUIRED: Workflow configuration
├── README.md              # RECOMMENDED: Human documentation
├── phase-00-*.md          # OPTIONAL: Setup/discovery phase
├── phase-01-*.md          # REQUIRED: First execution phase
├── phase-02-*.md          # REQUIRED: At least one more phase
├── phase-NN-*.md          # OPTIONAL: Additional phases
├── runtime-parameters.yaml  # GENERATED: Runtime parameters
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
- **Sequential**: No gaps allowed in numbering sequence
- **Starting Options**:
  - Start with `01` for workflows without setup phase
  - Start with `00` for workflows that need setup/discovery
- **Phase 00**: Reserved for setup, discovery, or parameter initialization
  - If present, must be followed by `01`, `02`, etc.
  - Optional - not all workflows need a phase 00
- **Minimum Phases**: At least two phase files required
  - Valid configurations: `phase-01` + `phase-02` OR `phase-00` + `phase-01`
  - Any sequential combination of 2+ phases with no gaps is valid
- **Valid Examples**:
  - `phase-01-*.md`, `phase-02-*.md` (two phases, no setup)
  - `phase-00-*.md`, `phase-01-*.md` (two phases with setup)
  - `phase-00-*.md`, `phase-01-*.md`, `phase-02-*.md` (three phases with setup)
  - `phase-01-*.md`, `phase-02-*.md`, `phase-03-*.md` (three phases, no setup)
- **Invalid Examples**:
  - `phase-01-*.md` only (only one phase - needs at least two)
  - `phase-00-*.md` only (only one phase - needs at least two)
  - `phase-00-*.md`, `phase-02-*.md` (gap - missing 01)
  - `phase-01-*.md`, `phase-03-*.md` (gap - missing 02)

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
    type: string               # string|boolean|integer|number|enum|file|directory|array
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
  workflow_type: string        # deployment|testing|migration|build|data-processing|requirements-processing|technical-planning|setup|automation
  complexity: string           # simple|medium|complex
  supported_agents: array      # List of specialized agents used
  architecture_notes: array    # Important architectural constraints
```

### Field Constraints

| Field | Min Length | Max Length | Format |
|-------|------------|------------|--------|
| `name` | 3 | 50 | kebab-case (`^[a-z][a-z0-9-]*$`) |
| `description` | 10 | 500 | Any text |
| `version` | - | - | Semantic version (`X.Y.Z`) |
| Parameter `description` | 5 | 200 | Any text |
| Phase file `description` | 5 | 200 | Any text |

### Parameter Array Format
Parameters can also be defined as an array:
```yaml
parameters:
  - name: ENVIRONMENT
    type: string
    required: true
    description: "Target environment"
    enum: ["dev", "staging", "prod"]
```

### Phases Configuration Details

#### `parallel_execution_supported`

This boolean flag indicates whether the workflow contains phases that use parallel execution mode. It serves as:

1. **Documentation**: Signals to users that this workflow leverages parallel agent execution
2. **Validation hint**: Validators can check that `execution_mode: parallel` appears in at least one phase when this is `true`
3. **Future use**: May be used by orchestrators to pre-allocate resources for parallel execution

**Note**: This flag is informational. The actual parallel execution is controlled by individual phase metadata (`execution_mode: parallel`), not this workflow-level flag. Setting this to `true` when no phases use parallel mode is a validation warning, not an error.

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
        type: string         # Optional: expected type (string|boolean|integer|number|enum|file|directory|array)
  
  # Output specifications
  outputs:
    files:                   # Output file specifications
      - path: string        # Path where file will be created (can use parameters)
        description: string # What this file contains
        required: boolean   # Whether output must be created (default: true)
    
    parameters:             # Output parameter specifications
      - name: string       # Parameter name for next phases
        description: string # What this parameter represents
        required: boolean   # Whether this parameter is guaranteed to be set (default: true)
        type: string       # Parameter type (string|boolean|integer|number|enum|file|directory|array)
  
  # Optional: Agent preferences
  preferred_agent: string   # Hint for orchestrator agent selection
---
```

### Parameter Interpolation

Parameters can be interpolated in paths and configuration values using two equivalent syntaxes:

**Syntax Options**:
- `$PARAMETER_NAME` - Simple form, works in most cases
- `${PARAMETER_NAME}` - Explicit form, required when parameter is adjacent to other characters

**When to Use Each**:
```yaml
# Simple form (preferred when unambiguous)
path: "$OUTPUT_DIR/report.md"

# Explicit form (required when adjacent to other text)
path: "${OUTPUT_DIR}_backup/report.md"
filename: "${PREFIX}report.md"
```

**Resolution Sources** (in priority order):
1. Command-line arguments
2. Environment variables with `WORKFLOW_` prefix (e.g., `WORKFLOW_OUTPUT_DIR` for parameter `OUTPUT_DIR`)
3. Previous phase outputs (from runtime-parameters.yaml)
4. Default values in workflow.yaml
5. Default values in phase metadata

**Environment Variable Convention**: To pass a parameter via environment variable, prefix the parameter name with `WORKFLOW_`. For example:
- Parameter `OUTPUT_DIR` → Environment variable `WORKFLOW_OUTPUT_DIR`
- Parameter `MAX_RETRIES` → Environment variable `WORKFLOW_MAX_RETRIES`

**Example**:
```yaml
path: "$OUTPUT_DIR/$SPECS_DIR/report.md"
# With OUTPUT_DIR=./outputs and SPECS_DIR=specs
# Resolves to: ./outputs/specs/report.md
```

**Note**: Both syntaxes are functionally equivalent. Use `${}` form when the parameter name would otherwise be ambiguous in context.

## Parameter Specifications

### Parameter Types

| Type | Description | Example | Validation |
|------|-------------|---------|------------|
| `string` | Text value | `"production"` | Any string |
| `boolean` | True/false | `true` | true/false only |
| `integer` | Whole number | `42` | Integer only |
| `number` | Decimal number | `3.14` | Any numeric value |
| `enum` | Restricted choice | `"prod"` | Must match enum list |
| `file` | File path | `"./config.yaml"` | File should exist |
| `directory` | Directory path | `"./outputs"` | Directory should exist |
| `array` | List of values | `["a", "b", "c"]` | Valid JSON/YAML array |

### Parameter Resolution Order
1. Command-line arguments (highest priority)
2. Environment variables with `WORKFLOW_` prefix (e.g., `WORKFLOW_OUTPUT_DIR` for parameter `OUTPUT_DIR`)
3. Previous phase outputs (runtime-parameters.yaml)
4. Default values in workflow.yaml
5. Default values in phase metadata

### Parameter Naming Conventions
- **Format**: UPPER_SNAKE_CASE for consistency
- **Examples**: `OUTPUT_DIR`, `MAX_RETRIES`, `ENABLE_LOGGING`
- **Reserved**: Avoid `PHASE_`, `WORKFLOW_`, `SYSTEM_` prefixes

## Runtime File Specifications

### Phase Completion Protocol

When a phase completes, the executing agent MUST output a structured completion report.

**Format**: YAML block with `phase_completion` root key

**Required Fields**:
- `status`: `SUCCESS` | `FAILURE`
- `outputs_created`: Array of `{path, exists}` objects
- `parameters_discovered`: Object of parameter key-value pairs
- `success_criteria`: Array of `{criterion, met}` objects
- `errors`: Array of error strings (empty if success)

**Optional Fields**:
- `notes`: Array of observation strings - useful observations, warnings, or suggestions for subsequent phases
- `duration_seconds`: Approximate execution time in seconds - used for logging and performance analysis

**Field Details**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `status` | string | Yes | `SUCCESS` or `FAILURE` |
| `outputs_created` | array | Yes | List of `{path, exists}` objects |
| `parameters_discovered` | object | Yes | Key-value pairs (empty `{}` if none) |
| `success_criteria` | array | Yes | List of `{criterion, met}` objects |
| `errors` | array | Yes | Error messages (empty `[]` if success) |
| `notes` | array | No | Observations or warnings |
| `duration_seconds` | integer | No | Execution time for logging |

The orchestrator uses this report to:
1. Validate phase completion
2. Update `runtime-parameters.yaml`
3. Append to `execution.log`
4. Determine whether to proceed or abort

### runtime-parameters.yaml

This file is automatically generated and maintained by the workflow orchestrator during execution.

**Location**: `<workflow-directory>/runtime-parameters.yaml`

**Structure**:
```yaml
generated_at: "2025-01-12T14:30:00Z"  # ISO 8601 timestamp
workflow_run_id: "wf-20250112-143000-abc123"  # Unique run identifier

# Initial parameters from workflow.yaml and CLI
initial:
  OUTPUT_DIR: "./outputs"
  ENVIRONMENT: "production"
  BACKUP: true

# Parameters discovered during phase execution
discovered:
  SPECS_COUNT: 12
  VALIDATION_PASSED: true
  DATABASE_TYPE: "postgresql"

# Current merged state of all parameters
current:
  OUTPUT_DIR: "./outputs"
  ENVIRONMENT: "production"
  BACKUP: true
  SPECS_COUNT: 12
  VALIDATION_PASSED: true
  DATABASE_TYPE: "postgresql"
```

**Update Rules**:
1. Created at workflow start with `initial` and `current` sections
2. After each phase completion, orchestrator merges discovered parameters into `discovered` and `current`
3. `initial` section remains unchanged throughout execution
4. `current` section always reflects the latest merged state
5. Used for parameter resolution in subsequent phases

### execution.log

This file contains a structured log of workflow execution events.

**Location**: `<workflow-directory>/execution.log`

**Format**:
```
[TIMESTAMP] EVENT_TYPE: Event details

EVENT_TYPES:
- PHASE_START: Phase N beginning execution
- PARAMETERS_RESOLVED: Parameters for phase N resolved
- AGENT_LAUNCHED: Agent started for phase N
- AGENT_COMPLETED: Agent finished for phase N
- OUTPUTS_CREATED: Phase N created output files
- PARAMETERS_DISCOVERED: Phase N discovered new parameters
- PHASE_COMPLETE: Phase N completed successfully
- PHASE_FAILED: Phase N failed with error
- PHASE_RETRY: Phase N being retried (attempt number, reason)
- WORKFLOW_COMPLETE: All phases completed successfully
- WORKFLOW_ABORTED: Workflow terminated due to error
```

**Example Log Entries**:
```
[2025-01-12 14:30:00] PHASE_START: Starting phase-01-extraction.md
[2025-01-12 14:30:01] PARAMETERS_RESOLVED: OUTPUT_DIR=./outputs, FEATURES_DIR=./features
[2025-01-12 14:30:02] AGENT_LAUNCHED: phase-executor for phase-01-extraction.md
[2025-01-12 14:31:45] AGENT_COMPLETED: phase-executor completed successfully
[2025-01-12 14:31:46] OUTPUTS_CREATED: Created 3 files: feature-list.json, summary.md, metadata.yaml
[2025-01-12 14:31:46] PARAMETERS_DISCOVERED: FEATURE_COUNT=25, TOTAL_TASKS=127
[2025-01-12 14:31:47] PHASE_COMPLETE: phase-01-extraction.md completed in 1m47s
[2025-01-12 14:31:47] PHASE_START: Starting phase-02-specification.md
```

**Log Event Details**:

| Event Type | Description | Included Information |
|------------|-------------|----------------------|
| `PHASE_START` | Phase execution begins | Phase file name |
| `PARAMETERS_RESOLVED` | Parameters prepared for phase | Resolved parameter values |
| `AGENT_LAUNCHED` | Agent started | Agent type, phase file |
| `AGENT_COMPLETED` | Agent finished | Success/failure status |
| `OUTPUTS_CREATED` | Phase outputs generated | File paths created |
| `PARAMETERS_DISCOVERED` | New parameters found | Parameter names and values |
| `PHASE_COMPLETE` | Phase finished successfully | Duration, outputs summary |
| `PHASE_FAILED` | Phase encountered error | Error message, failure reason |
| `PHASE_RETRY` | Phase being retried | Attempt number, reason |
| `WORKFLOW_COMPLETE` | All phases succeeded | Total duration, summary |
| `WORKFLOW_ABORTED` | Workflow stopped early | Reason, last completed phase |

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
6. `## Parameters Used` section
7. `## Process` section with steps
8. `## Outputs` section
9. `## Success Criteria` section
10. `## Error Handling` section

Optional sections (recommended for complex phases):
- `## Rollback Plan` - Recovery procedures if phase or subsequent phases fail
- `## Notes` - Additional context, warnings, or implementation notes

### Conditional Execution (Prerequisites)

Phase files can include conditional prerequisites that control execution flow:

```yaml
phase_metadata:
  prerequisites:
    - condition: "$ENVIRONMENT == 'production'"
      action: require_approval
    - condition: "$SKIP_TESTS == true"
      action: skip_phase
```

#### Condition Syntax

Conditions use simple expression syntax with parameter interpolation:

**Comparison Operators**:
- `==` - Equality (string or numeric)
- `!=` - Inequality
- `>`, `<`, `>=`, `<=` - Numeric comparison

**Logical Operators**:
- `&&` - Logical AND
- `||` - Logical OR
- `!` - Logical NOT (prefix)

**Parameter References**:
- `$PARAM_NAME` - Simple reference
- `${PARAM_NAME}` - Explicit boundary reference

**Literal Values**:
- Strings: `'value'` or `"value"`
- Numbers: `42`, `3.14`
- Booleans: `true`, `false`

**Examples**:
```yaml
# Single condition
condition: "$ENVIRONMENT == 'production'"

# Compound condition
condition: "$ENVIRONMENT == 'production' && $BACKUP_ENABLED == true"

# Numeric comparison
condition: "$RETRY_COUNT >= 3"

# Negation
condition: "!$SKIP_VALIDATION"
```

#### Available Actions

| Action | Description |
|--------|-------------|
| `require_approval` | Pause and ask user for confirmation before proceeding |
| `skip_phase` | Skip this phase entirely, continue with next phase |
| `fail_phase` | Immediately fail the phase with condition as reason |
| `warning` | Log a warning but continue execution |

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

## Agent Constraints {#agent-constraints}

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

## Future Features (Not Implemented)

The following features are planned but not currently supported. They are documented in INTRODUCTION.md for illustration purposes only.

### Phase Groups (Concurrent Phase Execution)
```yaml
# FUTURE FEATURE - NOT YET SUPPORTED
phase_groups:
  - [phase-02a-api.md, phase-02b-ui.md, phase-02c-db.md]
```
**Status**: All phases execute sequentially in numeric order. Use `execution_mode: parallel` within individual phases for concurrent work item processing.

### Dynamic Phase Generation
```yaml
# FUTURE FEATURE - NOT YET SUPPORTED
dynamic_phases:
  enabled: true
  generator: phase-00-analyze.md
```
**Status**: All phases must be defined statically in phase files.

### Cross-Workflow Dependencies
```yaml
# FUTURE FEATURE - NOT YET SUPPORTED
dependencies:
  - workflow: prerequisites
    outputs: [config.yaml, setup.log]
```
**Status**: Each workflow operates independently. Run workflows in sequence manually.

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-01-12 | Initial specification |

## References
- [INTRODUCTION.md](INTRODUCTION.md) - Conceptual overview
- [workflow-schema.yaml](../schemas/workflow-schema.yaml) - Formal schema
- [REFERENCE.md](REFERENCE.md) - Quick reference card