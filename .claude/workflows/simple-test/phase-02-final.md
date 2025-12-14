---
phase_metadata:
  inputs:
    parameters:
      - name: OUTPUT_DIR
        required: true
        type: directory

  outputs:
    files:
      - path: "$OUTPUT_DIR/complete.txt"
        description: "Completion marker"
---

# Phase 2: Finalize

**Purpose**: Complete simple workflow

## Prerequisites
- Phase 1 completed

## Tasks for Todo List
1. Create completion marker

## Parameters Used
- `OUTPUT_DIR`: Output directory

## Process

### Step 1: Mark Complete
```bash
echo "Workflow complete" > "$OUTPUT_DIR/complete.txt"
```

## Outputs
- `$OUTPUT_DIR/complete.txt`: Completion marker

## Success Criteria
- [ ] Completion marker created

## Error Handling
- None
