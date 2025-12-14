---
phase_metadata:
  inputs:
    parameters:
      - name: PROCESSED_VALUE
        required: true
        type: number

      - name: CURRENT_VALUE
        required: true
        type: number

      - name: LOOP_INDEX
        required: false
        type: integer

  outputs:
    files:
      - path: "$OUTPUT_DIR/iterations/analysis-${LOOP_INDEX}.txt"
        description: "Analysis report for this iteration"

    parameters:
      - name: CONVERGENCE_DELTA
        type: number
        description: "Change from previous iteration"

      - name: NEW_CURRENT_VALUE
        type: number
        description: "Updated current value for next iteration"
---

# Phase 3: Analyze Results

**Purpose**: Analyze iteration results and calculate convergence metrics

## Prerequisites
- PROCESSED_VALUE from phase 2
- CURRENT_VALUE from previous iteration

## Tasks for Todo List
1. Calculate convergence delta
2. Generate analysis report
3. Update current value for next iteration

## Parameters Used
- `PROCESSED_VALUE`: Value after processing
- `CURRENT_VALUE`: Value before processing
- `LOOP_INDEX`: Current iteration number

## Process

### Step 1: Calculate Convergence Delta
```bash
# Delta is absolute change from previous to current
CONVERGENCE_DELTA=$(echo "scale=10; sqrt(($PROCESSED_VALUE - $CURRENT_VALUE)^2)" | bc -l)
echo "Convergence delta: $CONVERGENCE_DELTA"
```

### Step 2: Generate Analysis Report
```bash
cat > "$OUTPUT_DIR/iterations/analysis-${LOOP_INDEX}.txt" <<EOF
Iteration ${LOOP_INDEX} Analysis
===========================

Previous value: ${CURRENT_VALUE}
Processed value: ${PROCESSED_VALUE}
Convergence delta: ${CONVERGENCE_DELTA}

Timestamp: $(date -Iseconds)
EOF

echo "Analysis report saved"
```

### Step 3: Update Current Value
```bash
# Pass processed value as new current value for next iteration
NEW_CURRENT_VALUE=$PROCESSED_VALUE
echo "Updated current value: $NEW_CURRENT_VALUE"
```

## Outputs
- `$OUTPUT_DIR/iterations/analysis-${LOOP_INDEX}.txt`: Analysis report
- `CONVERGENCE_DELTA`: Calculated delta
- `NEW_CURRENT_VALUE`: Value for next iteration

## Success Criteria
- [ ] Convergence delta calculated
- [ ] Analysis report generated
- [ ] Current value updated

## Error Handling
- If calculation fails: FAIL with error
- If values are invalid: FAIL with descriptive message
