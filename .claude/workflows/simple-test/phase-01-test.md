---
phase_metadata:
  inputs:
    parameters:
      - name: OUTPUT_DIR
        required: true
        type: directory

  outputs:
    files:
      - path: "$OUTPUT_DIR/test.txt"
        description: "Test output file"
---

# Phase 1: Simple Test

**Purpose**: Test backward compatibility - workflow without loops

## Prerequisites
- OUTPUT_DIR parameter provided

## Tasks for Todo List
1. Create test output

## Parameters Used
- `OUTPUT_DIR`: Output directory

## Process

### Step 1: Create Output
```bash
mkdir -p "$OUTPUT_DIR"
echo "Test complete - no loops used" > "$OUTPUT_DIR/test.txt"
```

## Outputs
- `$OUTPUT_DIR/test.txt`: Test file

## Success Criteria
- [ ] Test file created

## Error Handling
- None
