---
phase_metadata:
  inputs:
    parameters:
      - name: OUTPUT_DIR
        required: true
        type: directory

      - name: CURRENT_VALUE
        required: true
        type: number
        description: "Value from previous iteration"

      - name: LOOP_INDEX
        required: false
        type: integer
        description: "Current loop iteration (auto-injected)"

  outputs:
    files:
      - path: "$OUTPUT_DIR/iterations/iteration-${LOOP_INDEX}.json"
        description: "Iteration processing results"

    parameters:
      - name: PROCESSED_VALUE
        type: number
        description: "Value after processing"
---

# Phase 2: Process Iteration

**Purpose**: Process current iteration and refine value

## Prerequisites
- CURRENT_VALUE from previous phase or iteration
- LOOP_INDEX available (auto-injected by orchestrator)

## Tasks for Todo List
1. Determine iteration context
2. Apply refinement algorithm
3. Save iteration results

## Parameters Used
- `CURRENT_VALUE`: Input value to process
- `LOOP_INDEX`: Current iteration number (1-based)
- `OUTPUT_DIR`: Where to save results

## Process

### Step 1: Log Iteration Context
```bash
if [ -z "$LOOP_INDEX" ]; then
  echo "ERROR: LOOP_INDEX not set - should be auto-injected by orchestrator"
  exit 1
fi

echo "Processing iteration $LOOP_INDEX"
echo "Input value: $CURRENT_VALUE"
```

### Step 2: Apply Refinement Algorithm
Simulate an iterative refinement that converges toward 0:
```bash
# Simple convergence formula: new_value = current_value * 0.7
# This will converge toward 0 over multiple iterations
PROCESSED_VALUE=$(echo "$CURRENT_VALUE * 0.7" | bc -l)
echo "Processed value: $PROCESSED_VALUE"
```

### Step 3: Save Iteration Results
```bash
cat > "$OUTPUT_DIR/iterations/iteration-${LOOP_INDEX}.json" <<EOF
{
  "iteration": ${LOOP_INDEX},
  "input_value": ${CURRENT_VALUE},
  "processed_value": ${PROCESSED_VALUE},
  "timestamp": "$(date -Iseconds)",
  "algorithm": "value * 0.7"
}
EOF

echo "Saved results to $OUTPUT_DIR/iterations/iteration-${LOOP_INDEX}.json"
```

## Outputs
- `$OUTPUT_DIR/iterations/iteration-${LOOP_INDEX}.json`: Iteration results
- `PROCESSED_VALUE`: Refined value

## Success Criteria
- [ ] Refinement algorithm applied successfully
- [ ] Iteration results saved
- [ ] PROCESSED_VALUE calculated

## Error Handling
- If LOOP_INDEX missing: FAIL with error
- If calculation fails: FAIL with error
- If file write fails: FAIL with error
