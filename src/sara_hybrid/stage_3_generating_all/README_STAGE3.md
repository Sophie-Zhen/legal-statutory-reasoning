# Stage 3: Semantic Legal Fact Generation Pipeline

This directory contains Stage 3 of the SARA pipeline, which focuses on **semantic legal fact generation** using LLMs to convert natural language legal cases into executable Prolog facts and queries compatible with the Method 2 codebase.

## Overview

Stage 3 automates the conversion of legal case descriptions from natural language to structured Prolog facts and queries. It processes the 120 test cases from the SARA v3 dataset and generates semantic facts that can be executed against the Method 2 Prolog codebase.

### Key Features
- **Semantic Fact Extraction**: Uses Gemini API to extract structured facts from natural language case descriptions
- **Query Generation**: Generates answer/2 predicates for legal reasoning queries
- **Method 2 Compatibility**: Ensures generated code works with the Method 2 Prolog codebase
- **Caching System**: Implements intelligent caching to avoid redundant API calls
- **Accuracy Testing**: Comprehensive testing framework for evaluating generated facts and queries

## Directory Structure

```
stage_3_generating_all/
├── method_2_gemini_2.5pro/
│   ├── scripts/                           # Core pipeline scripts
│   │   ├── stage3_pipeline.py            # Main pipeline coordinator
│   │   ├── stage3_fact_extractor.py      # Semantic fact extraction
│   │   ├── stage3_query_generator.py     # Query generation
│   │   ├── stage3_case_parser.py         # Case file parsing
│   │   ├── stage3_individual_accuracy_runner.py # Individual case testing
│   │   ├── method2_codebase_accuracy_runner.py # Method 2 accuracy testing
│   │   ├── shared_accuracy_engine.py     # Shared accuracy testing logic
│   │   ├── stage3_cache_manager.py       # Caching system
│   │   ├── dynamic_prompt_generator.py   # Dynamic prompt generation
│   │   ├── model_config.py              # Model configuration management
│   │   ├── flexible_runner.py           # Flexible execution runner
│   │   ├── smoke_tester.py              # Prolog syntax validation
│   │   ├── prolog_parser.py             # Prolog file parsing
│   │   ├── gemini_generator.py          # Gemini API interface
│   │   ├── cache_utils.py               # Cache utilities
│   │   ├── codebase_analyzer.py         # Codebase analysis
│   │   ├── debug_gemini_responses.py    # Response debugging
│   │   ├── analyze_passed_cases_without_facts.py # Analysis utilities
│   │   ├── reprocess_cached_queries.py  # Query reprocessing
│   │   ├── init.py                      # Pipeline initialization
│   │   ├── run_pipeline.py              # Legacy pipeline runner
│   │   └── *.json                       # Analysis and configuration files
│   ├── results/                         # Pipeline execution results
│   │   ├── pipeline_summary.txt         # Human-readable summary
│   │   ├── pipeline_summary.json        # Detailed pipeline results
│   │   ├── smoke_test_results.txt       # Syntax validation results
│   │   ├── stage3_test_split/           # Test split results
│   │   │   ├── prolog/                  # Generated Prolog files
│   │   │   │   ├── s*.pl               # Section-specific cases
│   │   │   │   ├── tax_case_*.pl       # Tax calculation cases
│   │   │   │   └── *.pl                # Other case files
│   │   │   ├── acc_analysis/           # Accuracy analysis results
│   │   │   ├── run_llm_log/            # LLM interaction logs
│   │   │   ├── results_final_*.json    # Final results files
│   │   │   └── summary_final_*.json    # Summary files
│   │   └── llm_log/                     # LLM response logs
│   ├── intermediate_files/              # Intermediate processing files
│   ├── prolog_codebase/                 # Method 2 Prolog codebase
│   │   ├── section*.pl                  # Legal section implementations
│   │   ├── helpers.pl                   # Helper predicates
│   │   ├── knowledge_base.pl            # Knowledge base
│   │   └── tests.pl                     # Test cases and expected results
│   ├── cache/                           # Caching directory
│   │   └── stage3_test_split/           # Cache for test split
│   ├── statutes.txt                     # Merged legal statutes
│   └── selected_cases.txt               # Selected test cases
```

## Prerequisites

### 1. Python Dependencies
```bash
pip install google-generativeai pathlib
```

### 2. SWI-Prolog
Install SWI-Prolog for Prolog syntax validation and execution:
- **macOS**: `brew install swi-prolog`
- **Ubuntu/Debian**: `sudo apt-get install swi-prolog`
- **Windows**: Download from [SWI-Prolog website](https://www.swi-prolog.org/download/stable)

### 3. Environment Variables
Set your Gemini API key:
```bash
export GEMINI_API_KEY="your_gemini_api_key_here"
```

### 4. Data Requirements
Ensure the SARA v3 dataset is available:
- `data/sara_v3/cases/` - Case files
- `data/sara_v3/splits/test` - Test split case list
- `data/sara_v3/statutes/source/` - Legal statute files

## Quick Start

### 1. Initialize the Pipeline
```bash
cd src/sara_hybrid/stage_3_generating_all/method_2_gemini_2.5pro/scripts/

# Initialize the pipeline
python init.py
```

### 2. Run the Main Pipeline
```bash
# Run the complete Stage 3 pipeline
python stage3_pipeline.py
```

### 3. Run Individual Components
```bash
# Test individual case processing
python stage3_individual_accuracy_runner.py

# Run Method 2 accuracy testing
python method2_codebase_accuracy_runner.py

# Analyze results
python analyze_passed_cases_without_facts.py
```

## Pipeline Components

### 1. Stage 3 Pipeline (`stage3_pipeline.py`)
- **Purpose**: Main coordinator for the Stage 3 pipeline
- **Features**:
  - Processes 120 test cases from SARA v3
  - Orchestrates fact extraction and query generation
  - Manages caching and result storage
  - Handles batch processing and error recovery

### 2. Fact Extractor (`stage3_fact_extractor.py`)
- **Purpose**: Extracts semantic facts from natural language case descriptions
- **Features**:
  - Uses Gemini API with semantic prompts
  - Generates Method 2 compatible facts
  - Implements retry mechanisms
  - Validates extraction quality

### 3. Query Generator (`stage3_query_generator.py`)
- **Purpose**: Generates answer/2 predicates for legal reasoning queries
- **Features**:
  - Question type classification
  - Type consistency validation
  - Dynamic prompt generation
  - Structured response parsing

### 4. Case Parser (`stage3_case_parser.py`)
- **Purpose**: Parses SARA v3 case files
- **Features**:
  - Extracts case text and questions
  - Handles various case formats
  - Validates case structure

### 5. Cache Manager (`stage3_cache_manager.py`)
- **Purpose**: Manages caching of LLM responses and results
- **Features**:
  - Intelligent caching strategies
  - Cache invalidation
  - Performance optimization

## Pipeline Workflow

### 1. Initialization Phase
- Load test split cases (120 cases)
- Initialize caching system
- Set up Method 2 codebase context
- Configure LLM models and prompts

### 2. Case Processing Phase
For each case:
- **Parse Case**: Extract text and question from case file
- **Extract Facts**: Use LLM to generate semantic facts
- **Generate Query**: Create answer/2 predicate for the question
- **Save Prolog File**: Create executable Prolog file
- **Cache Results**: Store for future use

### 3. Validation Phase
- **Syntax Testing**: Validate Prolog syntax using SWI-Prolog
- **Execution Testing**: Test generated files against Method 2 codebase
- **Accuracy Analysis**: Compare results with expected outcomes

### 4. Analysis Phase
- **Generate Reports**: Create comprehensive analysis reports
- **Save Results**: Store all results and logs
- **Performance Metrics**: Calculate success rates and efficiency

## Configuration

### Model Configuration
- **Primary Model**: `gemini-2.0-flash-exp` (fast and efficient)
- **Fallback Model**: `gemini-2.5-pro` (for complex cases)
- **Max Retries**: 3 attempts per operation
- **Timeout**: 30 seconds per API call

### Prompt Modes
- **Full Mode**: Comprehensive prompts with full context
- **Fast Mode**: Streamlined prompts for efficiency
- **Emergency Mode**: Minimal prompts for fallback scenarios

### Caching Strategy
- **Cache Duration**: 24 hours for LLM responses
- **Cache Invalidation**: Automatic on codebase changes
- **Cache Size**: Unlimited with cleanup on disk space

## Expected Output

### Generated Files
Each case generates a Prolog file with:
```prolog
% case_id - Generated by Stage 3 Method 2 Pipeline
% Generated on: YYYY-MM-DD HH:MM:SS
% Total facts extracted: N

% MODULE IMPORTS
:- use_module('../../../prolog_codebase/section1').
:- use_module('../../../prolog_codebase/section2').
% ... other imports

% SEMANTIC FACTS (Generated from natural language text)
fact(case_id, predicate(args)).
% ... more facts

% QUERY (Generated from natural language question)
answer(case_id, Result) :- query_predicate(args, Result).
```

### Results Structure
- **120 Prolog Files**: One for each test case
- **Execution Logs**: Detailed logs of Prolog execution
- **Accuracy Reports**: Success rates and error analysis
- **LLM Response Logs**: Raw API responses for debugging

## Testing and Validation

### 1. Individual Case Testing
```bash
python stage3_individual_accuracy_runner.py
```
Tests individual cases and provides detailed results.

### 2. Method 2 Accuracy Testing
```bash
python method2_codebase_accuracy_runner.py
```
Tests against the Method 2 codebase using tests.pl approach.

### 3. Smoke Testing
```bash
python smoke_tester.py
```
Validates Prolog syntax for all generated files.

### 4. Analysis Tools
```bash
# Analyze cases without facts
python analyze_passed_cases_without_facts.py

# Debug LLM responses
python debug_gemini_responses.py

# Analyze codebase
python codebase_analyzer.py
```

## Performance Optimization

### Caching Benefits
- **API Cost Reduction**: Avoid redundant LLM calls
- **Speed Improvement**: Faster processing of cached cases
- **Reliability**: Consistent results across runs

### Batch Processing
- **Parallel Execution**: Process multiple cases simultaneously
- **Resource Management**: Efficient memory and API usage
- **Error Recovery**: Continue processing despite individual failures

### Model Selection
- **Fast Model**: Use for simple cases to reduce costs
- **Pro Model**: Use for complex cases requiring reasoning
- **Automatic Fallback**: Switch models on failure

## Troubleshooting

### Common Issues

1. **API Key Issues**
   ```bash
   # Verify API key is set
   echo $GEMINI_API_KEY
   # Set if missing
   export GEMINI_API_KEY="your_key_here"
   ```

2. **SWI-Prolog Not Found**
   ```bash
   # Check installation
   which swipl
   # Install if missing
   brew install swi-prolog  # macOS
   ```

3. **Cache Issues**
   ```bash
   # Clear cache
   python stage3_cache_manager.py --clear
   # Check cache status
   python stage3_cache_manager.py --status
   ```

4. **Memory Issues**
   ```bash
   # Reduce batch size
   python stage3_pipeline.py --batch-size 10
   # Use fast mode
   python stage3_pipeline.py --prompt-mode fast
   ```

### Debug Mode
Enable detailed logging:
```bash
export DEBUG=1
python stage3_pipeline.py
```

## Results Analysis

### Success Metrics
- **Fact Extraction Rate**: Percentage of cases with extracted facts
- **Query Generation Rate**: Percentage of cases with generated queries
- **Syntax Success Rate**: Percentage of files passing syntax validation
- **Execution Success Rate**: Percentage of files executing successfully
- **Accuracy Rate**: Percentage of correct results

### Output Files
- **`pipeline_summary.json`**: Detailed pipeline execution data
- **`pipeline_summary.txt`**: Human-readable summary
- **`results_final_*.json`**: Final results for each run
- **`summary_final_*.json`**: Summary statistics
- **`prolog_execution.log`**: Prolog execution logs

## Contributing

### Adding New Cases
1. Add case files to `data/sara_v3/cases/`
2. Update test split in `data/sara_v3/splits/test`
3. Run pipeline to process new cases

### Modifying Prompts
1. Edit `dynamic_prompt_generator.py`
2. Test with individual cases
3. Run full pipeline to validate changes

### Extending Analysis
1. Create new analysis scripts in `scripts/`
2. Follow existing patterns for consistency
3. Update documentation

## License

This project is part of the SARA (Statutory Reasoning with AI) research project.

## Contact

For questions or issues, please refer to the main project documentation or create an issue in the project repository. 