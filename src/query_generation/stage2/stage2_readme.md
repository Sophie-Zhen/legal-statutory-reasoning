# Stage 2: Natural Language to Prolog Facts & Query Generation

## Architecture

The Stage 2 pipeline consists of two main phases:

1. **Text → Facts**: Convert natural language legal scenarios into structured Prolog facts
2. **Facts + Question → Query**: Generate executable Prolog queries from the generated facts

### Key Components

```
stage2/
├── stage2_main.py          # Main pipeline orchestrator
├── fact_generator.py       # LLM-based fact generation
├── query_generator.py      # LLM-based query generation (reused from Stage 1)
├── entity_extractor.py     # Entity recognition and span calculation
├── fact_templates.py       # Template-based fact generation
├── example_selector.py     # Few-shot example selection
├── case_parser.py          # Case file parsing
├── predicate_knowledge.py  # Predicate signature database
├── prolog_executor.py      # Query execution engine
├── test_accuracy.py        # Accuracy testing framework
└── stage2_test_run.py      # Test execution scripts
```

## Features

### 1. Advanced Entity Extraction
- **Span-accurate positioning**: Implements inclusive end positions matching golden facts
- **Multi-entity recognition**: People, amounts, dates, relationships, employment
- **Legal relationship parsing**: Spouse, dependent, employer-employee relationships
- **Date normalisation**: Converts various date formats to YYYYMMDD format

### 2. Template-Based Fact Generation
- **Structured templates**: Pre-defined templates for common legal scenarios
- **Event modeling**: Income, payment, marriage, employment events
- **Relationship facts**: Bidirectional spouse relationships, dependency chains
- **Computed predicates**: Section-specific tax law predicates (s63, s151, s152, etc.)

### 3. LLM-Enhanced Generation
- **Gemini 2.5 Pro integration**: Advanced language model for complex fact generation
- **Few-shot learning**: Dynamic example selection based on text similarity
- **Fallback mechanisms**: Pattern-based generation when LLM fails
- **Rate limiting**: Intelligent batching to handle API limits

### 4. Comprehensive Testing Framework
- **Prolog execution**: Direct testing with SWI-Prolog
- **Error categorisation**: Detailed failure analysis
- **Performance metrics**: Success rates, accuracy, error distribution
- **Comparative analysis**: Stage 1 vs Stage 2 performance tracking

## Performance Results

### Latest Results Summary

| Test Set | Cases | Accuracy | Fact Gen Rate | Query Gen Rate | Execution Rate |
|----------|-------|----------|---------------|----------------|----------------|
| 100 Cases | 100  | **64%**  | 95%+          | 95%+           | 85%+           |
| 120 Cases | 120  | **55%**  | 95%+          | 95%+           | 85%+           |

### Key Achievements
- **Fully automated pipeline**: No dependency on golden facts
- **High generation success**: >95% fact and query generation rates
- **Competitive accuracy**: 55-64% on challenging legal reasoning tasks
- **Robust error handling**: Comprehensive fallback mechanisms

## Installation

### Prerequisites
```bash
# Python dependencies
pip install google-generativeai python-dotenv

# SWI-Prolog (required for query execution)
# macOS: brew install swi-prolog
# Ubuntu: apt-get install swi-prolog
```

### Environment Setup
```bash
# Set up API key
export GEMINI_API_KEY="your_gemini_api_key"

# Or create .env file
echo "GEMINI_API_KEY=your_gemini_api_key" > .env
```

## Usage

### Basic Pipeline Execution
```bash
# Run on 20 test cases (default)
python stage2_main.py

# Run on specific number of cases
python stage2_main.py --test 50

# Run on all test cases
python stage2_main.py --all

# Run with custom settings
python stage2_main.py --test 30 --batch-size 5 --delay 15 --run-name "experiment_1"
```

### Specialised Test Sets
```bash
# Run on 100 paper cases (non-tax)
python stage2_test_run.py --paper-100

# Run subset with custom parameters
python stage2_test_run.py --paper-100 --subset 20 --batch-size 5

# Skip already processed cases
python stage2_test_run.py --paper-100 --skip-existing
```

### Testing Generated Queries
```bash
# Test a specific results directory
python test_accuracy.py results/stage2_run_20241201_143022

# Test with verbose output
python test_accuracy.py results/stage2_run_20241201_143022 --verbose
```

## Technical Implementation

### Entity Extraction with Inclusive Spans
```python
# Example: "Alice has a brother, Bob"
entities = {
    'persons': [
        Person(name='Alice', start=0, end=4),    # Inclusive end
        Person(name='Bob', start=21, end=23)
    ],
    'relationships': [
        Relationship(type='brother', subject='Alice', object='Bob')
    ]
}
```

### Fact Template System
```python
# Income event template
income_facts = fact_templates.generate_income_facts({
    'event_text': 'income',
    'event_start': 15,
    'event_end': 20,
    'person': 'Alice',
    'person_start': 0,
    'person_end': 4,
    'amount': 50000,
    'year': 2017
})
```

### LLM Prompt Engineering
The system uses sophisticated prompting with:
- **Few-shot examples**: Dynamically selected based on text similarity
- **Span calculation guidance**: Explicit instructions for inclusive positioning
- **Legal context**: Tax law specific predicates and relationships
- **Error recovery**: Multiple fallback strategies

## File Structure

### Input Files
- **Case files** (`*.pl`): Natural language text, questions, and golden facts
- **Statute files**: Prolog predicate definitions and legal rules

### Output Files
```
results/stage2_run_timestamp/
├── generated_facts/         # Generated Prolog facts
│   ├── case1_facts.pl
│   └── case2_facts.pl
├── generated_queries/       # Generated queries
│   ├── case1.pl
│   └── case2.pl
├── results.json            # Detailed results
├── summary.json            # Performance summary
└── failures.json           # Failed cases analysis
```

## Error Analysis

### Common Error Categories
1. **Undefined Predicates**: Missing or incorrect predicate names
2. **Span Calculation Errors**: Incorrect character positioning
3. **Relationship Parsing**: Complex family/business relationships
4. **Tax Law Complexity**: Section-specific predicate requirements

### Debugging Tools
```bash
# Verbose testing for detailed error analysis
python test_accuracy.py results/your_run --verbose

# Check specific case
python stage2_main.py --cases case_name.pl
```

## Research Applications

### Legal AI Research
- **Automated legal reasoning**: End-to-end text understanding
- **Knowledge representation**: Natural language to formal logic
- **Performance benchmarking**: Standardised test sets

### Comparative Studies
- **Stage 1 vs Stage 2**: Golden facts vs generated facts
- **LLM capabilities**: Complex reasoning in legal domains
- **Error pattern analysis**: Understanding failure modes

## Future Improvements

### Planned Enhancements
1. **Advanced entity linking**: Better resolution of legal entities
2. **Contextual reasoning**: Multi-sentence relationship inference
3. **Error correction**: Self-correcting fact generation
4. **Domain expansion**: Beyond tax law to general legal reasoning

### Research Directions
- **Hybrid approaches**: Combining rule-based and neural methods
- **Active learning**: Improving performance with feedback
- **Explainable AI**: Understanding model decisions


**Results Directory**: `/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts/src/query_generation/stage2/results/`
- Result_100_64%: 64% accuracy on 100 test cases
- Result_120_55%: 55% accuracy on 120 test cases