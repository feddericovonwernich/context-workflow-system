---
phase_metadata:
  inputs:
    parameters:
      - name: CONVERGENCE_DELTA
        required: true
        type: number

      - name: CONVERGENCE_THRESHOLD
        required: true
        type: number

      - name: NEW_CURRENT_VALUE
        required: true
        type: number

      - name: LOOP_INDEX
        required: false
        type: integer

      - name: ITERATION_COUNT
        required: true
        type: integer

  outputs:
    files:
      - path: "$OUTPUT_DIR/validation-report.md"
        description: "Validation report with convergence decision"

    parameters:
      - name: LOOP_CONTINUE
        type: boolean
        description: "Whether to continue loop (phase override)"

      - name: LOOP_REASON
        type: string
        description: "Reason for loop decision"

      - name: CURRENT_VALUE
        type: number
        description: "Updated value for next iteration"

      - name: ITERATION_COUNT
        type: integer
        description: "Updated iteration count"
---

# Phase 4: Validate and Check Convergence

**Purpose**: Validate iteration results and determine if convergence has been achieved

## Prerequisites
- CONVERGENCE_DELTA from phase 3
- CONVERGENCE_THRESHOLD parameter set
- At least one iteration completed

## Tasks for Todo List
1. Load convergence metrics
2. Compare delta against threshold
3. Decide if loop should continue
4. Generate validation report

## Parameters Used
- `CONVERGENCE_DELTA`: Change from this iteration
- `CONVERGENCE_THRESHOLD`: Target threshold
- `NEW_CURRENT_VALUE`: Value to use for next iteration
- `LOOP_INDEX`: Current iteration number
- `ITERATION_COUNT`: Total iterations so far

## Process

### Step 1: Log Validation Context
```bash
echo "Validation for iteration $LOOP_INDEX"
echo "Convergence delta: $CONVERGENCE_DELTA"
echo "Convergence threshold: $CONVERGENCE_THRESHOLD"
echo "Current value: $NEW_CURRENT_VALUE"
```

### Step 2: Check Convergence
```bash
# Compare delta to threshold using bc for floating point
CONVERGED=$(echo "$CONVERGENCE_DELTA < $CONVERGENCE_THRESHOLD" | bc -l)

if [ "$CONVERGED" -eq 1 ]; then
  echo "✓ CONVERGED: Delta ($CONVERGENCE_DELTA) < Threshold ($CONVERGENCE_THRESHOLD)"
  LOOP_CONTINUE="false"
  LOOP_REASON="Converged (delta=$CONVERGENCE_DELTA < threshold=$CONVERGENCE_THRESHOLD)"
else
  echo "↻ NOT CONVERGED: Delta ($CONVERGENCE_DELTA) >= Threshold ($CONVERGENCE_THRESHOLD)"
  LOOP_CONTINUE="true"
  LOOP_REASON="Not converged (delta=$CONVERGENCE_DELTA >= threshold=$CONVERGENCE_THRESHOLD)"
fi

echo "Loop decision: LOOP_CONTINUE=$LOOP_CONTINUE"
echo "Loop reason: $LOOP_REASON"
```

### Step 3: Update State
```bash
# Pass current value forward for next iteration
CURRENT_VALUE=$NEW_CURRENT_VALUE

# Increment iteration count
ITERATION_COUNT=$((ITERATION_COUNT + 1))
```

### Step 4: Generate Validation Report
```bash
cat > "$OUTPUT_DIR/validation-report.md" <<EOF
# Validation Report - Iteration $LOOP_INDEX

## Convergence Analysis

- **Iteration**: $LOOP_INDEX
- **Convergence Delta**: $CONVERGENCE_DELTA
- **Threshold**: $CONVERGENCE_THRESHOLD
- **Current Value**: $CURRENT_VALUE
- **Total Iterations**: $ITERATION_COUNT

## Decision

**Loop Continue**: $LOOP_CONTINUE

**Reason**: $LOOP_REASON

## Iteration History

$(ls -1 $OUTPUT_DIR/iterations/ | wc -l) iteration files created

## Timestamp

$(date -Iseconds)
EOF

echo "Validation report saved to $OUTPUT_DIR/validation-report.md"
```

## Outputs
- `$OUTPUT_DIR/validation-report.md`: Validation report
- `LOOP_CONTINUE`: Boolean loop decision
- `LOOP_REASON`: Explanation of decision
- `CURRENT_VALUE`: Value for next iteration
- `ITERATION_COUNT`: Updated count

## Success Criteria
- [ ] Convergence delta compared to threshold
- [ ] Loop decision made (LOOP_CONTINUE set)
- [ ] Loop reason provided
- [ ] Validation report generated

## Error Handling
- If CONVERGENCE_DELTA missing: FAIL phase
- If threshold comparison fails: FAIL phase
- If report generation fails: FAIL phase

## Notes

This phase demonstrates the **hybrid loop control** pattern:

1. **Declarative structure**: Loop defined in workflow.yaml with phases [2, 3, 4]
2. **Phase-based control**: This phase sets LOOP_CONTINUE based on convergence
3. **Safety limit**: max_iterations in workflow.yaml prevents infinite loops
4. **Traceability**: All decisions logged in validation report

The orchestrator will:
- Respect max_iterations (highest priority)
- Check LOOP_CONTINUE parameter (this phase's decision)
- Jump back to phase 2 if continuing, or exit to phase 5 if converged
