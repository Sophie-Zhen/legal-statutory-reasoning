# Stage 1: Query Generation

This module implements Stage 1 of the SARA natural language to Prolog translation pipeline. In Stage 1, we generate only the Prolog queries (answer/2 predicates) for test cases, using the existing SARA statute implementations and case facts.

## Directory Structure

```
stage1/
├── core/                      # Core functionality
│   ├── __init__.py
│   ├── case_parser.py        # Parse test cases and load facts
│   └── query_generator.py    # Generate Prolog queries using LLM
├── prompts/                  # Prompt templates
│   ├── __init__.py
│   ├── stage1_base_prompt.txt
│   └── specialized_prompts.py
├── utils/                    # Utility functions
│   ├── __init__.py
│   └── prolog_executor.py   # Execute Prolog queries
├── llm/                      # LLM client (existing)
│   └── gemini_client.py
├── stage1_results/           # Results directory (created at runtime)
├── run_stage1.py            # Main runner script
├── config.py                # Configuration settings
└── README.md                # This file
```

## Setup

1. Ensure you have SWI-Prolog installed:
   ```bash
   brew install swi-prolog  # macOS
   # or
   apt-get install swi-prolog  # Ubuntu/Debian
   ```

2. Set up your Gemini API key:
   ```bash
   export GEMINI_API_KEY="your-api-key-here"
   ```

3. Update paths in `config.py` if needed.

## Usage

### Run all test cases:
```bash
python run_stage1.py
```

### Run with specific model:
```bash
python run_stage1.py --model gemini-1.5-pro
```

### Test a single case:
```bash
python run_stage1.py --test-single s1_d_iv_neg
```

### Limit number of cases (for testing):
```bash
python run_stage1.py --limit 10
```

## How It Works

1. **Case Loading**: The `CaseParser` loads test cases from `sara_parallel.jsonl` and extracts:
   - Case ID
   - Natural language text
   - Question and question type
   - Prolog facts from the case file

2. **Query Generation**: The `Stage1QueryGenerator`:
   - Creates a prompt with available predicates and case information
   - Sends the prompt to the LLM (Gemini)
   - Extracts the generated `answer/2` predicate

3. **Execution**: The `PrologExecutor`:
   - Creates a temporary Prolog file
   - Loads SARA statutes and case facts
   - Executes the generated query
   - Returns the result

4. **Evaluation**: Results are compared against expected outcomes:
   - For yes/no questions: Check if boolean result matches expectation
   - For tax amount questions: Check if calculated amount matches expected

## Output

Results are saved in timestamped directories:
- `stage1_results_YYYYMMDD_HHMMSS/`
  - `final_results.json` - Detailed results for each case
  - `results.csv` - Summary in CSV format
  - `summary.txt` - Overall accuracy statistics
  - Individual query files for each case

## Accuracy Metrics

The system tracks:
- **Success Rate**: Percentage of queries that execute without errors
- **Accuracy Rate**: Percentage of queries that produce correct results
- Breakdowns by question type (entailment, contradiction, tax_amount)

## Troubleshooting

1. **SWI-Prolog not found**: Update `SWIPL_COMMAND` in `config.py`
2. **Timeout errors**: Increase `PROLOG_TIMEOUT` in `config.py`
3. **API errors**: Check your Gemini API key and quota

## Next Steps

- Stage 2: Generate both facts and queries from natural language
- Stage 3: Full translation including statute rules