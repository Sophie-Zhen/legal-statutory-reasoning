# Prolog Integration for SARA Testing

This module provides integration between Python and Prolog for testing the SARA (Statutory Reasoning) dataset.

## Components

- `test_sara.py`: Main testing script that runs Prolog queries on the SARA dataset
- `sara_test_results.csv`: Results of the Prolog-based testing
- `swipl.pkg`: SWI-Prolog package configuration

## Requirements

- SWI-Prolog (version 9.2.9 or compatible)
- Python packages:
  - datasets
  - pandas
  - numpy

## Usage

```python
from sara_hybrid.integration.prolog import clean_prolog_code, run_prolog_query

# Clean Prolog code
cleaned_facts = clean_prolog_code(prolog_code)

# Run a Prolog query
result = run_prolog_query(facts, query)
```

## Features

- Automatic cleaning and formatting of Prolog code
- Support for both regular and negated queries
- Integration with the SARA dataset
- Results logging to CSV

## Notes

- The module assumes SWI-Prolog is installed at `/opt/homebrew/Cellar/swi-prolog/9.2.9/bin/swipl`
- Test results are saved to `sara_test_results.csv` 