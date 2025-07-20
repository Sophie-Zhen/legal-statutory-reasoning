# Stage 1: LLM-based Legal Query Generation

This repository contains the implementation for Stage 1 of our legal reasoning research project, which focuses on generating Prolog queries from natural language legal questions using Large Language Models (LLMs).

## Overview

Stage 1 converts natural language legal questions into executable Prolog queries that can be tested against a formal legal knowledge base. The system uses Google's Gemini API to generate queries from tax law questions in the SARA (Statutory Analysis and Reasoning Assistant) dataset.

## Project Structure

```
stage1/
├── case_parser.py              # Parses .pl case files to extract components
├── query_generator.py          # Main LLM-based query generator
├── example_selector.py         # Few-shot example selection for prompting
├── predicate_knowledge.py      # Knowledge base of predicate signatures
├── statute_loader.py           # Loads statute files for context
├── test_accuracy.py           # Tests generated queries against golden standards
├── stage1_test_run_120.py     # Runs tests on 120 specific cases
├── run_sara_100_test.py       # Runs paper replication on 100 cases
├── stage1_test_run.py         # Runs benchmark tests
└── results/                   # Generated query results
    ├── stage1_paper_100_test/ # 100-case paper replication results
    └── stage1_test120_run/    # 120-case test results
```

## Key Components

### 1. Query Generator (`query_generator.py`)
- **Primary Function**: Converts natural language legal questions into Prolog queries
- **LLM Backend**: Google Gemini 2.0 Flash model
- **Features**:
  - Full statute text preprocessing for better LLM understanding
  - Few-shot prompting with relevant examples
  - Minimal fallback mode for true LLM performance testing
  - Rate limiting and error handling

### 2. Case Parser (`case_parser.py`)
- Extracts components from `.pl` case files:
  - Case text and questions
  - Legal facts in Prolog format
  - Golden test assertions

### 3. Predicate Knowledge Base (`predicate_knowledge.py`)
- Comprehensive database of legal predicate signatures
- Section-to-predicate mapping (e.g., "Section 151(d)(3)(A)" → `s151_d_3_A`)
- Question pattern recognition for common legal query types

### 4. Accuracy Tester (`test_accuracy.py`)
- Executes generated Prolog queries against SWI-Prolog
- Compares results with golden standard assertions
- Provides detailed error analysis and debugging information

## Usage

### Prerequisites

1. **Python Dependencies**:
   ```bash
   pip install google-generativeai python-dotenv
   ```

2. **SWI-Prolog**: Required for query execution
   ```bash
   # macOS
   brew install swi-prolog
   
   # Ubuntu/Debian
   sudo apt-get install swi-prolog
   ```

3. **API Key**: Google Gemini API key (set as `GEMINI_API_KEY` environment variable)

### Running Tests

#### 1. 100-Case Paper Replication
```bash
python run_sara_100_test.py --api-key YOUR_API_KEY --batch-size 10 --delay 10.0
```

#### 2. 120-Case Extended Test
```bash
python stage1_test_run_120.py --api-key YOUR_API_KEY --batch-size 10 --delay 10.0
```

#### 3. Minimal Fallback Mode (True LLM Performance)
```bash
python stage1_test_run_120.py --api-key YOUR_API_KEY --minimal-fallback
```

### Command Line Options

- `--api-key`: Your Gemini API key
- `--batch-size`: Number of API calls before rate limiting pause (default: 10)
- `--delay`: Seconds to pause between batches (default: 10.0)
- `--force`: Regenerate queries even if they already exist
- `--minimal-fallback`: Use minimal fallback for true LLM testing

## Research Methodology

### Test Sets

1. **100-Case Paper Replication**: Replicates the original SARA paper results excluding tax cases
2. **120-Case Extended**: Includes additional tax cases for comprehensive evaluation

### Evaluation Metrics

- **Execution Success Rate**: Percentage of queries that execute without Prolog errors
- **Accuracy**: Percentage of correctly answered questions
- **Failure Analysis**: Categorizes failures into:
  - Contradiction failures (expected false, got true)
  - Entailment failures (expected true, got false)
  - Unknown case failures
  - Predicate errors

### Few-Shot Learning

The system uses carefully curated examples to improve LLM performance:
- **Contradiction Examples**: Cases where legal assertions should fail
- **Entailment Examples**: Cases where assertions should succeed
- **Complex Predicate Mapping**: Examples showing section-to-predicate conversion

## Results Location

Generated queries and test results are saved in:
- `results/stage1_paper_100_test/`: 100-case replication results
- `results/stage1_test120_run/`: 120-case extended test results

Each results directory contains:
- Individual `.pl` files with generated queries
- `summary.json`: Detailed test statistics and error analysis

## Key Features

### 1. Statute Text Preprocessing
- Extracts predicate signatures from Prolog statute files
- Creates summary tables for LLM reference
- Formats complex legal text for better LLM comprehension

### 2. Intelligent Fallback Handling
- **Standard Mode**: Pattern-matching fallbacks for common cases
- **Minimal Mode**: Generic fallbacks that represent true LLM failures

### 3. Comprehensive Error Analysis
- Tracks undefined predicate errors
- Categorizes logical reasoning failures
- Provides debugging output for failed cases

### 4. Rate Limiting and Robustness
- Automatic rate limit detection and backoff
- Graceful handling of API errors and safety blocks
- Resume capability for interrupted runs

## Research Contributions

1. **LLM Legal Reasoning**: Demonstrates LLM capability in formal legal query generation
2. **Systematic Evaluation**: Provides framework for testing legal reasoning systems
3. **Error Analysis**: Detailed categorization of failure modes in legal LLM applications
4. **Reproducibility**: Full replication of academic benchmarks with extended test cases

## Technical Details

### Prolog Query Format
Generated queries follow the pattern:
```prolog
answer('case_id', Result) :- 
    (predicate(arguments) -> Result = true ; Result = false).
```

### Section Mapping Examples
- "Section 151(d)(3)(A)" → `s151_d_3_A`
- "Section 63(c)(6)(B)" → `s63_c_6_B`
- "Section 1(a)(2)(iv)" → `s1_a_2_iv`

### Supported Question Types
- Tax calculation queries
- Section applicability questions
- Exemption and deduction determinations
- Dependency relationship assertions

## Future Work

- Integration with more sophisticated legal reasoning frameworks
- Extension to other legal domains beyond tax law
- Improved error recovery and query repair mechanisms
- Multi-step reasoning for complex legal scenarios

## Academic Context

This work is part of ongoing research into applying Large Language Models to formal legal reasoning tasks, building upon the SARA (Statutory Analysis and Reasoning Assistant) framework for automated legal analysis.

## Citation

If you use this code in your research, please cite our work:
```
[Citation to be added upon publication]
```

---

**Note**: This is research code for academic purposes. The legal reasoning capabilities demonstrated here are for educational and research use only and should not be used for actual legal advice or decision-making.