# Workflow System Quick Reference

## Commands
```bash
# Create a workflow from input files
create-workflow <input-files...> --name <name> [--type <type>]

# Execute a workflow
run-workflow <workflow-dir> [parameters...]

# Validate a workflow
validate-workflow <workflow-dir> [--strict-mode]
```

## Directory Structure
```
workflow-directory/
├── workflow.yaml          # REQUIRED: Configuration
├── phase-01-*.md         # REQUIRED: First phase
├── phase-02-*.md         # REQUIRED: Second phase
├── phase-00-*.md         # Optional: Setup phase
├── README.md             # Recommended: Documentation
└── examples/             # Optional: Examples
```

## workflow.yaml Structure
```yaml
name: workflow-name        # Required: kebab-case
description: "Purpose"     # Required: description
version: 1.0.0            # Required: semver

parameters:               # Optional: parameters
  PARAM_NAME:
    type: string         # string|boolean|integer|number|enum|file|directory
    required: true       # Is required?
    default: value       # Default value
    description: "..."   # Description

phases:                  # Optional: execution config
  require_confirmation: false
  allow_retry: true
  generate_logs: true
  stop_on_failure: true
```

## Phase Metadata (Required at top of each phase file)
```yaml
---
phase_metadata:
  execution_mode: sequential  # or parallel
  
  # For parallel execution:
  parallel_config:
    agent_type: feature-specifier
    discovery_pattern: "$OUTPUT_DIR/features/*.md"
    work_item_parameter: FEATURE_FILE
    output_pattern: "$OUTPUT_DIR/specs/{name}-spec.md"
    max_parallel: 5
  
  inputs:
    files:
      - name: INPUT_FILE
        required: true
        description: "Input file"
    parameters:
      - name: PARAM_NAME
        required: true
        description: "Parameter"
  
  outputs:
    files:
      - path: "$OUTPUT_DIR/file.md"
        description: "Output file"
    parameters:
      - name: OUTPUT_PARAM
        description: "Output value"
---
```

## Phase File Structure
```markdown
---
phase_metadata: {...}
---

# Phase N: Name

**Purpose**: What this phase does

## Prerequisites
- Required conditions

## Tasks for Todo List
1. Task one
2. Task two

## Process
### Step 1: Name
Instructions...

## Outputs
- Generated files

## Success Criteria
- [ ] Criteria met

## Error Handling
- Recovery procedures
```

## Parameter Types
| Type | Example | Description |
|------|---------|-------------|
| `string` | `"text"` | Text value |
| `boolean` | `true` | True/false |
| `integer` | `42` | Whole number |
| `number` | `3.14` | Decimal number |
| `enum` | `"prod"` | From list |
| `file` | `"./file"` | File path |
| `directory` | `"./dir"` | Dir path |

## Parameter Resolution Order
1. CLI arguments (highest)
2. Environment variables
3. Previous phase outputs
4. workflow.yaml defaults
5. Phase metadata defaults

## Execution Modes

### Sequential (Default)
- Single agent per phase
- Processes all work
- Standard execution

### Parallel
- Multiple agents concurrent
- One per work item
- Requires parallel_config

## Agent Types
- `phase-executor` - Default isolated executor for running workflow phases
- `workflow-creator` - Analyzes input files and generates complete workflows
- `workflow-validator` - Validates workflow structure, metadata, and coherence

Note: Custom specialized agents can be created and referenced in `parallel_config.agent_type` for domain-specific work.

## Critical Rules
1. **No Nested Agents**: Agents cannot invoke other agents
2. **Sequential Phases**: No gaps in numbering
3. **Parameter Names**: UPPER_SNAKE_CASE
4. **File Names**: phase-XX-name.md format
5. **Explicit Dependencies**: All inputs declared

## Validation Levels
- **ERROR** ✗ - Blocks execution
- **WARNING** ⚠ - May cause issues
- **INFO** ℹ - Suggestions

## Common Patterns

### Discovery Phase (phase-00)
```yaml
outputs:
  parameters:
    - name: DISCOVERED_VALUE
      description: "Runtime discovery"
```

### Parallel Processing
```yaml
execution_mode: parallel
parallel_config:
  agent_type: processor
  discovery_pattern: "$DIR/*.md"
```

### Conditional Execution
```yaml
prerequisites:
  - condition: "$ENV == 'prod'"
    action: require_approval
```

## File References
- [Full Specification](SPECIFICATION.md)
- [Introduction](INTRODUCTION.md)
- [Workflow Schema](../schemas/workflow-schema.yaml)
- [Phase Schema](../schemas/phase-metadata-schema.yaml)

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Phase not found" | Check naming: phase-XX-*.md |
| "Parameter undefined" | Add to workflow.yaml |
| "Missing metadata" | Add phase_metadata section |
| "Agent failed" | Check phase can't invoke agents |

## Best Practices
1. Always include phase_metadata
2. Use parameter interpolation: `$PARAM`
3. Document success criteria
4. Include error handling
5. One objective per phase
6. Validate before execution