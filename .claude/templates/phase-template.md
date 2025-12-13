---
phase_metadata:
  # Execution mode: sequential (default) or parallel
  execution_mode: sequential
  
  # For parallel execution, uncomment and configure:
  # parallel_config:
  #   agent_type: ${AGENT_TYPE}  # e.g., feature-specifier
  #   discovery_pattern: "${DISCOVERY_PATTERN}"  # e.g., "$OUTPUT_DIR/items/*.md"
  #   work_item_parameter: ${WORK_ITEM_PARAM}  # e.g., WORK_ITEM_FILE
  #   output_pattern: "${OUTPUT_PATTERN}"  # e.g., "$OUTPUT_DIR/results/{name}.md"
  #   max_parallel: ${MAX_PARALLEL}  # e.g., 5 or 0 for unlimited
  
  inputs:
    files:
      # List input files this phase needs
      - name: ${INPUT_FILE_PARAM}  # Parameter name (e.g., FEATURE_SPEC)
        required: true  # Is this file required?
        path: "${INPUT_FILE_PATH}"  # Optional: explicit path
        description: "${INPUT_FILE_DESC}"  # What this file contains
    
    parameters:
      # List input parameters this phase needs
      - name: ${INPUT_PARAM}  # e.g., OUTPUT_DIR
        required: true  # Is this parameter required?
        default: ${DEFAULT_VALUE}  # Optional: default value
        description: "${INPUT_PARAM_DESC}"  # Parameter purpose
  
  outputs:
    files:
      # List files this phase will create
      - path: "${OUTPUT_FILE_PATH}"  # e.g., "$OUTPUT_DIR/report.md"
        description: "${OUTPUT_FILE_DESC}"  # What this file contains
    
    parameters:
      # List parameters this phase provides to next phases
      - name: ${OUTPUT_PARAM}  # e.g., VALIDATION_PASSED
        description: "${OUTPUT_PARAM_DESC}"  # What this parameter represents
  
  # Optional: Suggest a specific agent for this phase
  # preferred_agent: phase-executor
---

# Phase ${PHASE_NUMBER}: ${PHASE_NAME}

**Purpose**: ${PHASE_PURPOSE}

## Prerequisites
${PREREQUISITES_LIST}

## Tasks for Todo List
When starting this phase, add these tasks:
${TASKS_LIST}

## Parameters Used
${PARAMETERS_LIST}

## Process

${PROCESS_STEPS}

## Outputs
${OUTPUTS_LIST}

## Success Criteria
${SUCCESS_CRITERIA}

## Error Handling

${ERROR_HANDLING}

## Rollback Plan
${ROLLBACK_PLAN}

## Notes
${ADDITIONAL_NOTES}