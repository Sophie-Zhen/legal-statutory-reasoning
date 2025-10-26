# Text-to-Symbolic Statutory Reasoning

Automating natural language to Prolog conversion for legal statutory reasoning using Large Language Models.

## Project Overview

This project explores automated conversion of natural language statutory descriptions into executable Prolog code for legal reasoning. Using the SARA (Statutory Article Representation and Application) dataset from US tax code, we implement and evaluate multiple LLM-based approaches to bridge the gap between human-readable legal text and machine-executable logic.

**Key Innovation**: A multi-stage pipeline that combines prompt engineering, automated validation, and iterative refinement to achieve high accuracy in statute-to-code translation.

## Research Context

**Course**: M.Sc. Practicum Project, Dublin City University  
**Domain**: Natural Language Processing + Legal AI  
**Dataset**: SARA - US Tax Code statutory reasoning cases  
**Challenge**: Convert complex legal statutes (natural language) into verifiable Prolog predicates

## Technical Approach

### Multi-Stage Pipeline Architecture

#### **Stage 1: Rule Translation**
- **Input**: Natural language statutory rules
- **Process**: GPT-4/Gemini-based translation with structured prompts
- **Output**: Prolog predicates representing legal rules
- **Validation**: Syntax checking, predicate verification

#### **Stage 2: Fact & Query Generation**
- **Input**: Legal test cases (natural language scenarios)
- **Process**: Entity extraction → Fact generation → Query formulation
- **Output**: Prolog facts and queries for case evaluation
- **Validation**: Execution-based correctness testing

#### **Stage 3: End-to-End Integration**
- **Hybrid Approach**: Combines LLM translation with symbolic reasoning
- **Cross-Reference Resolution**: Handles inter-statute dependencies
- **Iterative Refinement**: Auto-correction based on execution feedback

#### **Stage 4: Interactive Prompting**
- **Error Analysis**: Detailed failure case examination
- **Self-Correction**: LLM-guided debugging and fixes
- **Provenance Tracking**: Complete audit trail of transformations

### Key Techniques

- **Prompt Engineering**: Carefully crafted templates with examples and constraints
- **Executable Validation**: Prolog parse/compile checks + execution testing
- **Automated Evaluation**: Precision/recall metrics on SARA test cases
- **Multi-Model Comparison**: GPT-4, GPT-4-mini, Gemini 2.5 Pro evaluation

## Results & Achievements

### Performance Metrics
- **Best Accuracy**: 64% on 100-case test set (Stage 2)
- **Rule Translation**: High syntactic correctness (>90%)
- **Challenge Areas**: Complex cross-references, edge cases

### Key Findings
- **Staged approach** outperforms end-to-end translation
- **Validation feedback** crucial for iterative improvement
- **Model comparison**: GPT-4 vs Gemini trade-offs identified
- **Error patterns**: Systematic analysis of failure modes

## Technologies & Tools

**Programming Languages:**
- Python (primary)
- Prolog (SWI-Prolog for execution)

**LLM APIs:**
- OpenAI GPT-4, GPT-4-mini
- Google Gemini 2.5 Pro

**Key Libraries:**
- OpenAI API, Google Generative AI
- subprocess (Prolog integration)
- JSON, YAML (data handling)

**Development Tools:**
- Git version control
- Automated testing frameworks
- Result logging and analysis

## Project Structure

```
├── src/
│   ├── gpt-statutes/           # Direct GPT-4 experiments on SARA
│   │   └── sara_run/           # Prompt variations and results
│   ├── query_generation/       # Multi-stage pipeline
│   │   ├── stage1/            # Rule translation
│   │   └── stage2/            # Fact/query generation
│   ├── sara_hybrid/           # Integrated approaches
│   │   ├── llm_translation/   # Translation methods comparison
│   │   ├── stage_3_generating_all/  # Full pipeline
│   │   └── stage4_interactive/      # Interactive debugging
│   └── sara_llm_translator/   # Generated Prolog code
├── docs/
│   ├── documentation/         # Project reports and literature review
│   └── proposal/             # Initial project proposal
├── data/                     # SARA dataset and test cases
├── results/                  # Experimental outputs
└── logs/                     # Execution logs and traces
```

## Key Contributions

1. **Reproducible Pipeline**: End-to-end automation from text to validated Prolog
2. **Comprehensive Validation**: Multi-level checking (syntax → semantics → execution)
3. **Error Analysis**: Systematic categorization of translation failures
4. **Model Comparison**: Empirical evaluation of different LLM approaches
5. **Practical Insights**: Lessons for legal AI and code generation tasks

## Experimental Workflow

### Running the Pipeline

1. **Stage 1 - Rule Translation**:
   ```bash
   python src/query_generation/stage1/stage1_test_run.py
   ```

2. **Stage 2 - Fact/Query Generation**:
   ```bash
   python src/query_generation/stage2/stage2_test_run.py
   ```

3. **Full Integration**:
   ```bash
   python src/sara_hybrid/stage_3_generating_all/method_2_gemini_2.5pro/scripts/run_pipeline.py
   ```

### Validation & Evaluation

- Automated accuracy testing against SARA ground truth
- Prolog execution verification
- Error categorization and reporting

## Research Methodology

**Iterative Development Approach:**
1. **Baseline**: Direct LLM translation (Stage 1)
2. **Enhancement**: Add fact generation (Stage 2)
3. **Integration**: Full hybrid system (Stage 3)
4. **Refinement**: Interactive error correction (Stage 4)

**Evaluation Strategy:**
- Quantitative: Accuracy on SARA test cases
- Qualitative: Error analysis and categorization
- Comparative: Multiple LLM performance analysis

## Academic Context

This project demonstrates:
- **NLP → Code Generation**: Specialized domain adaptation
- **Prompt Engineering**: Structured approaches for complex tasks
- **Validation Frameworks**: Ensuring correctness in AI-generated code
- **Legal AI**: Practical challenges in statutory reasoning automation

## Future Directions

- **Improved Cross-Reference Handling**: Better resolution of inter-statute dependencies
- **Fine-Tuning**: Domain-specific model training on legal corpora
- **Extended Evaluation**: Testing on broader legal domains beyond tax code
- **Interactive Tools**: User-friendly interfaces for legal professionals

## Documentation

Full technical reports and documentation are available in the academic repository.

## Project Outcomes

- Demonstrated feasibility of automated statute-to-code translation
- Identified key challenges and limitations in current LLM approaches
- Provided reproducible framework for future legal AI research
- Achieved competitive accuracy on established benchmark (SARA dataset)

---

**Authors**: Songhui Zhen, Saw Pu  
**Institution**: Dublin City University  
**Program**: M.Sc. Computer Science (Natural Language Processing)  
**Year**: 2024-2025  
**Supervisors**: Anya Belz, James O'Doherty

## License

This project is for academic research purposes.