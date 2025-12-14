---
phase_metadata:
  inputs:
    parameters:
      - name: OUTPUT_DIR
        required: true
        type: directory
        description: "Output directory for results"

      - name: INITIAL_VALUE
        required: true
        type: number
        description: "Starting value for convergence"

  outputs:
    files:
      - path: "$OUTPUT_DIR/setup-complete.txt"
        description: "Setup completion marker"

    parameters:
      - name: CURRENT_VALUE
        type: number
        description: "Initial value for iteration"

      - name: ITERATION_COUNT
        type: integer
        description: "Total iterations performed (starts at 0)"
---

# Phase 1: Setup and Initialization

**Purpose**: Initialize the convergence testing workflow and set up output directory

## Prerequisites
- OUTPUT_DIR parameter provided
- Write access to output directory

## Tasks for Todo List
1. Create output directory structure
2. Initialize iteration tracking
3. Set initial values for convergence testing

## Parameters Used
- `OUTPUT_DIR`: Where to store iteration results
- `INITIAL_VALUE`: Starting value for convergence simulation

## Process

### Step 1: Create Directory Structure
```bash
mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/iterations"
echo "Created output directory: $OUTPUT_DIR"
```

### Step 2: Initialize State
```bash
# Set initial value for convergence
CURRENT_VALUE=$INITIAL_VALUE
echo "Initial value: $CURRENT_VALUE"

# Initialize iteration counter
ITERATION_COUNT=0
```

### Step 3: Create Setup Marker
```bash
cat > "$OUTPUT_DIR/setup-complete.txt" <<EOF
Setup completed at: $(date -Iseconds)
Initial value: $CURRENT_VALUE
Convergence threshold: $CONVERGENCE_THRESHOLD
Max iterations: $MAX_LOOP_ITERATIONS
EOF
```

## Outputs
- `$OUTPUT_DIR/setup-complete.txt`: Setup completion marker
- `CURRENT_VALUE`: Initial value (${INITIAL_VALUE})
- `ITERATION_COUNT`: Iteration counter (0)

## Success Criteria
- [ ] Output directory created successfully
- [ ] Initial values set
- [ ] Setup marker file created

## Error Handling
- If OUTPUT_DIR creation fails: FAIL phase with error message
- If parameters missing: FAIL phase
