---
phase_metadata:
  execution_mode: sequential

  inputs:
    parameters:
      - name: OUTPUT_DIR
        required: true
        description: "Output directory for workflow files"
      - name: TASK_COUNT
        required: true
        description: "Number of tasks to generate"

  outputs:
    files:
      - path: "$OUTPUT_DIR/task-index.json"
        description: "Task index with execution order"
      - path: "$OUTPUT_DIR/tasks/*.json"
        description: "Individual task definition files"
    parameters:
      - name: TASK_INDEX_PATH
        description: "Path to the generated task index file"
---

# Phase 1: Setup and Task Generation

**Purpose**: Generate task index and task definition files to demonstrate task iteration feature.

## Prerequisites
- OUTPUT_DIR parameter is set
- TASK_COUNT parameter is set (default: 5)

## Tasks for Todo List
1. Create output directory structure
2. Generate task definition files
3. Create task index with execution order
4. Validate generated files

## Parameters Used
- `OUTPUT_DIR`: Base directory for all output files
- `TASK_COUNT`: Number of example tasks to generate

## Process

### Step 1: Create Directory Structure
Create the necessary directories for task iteration:
```bash
mkdir -p "$OUTPUT_DIR/tasks"
mkdir -p "$OUTPUT_DIR/task-results"
```

### Step 2: Generate Task Definition Files
For each task from 1 to TASK_COUNT, create a task definition file at `$OUTPUT_DIR/tasks/TASK-{i}.json`:

```json
{
  "task_id": "TASK-{i}",
  "description": "Example task {i}: Process data item {i}",
  "dependencies": [],
  "data": {
    "item_number": {i},
    "processing_instruction": "Convert to uppercase and add timestamp"
  }
}
```

For tasks with dependencies (to demonstrate dependency tracking):
- TASK-3 should depend on TASK-1
- TASK-5 should depend on TASK-2

Example with dependency:
```json
{
  "task_id": "TASK-3",
  "description": "Example task 3: Process data item 3 (depends on TASK-1)",
  "dependencies": ["TASK-1"],
  "data": {
    "item_number": 3,
    "processing_instruction": "Convert to uppercase and add timestamp"
  }
}
```

### Step 3: Create Task Index
Create the task index file at `$OUTPUT_DIR/task-index.json`:

```json
{
  "metadata": {
    "total_tasks": {TASK_COUNT},
    "generated": "{ISO_TIMESTAMP}",
    "workflow_run_id": "{WORKFLOW_RUN_ID}",
    "description": "Task index for task iteration example"
  },
  "tasks": ["TASK-1", "TASK-2", ..., "TASK-{TASK_COUNT}"],
  "execution_order": [
    {
      "batch": 1,
      "tasks": ["TASK-1", "TASK-2", "TASK-4"]
    },
    {
      "batch": 2,
      "tasks": ["TASK-3", "TASK-5"]
    }
  ]
}
```

Note: TASK-3 and TASK-5 are in batch 2 because they have dependencies that must complete first.

### Step 4: Validate Generated Files
Verify all files were created successfully:
- task-index.json exists and is valid JSON
- All TASK-*.json files exist in tasks/ directory
- Execution order reflects dependencies correctly

## Outputs
- `$OUTPUT_DIR/task-index.json` - Master task index
- `$OUTPUT_DIR/tasks/TASK-*.json` - Individual task definitions
- Parameter: `TASK_INDEX_PATH` = `$OUTPUT_DIR/task-index.json`

## Success Criteria
- [ ] Output directory structure created
- [ ] All task definition files generated (TASK_COUNT files)
- [ ] Task index file created with correct structure
- [ ] Execution order batches respect dependencies
- [ ] TASK_INDEX_PATH parameter set for next phase

## Completion Report

Output the following YAML structure:
```yaml
status: success
phase: 1
outputs_created:
  - $OUTPUT_DIR/task-index.json
  - $OUTPUT_DIR/tasks/TASK-*.json
parameters_discovered:
  TASK_INDEX_PATH: $OUTPUT_DIR/task-index.json
summary: "Generated {TASK_COUNT} task definitions and task index"
```

## Error Handling
- If OUTPUT_DIR cannot be created, abort with clear error message
- If task file creation fails, report which tasks failed
- Ensure task-index.json is valid JSON before completing
