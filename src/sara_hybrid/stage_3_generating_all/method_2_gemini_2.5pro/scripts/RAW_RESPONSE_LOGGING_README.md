# Raw LLM Response Logging Implementation

## Overview

This implementation adds comprehensive raw LLM response logging to the Stage 3 Method 2 pipeline to help debug and trace LLM interactions. All raw responses from Gemini API calls are now captured and saved separately for analysis.

## What's Logged

### 1. Fact Extraction Responses
- **Location**: `stage3_fact_extractor.py`
- **Methods**: `extract_facts()` and `extract_with_retries()`
- **Data Captured**:
  - Original prompt sent to LLM
  - Raw response text from Gemini
  - Model name used
  - Timestamp of request
  - Error messages (if any)
  - Attempt number (for retries)

### 2. Query Generation Responses
- **Location**: `stage3_query_generator.py`
- **Methods**: `generate_query()` and `generate_with_retries()`
- **Data Captured**:
  - Original prompt sent to LLM
  - Raw response text from Gemini
  - Model name used
  - Timestamp of request
  - Error messages (if any)
  - Attempt number (for retries)

### 3. Question Analysis Responses
- **Location**: `stage3_query_generator.py`
- **Method**: `_classify_question_with_llm()`
- **Data Captured**:
  - Question analysis prompt
  - Raw JSON response from LLM
  - Classification results
  - Error messages (if parsing fails)

## File Structure

### Raw Response Data Format
```json
{
  "case_id": "s151_d_1_neg",
  "prompt": "Full prompt text sent to LLM...",
  "model": "gemini-2.0-flash-exp",
  "timestamp": 1704067200.123,
  "raw_response": "Raw text response from LLM...",
  "error": null,
  "attempt": 1
}
```

### Pipeline Results Structure
Each case result now includes:
```json
{
  "case_id": "s151_d_1_neg",
  "status": "success",
  "facts": ["fact(...)", "fact(...)"],
  "query": "answer('s151_d_1_neg', Result) :- ...",
  "raw_llm_responses": {
    "fact_extraction": [
      {
        "case_id": "s151_d_1_neg",
        "prompt": "...",
        "raw_response": "...",
        "attempt": 1
      }
    ],
    "query_generation": [
      {
        "case_id": "s151_d_1_neg", 
        "prompt": "...",
        "raw_response": "...",
        "attempt": 1
      }
    ]
  }
}
```

## Output Files

The pipeline now generates organized output files in structured directories:

### 1. Prolog Files (`results/stage3_test_split/prolog/`)
- `s151_d_1_neg.pl` - Generated Prolog files for each case
- `s151_d_2_pos.pl` - Individual case logic and queries
- Contains facts, queries, and module imports

### 2. LLM Execution Logs (`results/stage3_test_split/run_llm_log/`)

#### Results Files
- `results_final_YYYYMMDD_HHMMSS.json` - Complete case results
- `results_intermediate_N_YYYYMMDD_HHMMSS.json` - Intermediate results every 10 cases

#### Summary Files
- `summary_final_YYYYMMDD_HHMMSS.json` - High-level statistics
- `summary_intermediate_N_YYYYMMDD_HHMMSS.json` - Intermediate summaries

#### Raw Response Files (NEW)
- `raw_llm_responses_final_YYYYMMDD_HHMMSS.json` - All raw LLM responses
- `raw_llm_responses_intermediate_N_YYYYMMDD_HHMMSS.json` - Intermediate raw responses

## Usage for Debugging

### 1. Analyzing Failed Cases
```python
import json

# Load raw responses
with open('raw_llm_responses_final_20250101_120000.json', 'r') as f:
    raw_responses = json.load(f)

# Check a specific case
case_id = 's151_d_1_neg'
if case_id in raw_responses:
    fact_attempts = raw_responses[case_id]['fact_extraction']
    query_attempts = raw_responses[case_id]['query_generation']
    
    print(f"Fact extraction attempts: {len(fact_attempts)}")
    print(f"Query generation attempts: {len(query_attempts)}")
    
    # Check first fact extraction attempt
    first_fact_attempt = fact_attempts[0]
    print(f"Prompt: {first_fact_attempt['prompt'][:200]}...")
    print(f"Response: {first_fact_attempt['raw_response'][:200]}...")
```

### 2. Finding Patterns in Failures
```python
# Find cases with multiple retry attempts
retry_cases = []
for case_id, responses in raw_responses.items():
    fact_attempts = len(responses['fact_extraction'])
    query_attempts = len(responses['query_generation'])
    
    if fact_attempts > 1 or query_attempts > 1:
        retry_cases.append({
            'case_id': case_id,
            'fact_attempts': fact_attempts,
            'query_attempts': query_attempts
        })

print(f"Cases requiring retries: {len(retry_cases)}")
```

### 3. Analyzing Response Quality
```python
# Check response lengths and error patterns
for case_id, responses in raw_responses.items():
    for attempt in responses['fact_extraction']:
        if attempt['error']:
            print(f"Fact extraction error in {case_id}: {attempt['error']}")
        elif attempt['raw_response']:
            print(f"Fact response length for {case_id}: {len(attempt['raw_response'])}")
```

## Implementation Details

### Method Changes

1. **Return Type Changes**:
   - `extract_facts()`: `List[str]` → `Tuple[List[str], Dict]`
   - `extract_with_retries()`: `List[str]` → `Tuple[List[str], List[Dict]]`
   - `generate_query()`: `str` → `Tuple[str, Dict]`
   - `generate_with_retries()`: `str` → `Tuple[str, List[Dict]]`
   - `_classify_question_with_llm()`: `Dict` → `Tuple[Dict, Dict]`

2. **New Pipeline Methods**:
   - `save_raw_llm_responses()`: Extracts and saves raw responses separately
   - Updated `save_batch_results()`: Now saves raw responses automatically

### Error Handling

- All LLM API errors are captured in the raw response metadata
- Empty responses are logged with appropriate error messages
- Retry attempts are tracked with attempt numbers
- JSON parsing errors in question analysis are captured

## Benefits

1. **Complete Traceability**: Every LLM interaction is logged for debugging
2. **Retry Analysis**: Can see exactly what happened in each retry attempt
3. **Prompt Engineering**: Can analyze prompt effectiveness
4. **Error Diagnosis**: Detailed error information for troubleshooting
5. **Performance Analysis**: Response times and content lengths tracked
6. **Separate Storage**: Raw responses don't clutter main results files

## Testing

The implementation was tested with:
- ✅ Fact extraction with retries
- ✅ Query generation with retries  
- ✅ Question analysis with LLM
- ✅ JSON serialization/deserialization
- ✅ Error handling and empty responses
- ✅ Integration with existing pipeline

## Next Steps

1. **Analysis Tools**: Create scripts to analyze raw response patterns
2. **Prompt Optimization**: Use logged data to improve prompts
3. **Performance Monitoring**: Track response quality over time
4. **Automated Debugging**: Build tools to automatically identify common issues 