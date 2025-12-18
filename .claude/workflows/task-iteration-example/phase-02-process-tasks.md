---
phase_metadata:
  execution_mode: sequential

  inputs:
    parameters:
      - name: OUTPUT_DIR
        required: true
        description: "Output directory for workflow files"
      - name: TASK_ID
        required: true
        description: "Current task ID (provided by task iteration)"
      - name: TASK_INDEX_PATH
        required: true
        description: "Path to task index file"

  outputs:
    files:
      - path: "$OUTPUT_DIR/task-results/$TASK_ID-result.json"
        description: "Result file for this specific task"
---

# Phase 2: Process Single Task

**Purpose**: Process a single task with its own isolated context. This phase is executed multiple times via task iteration, once per task.

## Prerequisites
- TASK_ID is set (injected by task iteration orchestrator)
- TASK_INDEX_PATH is set
- Task definition file exists at `$OUTPUT_DIR/tasks/$TASK_ID.json`

## Tasks for Todo List
1. Load task definition
2. Check dependencies (if any)
3. Process task data
4. Generate result file
5. Report completion

## Parameters Used
- `OUTPUT_DIR`: Base directory for all files
- `TASK_ID`: Current task ID (e.g., "TASK-1", "TASK-3")
- `TASK_INDEX_PATH`: Path to task index (for dependency checking)

## Process

### Step 1: Load Task Definition
Read the task definition from `$OUTPUT_DIR/tasks/$TASK_ID.json`.

Expected structure:
```json
{
  "task_id": "TASK-X",
  "description": "...",
  "dependencies": [],
  "data": {
    "item_number": X,
    "processing_instruction": "..."
  }
}
```

### Step 2: Verify Dependencies (Optional)
If the task has dependencies, verify they completed successfully by checking result files:
```bash
for dep_id in dependencies:
    result_file = "$OUTPUT_DIR/task-results/${dep_id}-result.json"
    if not exists(result_file):
        return status: blocked, blocked_by: dep_id
    if result["status"] != "success":
        return status: blocked, blocked_by: dep_id
```

### Step 3: Process Task Data
Perform the task processing based on the instruction in task.data:
- Read the processing_instruction
- Execute the instruction on the data
- For this example: convert item_number to string, uppercase it, add current timestamp

Example output:
```
ITEM: {item_number}
PROCESSED: ITEM-{item_number}
TIMESTAMP: 2025-12-18T12:30:45Z
```

### Step 4: Generate Result File
Create the result file at `$OUTPUT_DIR/task-results/$TASK_ID-result.json`:

```json
{
  "task_id": "{TASK_ID}",
  "status": "success",
  "processed_at": "{ISO_TIMESTAMP}",
  "outputs": {
    "processed_data": "ITEM-{item_number}",
    "timestamp": "{ISO_TIMESTAMP}"
  },
  "execution_time_seconds": {seconds}
}
```

If processing fails:
```json
{
  "task_id": "{TASK_ID}",
  "status": "failure",
  "error": "Error message describing what went wrong",
  "processed_at": "{ISO_TIMESTAMP}"
}
```

If dependencies not satisfied:
```json
{
  "task_id": "{TASK_ID}",
  "status": "blocked",
  "blocked_by": "{DEPENDENCY_TASK_ID}",
  "processed_at": "{ISO_TIMESTAMP}"
}
```

### Step 5: Report Completion
The orchestrator will automatically detect the result file and continue with the next task.

## Outputs
- `$OUTPUT_DIR/task-results/$TASK_ID-result.json` - Task result file

## Success Criteria
- [ ] Task definition loaded successfully
- [ ] Dependencies verified (if any)
- [ ] Task processing completed
- [ ] Result file created with correct status
- [ ] No errors during execution

## Completion Report

Output the following YAML structure:
```yaml
status: success
phase: 2
task_id: {TASK_ID}
outputs_created:
  - $OUTPUT_DIR/task-results/$TASK_ID-result.json
summary: "Processed {TASK_ID} successfully"
```

## Error Handling
- If task definition file not found, set status: "failure" with error message
- If dependency not satisfied, set status: "blocked" with blocked_by field
- If processing fails, set status: "failure" with error message
- Always create result file even on failure (orchestrator needs it)

## Notes for Task Iteration
- This phase runs in complete isolation for each task
- Fresh agent context per task (prevents context exhaustion)
- Orchestrator handles dependency checking before launching
- Result files enable resumption (skip completed tasks on restart)
