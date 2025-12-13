---
name: run-workflow
description: "Execute multi-phase workflows from a specified directory"
---

# Multi-Phase Workflow Runner

Execute complex, multi-phase workflows by automatically discovering and orchestrating phase execution from a workflow directory.

## Overview

This command provides a general-purpose workflow orchestration engine that:
- Discovers phase files from a workflow directory
- Orchestrates phase execution via isolated agents using the Task tool
- Resolves and displays parameters for each phase
- Manages context flow between phases
- Provides clear progress tracking and isolation

## Usage

```bash
run-workflow <WORKFLOW_DIR> [parameters...]
```

**Arguments:**
- `WORKFLOW_DIR`: Path to workflow directory containing workflow phases (required)
- `parameters...`: Additional parameters passed to the workflow (optional)

**Examples:**
```bash
# Run a deployment workflow
run-workflow .claude/workflows/deployment

# Run with custom parameters
run-workflow .claude/workflows/migration --database=prod --backup=true

# Run workflow from absolute path
run-workflow /home/user/project/workflows/testing
```

## Workflow Structure

### Required Files
Each workflow directory must contain:
```
workflow-directory/
├── workflow.yaml           # Workflow metadata and parameter definitions
├── phase-01-*.md          # First phase (required)
└── phase-02-*.md          # Subsequent phases (at least one more)
```

> **Minimum Phases**: A workflow requires at least 2 phase files. Valid configurations:
> - `phase-01-*.md` + `phase-02-*.md` (standard)
> - `phase-00-*.md` + `phase-01-*.md` (with setup phase)

### Optional Files
```
workflow-directory/
├── phase-00-setup.md      # Optional setup/discovery phase
├── runtime-parameters.yaml  # Generated runtime parameters
└── execution.log         # Generated execution log
```

### File Naming Convention
- Phase files must start with `phase-` followed by a two-digit number
- Numbers must be sequential (01, 02, 03...)
- Descriptive names after the number (e.g., `phase-01-prepare.md`)
- Setup phase (if present) should be `phase-00-setup.md`

## Workflow Configuration

### workflow.yaml Structure
```yaml
name: deployment-workflow
description: "Deploy application to production environment"
version: 1.0.0

parameters:
  - name: ENVIRONMENT
    type: string
    required: true
    description: "Target deployment environment"

  - name: BACKUP
    type: boolean
    required: false
    default: true
    description: "Create backup before deployment"

  - name: PARALLEL_JOBS
    type: integer
    required: false
    default: 4
    description: "Number of parallel deployment jobs"

phases:
  require_confirmation: true  # Ask for confirmation before each phase
  allow_retry: true           # Allow retrying failed phases
  generate_logs: true         # Create execution.log file
```

## Phase File Structure

Each phase file must follow this structure:

### Standard Phase (Sequential Execution)
```markdown
---
phase_metadata:
  inputs:
    files:
      - name: FEATURE_SPEC
        required: true
        description: "Source specification document"
      - name: VALIDATION_RULES
        required: false
        description: "Validation rules document"
    parameters:
      - name: SPECS_DIR
        required: true
        description: "Output directory"
  outputs:
    files:
      - path: "$SPECS_DIR/research.md"
        description: "Research findings"
      - path: "$SPECS_DIR/adrs/*.md"
        description: "Architecture Decision Records"
    parameters:
      - name: TECHNOLOGY_STACK
        description: "Resolved technology choices"
---
```

### Parallel Phase (Concurrent Agent Execution)
```markdown
---
phase_metadata:
  execution_mode: parallel  # Enables parallel execution
  parallel_config:
    agent_type: feature-specifier  # Agent to use for each work item
    discovery_pattern: "$OUTPUT_DIR/features/FEAT-*.md"  # Find work items
    work_item_parameter: FEATURE_FILE  # Pass work item to agent
    output_pattern: "$OUTPUT_DIR/specs/SPEC-{number}-{name}/feature-spec.md"
    max_parallel: 5  # Max concurrent agents (0 = unlimited)
  inputs:
    parameters:
      - name: OUTPUT_DIR
        required: true
        description: "Base output directory"
  outputs:
    files:
      - path: "$OUTPUT_DIR/specs/SPEC-*/feature-spec.md"
        description: "Generated specifications"
    parameters:
      - name: SPECS_COUNT
        description: "Number of specs generated"
---

# Phase [Number]: [Name]

**Purpose**: Brief description of what this phase accomplishes

## Prerequisites
- List of requirements before this phase can run
- Required parameters: ${PARAM_NAME}
- Required files or resources

## Tasks for Todo List
When starting this phase, add these tasks:
1. First task to complete
2. Second task to complete
3. Third task to complete

## Parameters Used
- `environment`: Target environment for deployment
- `backup`: Whether to create backup

## Process

### Step 1: [Step Name]
Detailed instructions for this step...

### Step 2: [Step Name]  
Detailed instructions for this step...

## Outputs
- Files or artifacts created by this phase
- Updated configurations
- Generated reports

## Success Criteria
- [ ] Criterion 1 met
- [ ] Criterion 2 met
- [ ] All tests pass

## Error Handling
- Common errors and their resolutions
- Rollback procedures if needed
```

## Execution Flow

### 1. Discovery Phase
```
1. Validate WORKFLOW_DIR exists and is readable
2. Load workflow.yaml configuration
3. Discover all phase-*.md files
4. Sort phases by numeric prefix
5. Validate sequential numbering (no gaps)
6. Count total phases
7. Display workflow summary
```

### 2. Parameter Resolution
```
1. Parse workflow.yaml for required parameters
2. Check command-line arguments
3. Check environment variables:
   - Parameters can be set via environment variables with `WORKFLOW_` prefix
   - Example: `WORKFLOW_OUTPUT_DIR` sets the `OUTPUT_DIR` parameter
   - Environment variables take precedence over defaults but not CLI args
4. If phase-00-setup.md exists:
   - Execute setup phase for parameter discovery
   - Store discovered values in runtime-parameters.yaml
5. Validate all required parameters are available
6. Load default values for optional parameters
```

### 3. Todo List Initialization
```
1. Create initial todo list with all phases:
   - Phase 0: Setup (if present)
   - Phase 1: [Name from file]
   - Phase 2: [Name from file]
   - ...
2. Mark first phase as pending
```

### 4. Phase Execution Loop (Agent-Based)
For each phase:
```
1. ANNOUNCE: "Starting Phase X of Y: [Phase Name]"
2. Mark phase as in_progress in todo list
3. Read phase file and extract:
   - Phase metadata (inputs, outputs, parameters, execution_mode)
   - Phase instructions and process steps
   - Success criteria
4. Resolve parameters from:
   - workflow.yaml definitions
   - Command-line arguments
   - Previous phase outputs (runtime-parameters.yaml)
   - Discovered files in output directories

5. CHECK EXECUTION MODE:
   If phase_metadata.execution_mode == "parallel":
      → Execute Parallel Phase (see section 4a below)
   Else:
      → Execute Standard Phase (continue with step 6)

6. **CRITICAL: Display resolved context in main thread output**
   **This MUST happen in your main response, NOT inside the agent**
   **Display this BEFORE calling the Task tool:**
   
   ═══════════════════════════════════════════════════════
   PHASE X: [Phase Name]
   ═══════════════════════════════════════════════════════
   Input Files:
   - [FILE_NAME]: [resolved path]
   - [FILE_NAME]: [resolved path]
   
   Parameters:
   - [PARAM_NAME]: [resolved value]
   - [PARAM_NAME]: [resolved value]
   
   Expected Outputs:
   - [output file path]
   - [output file path]
   ═══════════════════════════════════════════════════════

7. Build agent prompt including:
   - List of input files to read
   - Resolved parameter values
   - Phase instructions from the phase file
   - Expected output specifications
   - Success criteria to validate
8. Execute phase via Task tool:
   - subagent_type: "phase-executor"
   - description: "Execute Phase X: [Name]"
   - prompt: [constructed prompt with all context]
9. Process agent result:
   - Verify expected outputs were created
   - Extract any new parameters for next phases
   - Update runtime-parameters.yaml if needed
10. Mark phase as completed in todo list
11. ANNOUNCE: "Completed Phase X of Y: [Phase Name]"
12. Log execution details to execution.log
```

### 4a. Parallel Phase Execution
When `execution_mode: parallel` is set in phase metadata:
```
1. Extract parallel configuration:
   - agent_type: Which agent to use for parallel tasks
   - discovery_pattern: Pattern to find work items
   - work_item_parameter: Parameter name for passing work item
   - output_pattern: Expected output path pattern
   - max_parallel: Maximum concurrent agents (0 = unlimited)

2. Discover work items:
   - Use discovery_pattern to find all files/items to process
   - Example: Find all FEAT-*.md files in features directory
   - Build list of work items with their target outputs

3. Display parallel execution plan:
   ═══════════════════════════════════════════════════════
   PHASE X: [Phase Name] - PARALLEL EXECUTION
   ═══════════════════════════════════════════════════════
   Work Items Found: [count]
   - [work_item_1] → [output_1]
   - [work_item_2] → [output_2]
   - ...
   
   Parallel Configuration:
   - Agent Type: [agent_type]
   - Max Parallel: [max_parallel or "unlimited"]
   
   Common Parameters:
   - [PARAM_NAME]: [resolved value]
   - [PARAM_NAME]: [resolved value]
   ═══════════════════════════════════════════════════════

4. Launch parallel agents:
   - Create Task tool invocations for each work item
   - Use the agent_type specified in parallel_config (can be phase-executor or a specialized agent)
   - Pass work item via work_item_parameter
   - Include common parameters for all agents
   - Execute multiple agents in single message (for parallelism)

5. Example parallel invocation:

   > **Note**: The following examples use pseudocode syntax to illustrate the Task tool invocation pattern. The actual Claude Code tool call syntax differs.

   ```python
   # Launch multiple agents in one message for true parallelism
   Task(
       subagent_type="feature-specifier",
       description="Process FEAT-001",
       prompt="Transform FEAT-001-pr-fetching.md to specification..."
   )
   Task(
       subagent_type="feature-specifier",
       description="Process FEAT-002",
       prompt="Transform FEAT-002-check-analysis.md to specification..."
   )
   # ... more Task invocations
   ```

6. Monitor and aggregate results:
   - Wait for all parallel agents to complete
   - Collect outputs from each agent
   - Verify expected outputs were created
   - Aggregate any discovered parameters
   - Handle and retry any failures

7. Complete parallel phase:
   - Mark phase as completed in todo list
   - Generate summary report if specified
   - Update runtime-parameters.yaml with aggregated values
```

### 5. Completion
```
1. Verify all phases completed successfully
2. Generate final execution summary
3. Display:
   - Total phases executed
   - Total time taken
   - Key outputs produced
4. Save complete execution.log
```

## Progress Indicators

The command provides clear progress tracking:

```
═══════════════════════════════════════════════════════
WORKFLOW: deployment-workflow
PHASES: 4 phases discovered
═══════════════════════════════════════════════════════

[Discovery] Found phases:
  ✓ phase-00-setup.md (Parameter Discovery)
  ✓ phase-01-prepare.md (Environment Preparation)
  ✓ phase-02-execute.md (Deployment Execution)
  ✓ phase-03-validate.md (Post-Deployment Validation)

[Parameters] Resolving workflow parameters...
  ✓ environment: production
  ✓ backup: true
  ✓ parallel_jobs: 4

───────────────────────────────────────────────────────
▶ PHASE 1 of 4: Environment Preparation
───────────────────────────────────────────────────────

═══════════════════════════════════════════════════════
PHASE 1: Environment Preparation
═══════════════════════════════════════════════════════
Input Files:
  - ENVIRONMENT_CONFIG: /workspace/configs/prod.yaml
  - DEPLOYMENT_SPEC: /workspace/deploy/spec.yaml

Parameters:
  - environment: production
  - backup: true
  - parallel_jobs: 4

Expected Outputs:
  - /workspace/temp/prepared-environment.yaml
  - /workspace/logs/preparation.log
═══════════════════════════════════════════════════════

[in progress] Setting up deployment environment...
[completed] ✓ Environment ready

───────────────────────────────────────────────────────
▶ PHASE 2 of 4: Deployment Execution
───────────────────────────────────────────────────────

═══════════════════════════════════════════════════════
PHASE 2: Deployment Execution
═══════════════════════════════════════════════════════
Input Files:
  - PREPARED_ENV: /workspace/temp/prepared-environment.yaml
  - DEPLOYMENT_SPEC: /workspace/deploy/spec.yaml

Parameters:
  - environment: production
  - backup: true
  - parallel_jobs: 4
  - ENV_READY: true    # From Phase 1

Expected Outputs:
  - /workspace/logs/deployment.log
  - /workspace/status/deployment-status.yaml
═══════════════════════════════════════════════════════

...
```

**CRITICAL REQUIREMENT:** The parameter display box with ═══ borders MUST be shown in your main response before each Task tool invocation. This ensures users can see what parameters are being passed to each phase.

## Error Handling

### Phase Failures
When a phase fails:
1. Display error details clearly
2. Mark phase as failed in todo list
3. If `allow_retry: true` in workflow.yaml:
   - Prompt: "Phase failed. Retry? (y/n)"
   - On 'y': Reset phase tasks and retry
   - On 'n': Abort workflow
4. Log failure details to execution.log

### Missing Requirements
- Missing workflow.yaml: Error with instructions to create
- Missing phase files: List discovered phases and gaps
- Missing parameters: List required parameters and how to provide

### Validation Errors
- Non-sequential phases: Show gap (e.g., "Missing phase-02")
- Invalid phase format: Show expected format
- Invalid workflow.yaml: Display schema violations

## Advanced Features

### Conditional Phases
Phases can include conditions in their prerequisites:
```markdown
## Prerequisites
- Parameter `environment` must equal "production"
- File `backup.sql` must exist if `backup` is true
```

### Phase Dependencies
Phases can reference outputs from previous phases:
```markdown
## Prerequisites  
- Output from Phase 1: deployment-config.yaml
- Artifact from Phase 2: backup-timestamp.txt
```

### Parallel Task Execution
Within a phase, mark tasks that can run in parallel:
```markdown
## Tasks for Todo List
1. [PARALLEL] Deploy to region-1
2. [PARALLEL] Deploy to region-2  
3. [PARALLEL] Deploy to region-3
4. Verify all deployments
```

## Example Workflows

### Deployment Workflow
```
.claude/workflows/deployment/
├── workflow.yaml
├── phase-00-setup.md      # Discover environment settings
├── phase-01-prepare.md    # Prepare deployment environment
├── phase-02-backup.md     # Create backups
├── phase-03-deploy.md     # Execute deployment
└── phase-04-validate.md   # Validate deployment
```

### Testing Workflow
```
.claude/workflows/testing/
├── workflow.yaml
├── phase-01-setup.md      # Setup test environment
├── phase-02-unit.md       # Run unit tests
├── phase-03-integration.md # Run integration tests
└── phase-04-cleanup.md    # Cleanup test artifacts
```

### Migration Workflow
```
.claude/workflows/migration/
├── workflow.yaml
├── phase-00-setup.md      # Analyze current state
├── phase-01-backup.md     # Backup data
├── phase-02-transform.md  # Transform data
├── phase-03-migrate.md    # Execute migration
├── phase-04-verify.md     # Verify migration
└── phase-05-cleanup.md    # Cleanup temporary files
```

## Best Practices

1. **Phase Granularity**: Keep phases focused on a single objective
2. **Clear Prerequisites**: Always specify what a phase needs
3. **Explicit Success Criteria**: Define measurable success conditions
4. **Error Recovery**: Include rollback procedures in each phase
5. **Parameter Documentation**: Document all parameters in workflow.yaml
6. **Task Atomicity**: Make tasks small and independently verifiable
7. **Progress Visibility**: Use clear task names that indicate progress
8. **Logging**: Generate artifacts that can be reviewed later

## Troubleshooting

### Common Issues

**"No phase files found"**
- Check workflow directory path
- Verify files match pattern `phase-*.md`
- Ensure files are readable

**"Phase sequence has gaps"**
- Phases must be numbered sequentially
- Check for missing numbers (e.g., 01, 02, 04 - missing 03)

**"Required parameter missing"**
- Check workflow.yaml for required parameters
- Provide via command line or setup phase
- Verify parameter names match exactly

**"Phase failed to complete"**
- Check execution.log for details
- Verify prerequisites were met
- Review success criteria
- Consider retry if transient issue

## Agent-Based Execution Architecture

### How It Works
Each phase is executed in an isolated agent context via the Task tool:

1. **Orchestrator Role**: The workflow runner acts as an orchestrator, not an executor
2. **Parameter Display**: Before each phase, the orchestrator MUST display resolved parameters in the main thread
3. **Phase Isolation**: Each phase runs in a clean agent context with only necessary inputs
4. **Explicit Context**: Agents receive explicit file lists and parameters, no implicit context
5. **Clear Contracts**: Each phase has defined inputs and outputs via metadata

### Benefits
- **Isolation**: Phases cannot accidentally depend on undeclared context
- **Debugging**: Can re-run individual phases with exact same inputs
- **Parallelization**: Non-dependent phases could run concurrently (future enhancement)
- **Modularity**: Phases become reusable components with clear interfaces
- **Traceability**: Complete record of what each phase received and produced

### Example Task Tool Invocation

> **Note**: The following examples use pseudocode syntax to illustrate the Task tool invocation pattern. The actual Claude Code tool call syntax differs.

```python
# Orchestrator invokes Task tool for each phase:
Task(
    subagent_type="phase-executor",
    description="Execute Phase 00: Research & Discovery",
    prompt="""
    ## Phase: Research & Discovery

    ### Your Input Files
    Please read these files:
    - /workspace/specs/feature.md (FEATURE_SPEC)
    - .claude/validation-rules.md (VALIDATION_RULES)

    ### Parameters
    - SPECS_DIR: outputs/specs/SPEC-001/
    - LANGUAGE_HINT: Python
    - FRAMEWORK_HINT: FastAPI

    ### Your Task
    [Full phase instructions from phase-00-research.md]

    ### Expected Outputs
    Create these files:
    - outputs/specs/SPEC-001/research.md
    - outputs/specs/SPEC-001/adrs/ADR-*.md

    ### Success Criteria
    - All technical decisions documented
    - Validation rules compliance verified
    """
)
```

## Integration with Other Commands

Phases executed via agents have access to Claude's built-in tools:
- File operations (read, write, edit)
- Bash commands and script execution
- Search and analysis tools
- Web requests via appropriate tools

**Important**: Agents CANNOT invoke other agents. The Task tool is not available within phase execution. All work must be completed directly by the phase-executor agent.

## Backward Compatibility Note

Existing phase files without metadata sections will still work:
- Orchestrator will use legacy parameter extraction
- All parameters will be passed to the agent
- Gradual migration to metadata format recommended