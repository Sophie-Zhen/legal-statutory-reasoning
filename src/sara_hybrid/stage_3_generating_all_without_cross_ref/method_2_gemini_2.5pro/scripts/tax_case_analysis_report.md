# Tax Case Analysis Report

## Summary
- Total tax cases analyzed: 100
- Cases with fact extraction failures: 93
- Cases with query generation failures: 80
- Cases with empty query bodies: 4

## Question Type Distribution
- calculation: 100 cases

## Failure Reasons
- fact_extraction_failed: 93 cases
- query_generation_failed: 80 cases
- missing_gross_income: 98 cases
- missing_filing_status: 100 cases
- missing_taxpayer: 100 cases
- empty_query_body: 4 cases

## Recommendations
1. Fact extraction failed for 93 cases - improve fact extraction prompts for tax scenarios
2. Query generation failed for 80 cases - improve query generation for tax calculations
3. Empty query bodies generated for 4 cases - fix query generation to include proper tax calculation predicates
4. Missing gross_income facts for 98 cases - improve income extraction from text
5. Missing filing_status facts for 100 cases - improve filing status detection

## Detailed Case Analysis
### tax_case_1
- Question type: calculation
- Facts extracted: 0
- Query generated: False
- Primary failure: fact_extraction_failed

### tax_case_10
- Question type: calculation
- Facts extracted: 0
- Query generated: False
- Primary failure: fact_extraction_failed

### tax_case_100
- Question type: calculation
- Facts extracted: 0
- Query generated: False
- Primary failure: fact_extraction_failed

### tax_case_11
- Question type: calculation
- Facts extracted: 0
- Query generated: False
- Primary failure: fact_extraction_failed

### tax_case_12
- Question type: calculation
- Facts extracted: 0
- Query generated: False
- Primary failure: fact_extraction_failed
