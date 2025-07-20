"""
Dynamic Prompt Generator for Stage 3 Method 2
Generates prompts using actual predicates from the Method 2 codebase
"""

import os
import logging
from typing import Dict, List
from codebase_analyzer import CodebaseAnalyzer, PredicateInfo

logger = logging.getLogger(__name__)

class DynamicPromptGenerator:
    """Generates prompts dynamically based on actual Stage 4 codebase"""
    
    def __init__(self, codebase_dir: str = None):
        if codebase_dir is None:
            # Default to Stage 4 prolog_codebase
            current_dir = os.path.dirname(os.path.abspath(__file__))
            codebase_dir = os.path.join(current_dir, "../prolog_codebase")
        self.codebase_dir = codebase_dir
        self.analyzer = CodebaseAnalyzer(codebase_dir)
        self.predicates: Dict[str, PredicateInfo] = {}
        self._load_predicates()
    
    def _load_predicates(self):
        """Load predicates from the codebase"""
        logger.info("Loading actual Method 2 predicates...")
        self.predicates = self.analyzer.analyze_codebase()
        logger.info(f"Loaded {len(self.predicates)} predicates")
    
    def generate_fact_extraction_prompt(self, mode: str = "full") -> str:
        """Generate fact extraction prompt with actual predicates"""
        if mode == "fast":
            return self._generate_fast_fact_prompt()
        elif mode == "emergency":
            return self._generate_emergency_fact_prompt()
        elif mode == "minimal":
            return self._generate_minimal_fact_prompt()
        else:
            return self._generate_full_fact_prompt()
    
    def _generate_full_fact_prompt(self) -> str:
        """Generate comprehensive fact extraction prompt"""
        predicate_vocab = self.analyzer.generate_prompt_vocabulary()
        
        return f"""You are a legal fact extractor for a Prolog-based tax law expert system. Your task is to convert a natural language case description into a set of structured, semantic Prolog facts that our system can directly use for reasoning.

**TEXT TO ANALYZE:**
{{text}}

**CODEBASE CONTEXT:**
Here is our actual system codebase with available predicates and their usage:

{{codebase}}

**AVAILABLE PREDICATES:**
Our system uses these actual predicates (extracted from the codebase):

{predicate_vocab}

**IMPORTANT NOTES:**
1. These predicates are the ACTUAL ones available in our system
2. Use only predicates listed above - don't invent new ones
3. Pay attention to arity (number of arguments) for each predicate
4. Some predicates require specific argument patterns

**FACT GENERATION RULES:**
1. Generate facts in the format: `fact({{case_id}}, predicate(args)).`
2. Use simple atoms for entities (e.g., `alice`, `bob`, `johns_hopkins_university`)
3. Represent years as integers (e.g., `2015`, `2018`)
4. For amounts, use integers without commas (e.g., `50000`, not `50,000`)
5. For filing status, use atoms like `single`, `married_filing_jointly`, `head_of_household`

**REAL EXAMPLES FROM OUR CODEBASE:**

**Example 1 (Logic case: s1_a_1_pos):**
Text: "Alice is married to Bob in 2017. They file a joint return. Their taxable income as a couple is $17,330."
Facts:
fact(s1_a_1_pos, is_married(alice, 2017)).
fact(s1_a_1_pos, spouse(alice, bob)).
fact(s1_a_1_pos, files_joint_return(alice, bob, 2017)).
fact(s1_a_1_pos, taxable_income(couple_alice_bob, 2017, 17330)).

**Example 2 (Logic case: s3306_c_5_pos):**
Text: "Alice paid Bob $3,200 in 2017 for work performed in the US. Bob is Alice's father."
Facts:
fact(s3306_c_5_pos, payment_for_service(alice, bob, 3200, 2017, work)).
fact(s3306_c_5_pos, service_performed_in_us(alice, bob, 2017)).
fact(s3306_c_5_pos, father_of(bob, alice)).
fact(s3306_c_5_pos, child_of(alice, bob)).

**Example 3 (Tax calculation: tax_case_13):**
Text: "Bob is the taxpayer in 2017 with gross income $53,249. Alice is his child, lived with him over half the year, and is a student. Bob furnishes over half the cost of the household and takes the standard deduction."
Facts:
fact(tax_case_13, taxpayer(bob)).
fact(tax_case_13, gross_income(bob, 2017, 53249)).
fact(tax_case_13, adjusted_gross_income(bob, 2017, 53249)).
fact(tax_case_13, child_of(alice, bob)).
fact(tax_case_13, lived_with_over_half_year(alice, bob, 2017)).
fact(tax_case_13, furnishes_over_half_cost_of_household(bob, 2017)).
fact(tax_case_13, takes_standard_deduction(bob, 2017)).
fact(tax_case_13, birth_year(bob, 1970)).
fact(tax_case_13, birth_year(alice, 1996)).
fact(tax_case_13, student(alice, 2017)).
fact(tax_case_13, gross_income(alice, 2017, 0)).

**Example 4 (Tax calculation: tax_case_26):**
Text: "Alice is the taxpayer in 2019 with gross income $567,192. She takes the standard deduction, is the parent of Charlie, who lived with her over half the year. Alice furnishes over half the cost of the household. Charlie has no income."
Facts:
fact(tax_case_26, taxpayer(alice)).
fact(tax_case_26, gross_income(alice, 2019, 567192)).
fact(tax_case_26, adjusted_gross_income(alice, 2019, 567192)).
fact(tax_case_26, takes_standard_deduction(alice, 2019)).
fact(tax_case_26, father_of(charlie, alice)).
fact(tax_case_26, child_of(alice, charlie)).
fact(tax_case_26, lived_with_over_half_year(charlie, alice, 2019)).
fact(tax_case_26, furnishes_over_half_cost_of_household(alice, 2019)).
fact(tax_case_26, gross_income(charlie, 2019, 0)).
fact(tax_case_26, birth_year(alice, 1980)).
fact(tax_case_26, birth_year(charlie, 1950)).

**CRITICAL:**
- Generate only `fact({{case_id}}, ...).` clauses
- Use ONLY the predicates listed in the AVAILABLE PREDICATES section
- The case ID will be `{{case_id}}`
- Don't invent predicates not in our actual codebase

Generate ONLY the Prolog facts for the text above, using `{{case_id}}` as the case identifier."""

    def _generate_fast_fact_prompt(self) -> str:
        """Generate fast fact extraction prompt"""
        return """Convert text to Method 2 semantic Prolog facts using ACTUAL predicates from our codebase.

TEXT: {text}
CASE_ID: {case_id}

Use only these actual predicates:
- personal_exemption_deduction/4 - for exemptions
- tax_imposed/4 - for tax calculations  
- standard_deduction/4 - for standard deductions
- filing_status/4 - for filing status
- exemption_amount/4 - for specific exemption amounts

Format: fact(CaseID, predicate(...)).

Generate facts:"""

    def _generate_emergency_fact_prompt(self) -> str:
        """Generate emergency fact extraction prompt"""
        return """Extract basic facts using actual Method 2 predicates.

TEXT: {text}
CASE_ID: {case_id}

Use predicates like: personal_exemption_deduction/4, tax_imposed/4, standard_deduction/4
Format: fact(CaseID, predicate(...))."""

    def _generate_minimal_fact_prompt(self) -> str:
        """Generate minimal fact extraction prompt to avoid safety filters"""
        return """Convert this text to structured facts for a legal reasoning system.

TEXT: {text}
CASE_ID: {case_id}

TASK: Extract key information as structured facts.

EXAMPLE:
Text: "Alice received income of $50000 in 2018. She takes standard deduction."
Facts:
fact(case1, taxpayer(alice)).
fact(case1, gross_income(alice, 2018, 50000)).
fact(case1, takes_standard_deduction(alice, 2018)).

IMPORTANT: Use format fact({case_id}, predicate(...)).

Generate facts for the text above:"""

    def generate_query_generation_prompt(self, mode: str = "full") -> str:
        """Generate query generation prompt with actual predicates"""
        if mode == "fast":
            return self._generate_fast_query_prompt()
        elif mode == "emergency":
            return self._generate_emergency_query_prompt()
        elif mode == "minimal":
            return self._generate_minimal_query_prompt()
        else:
            return self._generate_full_query_prompt()
    
    def _generate_full_query_prompt(self) -> str:
        """Generate full query generation prompt with real examples and improved instructions"""
        predicate_vocab = self.analyzer.generate_prompt_vocabulary()
        # Use an f-string but escape the placeholders that are meant for the .format() call later
        return f"""You are a Prolog test case generator. Your task is to first classify a legal question and then convert it into a value-producing `answer(CaseID, Result)` predicate for our test suite.

FACTS: {{facts}}
QUESTION: {{question}}
CASE_ID: {{case_id}}

**AVAILABLE PREDICATES:**
{predicate_vocab}

**STEP 1: CLASSIFY QUESTION TYPE**
Based on the question, classify it as either `CALCULATION` or `LOGIC`.
- **CALCULATION**: The question asks for a numerical value (e.g., "How much tax...").
- **LOGIC**: The question tests a statement's truth (e.g., "...is an employer. Contradiction").

**STEP 2: GENERATE THE `answer/2` PREDICATE**
Based on the classification, generate a single `answer/2` predicate.

**RULES FOR `answer/2` PREDICATE GENERATION:**
1. The predicate must always be in the format `answer({{case_id}}, Result) :- ....`
2. The goal is to compute a final value and unify it with `Result`. Do not perform any comparison with a ground truth inside the Prolog code.
3. For **CALCULATION** questions, `Result` must be the final calculated number. The body should typically call predicates that compute a numerical value.
4. For **LOGIC** questions, `Result` must be the boolean result (`true` or `false`) of the core statement being tested. The body should call the relevant statute predicate and unify its boolean output with `Result`.

**REQUIRED OUTPUT FORMAT:**
Your output MUST strictly follow this format, including the headers `Question Type:`, `Reasoning:`, and `Query:`.

```
Question Type: [CALCULATION or LOGIC]
Reasoning: [Brief explanation of your classification.]
Query:
```prolog
answer({{case_id}}, Result) :-
    [Prolog code body].
```
```

**EXAMPLES OF THE REQUIRED OUTPUT FORMAT:**

**Example 1 (LOGIC):**
Question: "Section 3306(c)(5) applies... Entailment."
```
Question Type: LOGIC
Reasoning: The question is testing the truth of whether a specific section of the tax code applies, which is a logic-based determination.
Query:
```prolog
answer(s3306_c_5_pos, Result) :-
    is_employment_exception_child_parent(alice, bob, 2017, Result).
```
```

**Example 2 (LOGIC - Internal Comparison):**
Question: "...pay $2600... under section 1(a). Entailment."
```
Question Type: LOGIC
Reasoning: The question is testing the truth of a numerical comparison, which requires an internal check to produce a final boolean result.
Query:
```prolog
answer(s1_a_1_pos, Result) :-
    tax_imposed(married_filing_jointly, 17330, 2017, Tax),
    (Tax =:= 2600 -> Result = true ; Result = false).
```
```

**Example 3 (CALCULATION):**
Question: "How much tax does Bob pay in 2017? The answer is $8710."
```
Question Type: CALCULATION
Reasoning: The question explicitly asks "how much tax," indicating a need for a numerical calculation.
Query:
```prolog
answer(tax_case_13, Result) :-
    taxable_income(bob, tax_case_13, 2017, TI),
    filing_status(bob, tax_case_13, 2017, Status),
    tax_imposed(Status, TI, 2017, Result).
```
```

**CRITICAL FINAL INSTRUCTION:**
Your output must follow the structured format exactly.
"""

    def _generate_fast_query_prompt(self) -> str:
        """Generate fast query generation prompt with question classification"""
        return """Convert question to answer/2 predicate using ACTUAL Method 2 predicates.

FACTS: {facts}
QUESTION: {question}
CASE_ID: {case_id}

**STEP 1: CLASSIFY QUESTION TYPE**
- CALCULATION: "how much", "amount", "calculate" → seeks numerical result
- LOGIC: "entailment", "contradiction", "true/false" → tests statement truth

**STEP 2: GENERATE QUERY BASED ON TYPE**

Use actual predicates:
- statute_63:taxable_income/4 - for taxable income calculations
- statute_1:tax_imposed/4 - for tax calculations
- statute_2:filing_status/4 - for filing status determination
- statute_151:personal_exemption_deduction/4 - for exemption calculations
- statute_63:standard_deduction/4 - for standard deductions

**REQUIRED OUTPUT FORMAT:**
```
Question Type: [CALCULATION or LOGIC]
Reasoning: [Brief explanation]
Query:
```prolog
answer({case_id}, Result) :-
    [complete Prolog clause body].
```
```

CRITICAL: Generate a complete Prolog rule with a non-empty body after ':-'.
NEVER generate incomplete rules like 'answer({case_id}, Result) :-.'
Follow the REQUIRED OUTPUT FORMAT exactly."""

    def _generate_emergency_query_prompt(self) -> str:
        """Generate emergency query prompt with minimal complexity"""
        return """Convert this legal question to a Prolog answer/2 predicate.

FACTS: {facts}
QUESTION: {question}
CASE_ID: {case_id}

INSTRUCTIONS:
1. First, classify the question as CALCULATION or LOGIC
2. Generate an answer/2 predicate that produces the final result

OUTPUT FORMAT:
Question Type: [CALCULATION or LOGIC]
Reasoning: [Brief explanation]
Query:
```prolog
answer({case_id}, Result) :- [your code here].
```

EXAMPLES:
Question Type: CALCULATION
Reasoning: Tax calculation question
Query:
```prolog
answer(tax_case_1, Result) :- 
    statute_63:taxable_income(alice, tax_case_1, 2017, TI),
    statute_1:tax_imposed(single, TI, 2017, Result).
```

Question Type: LOGIC  
Reasoning: Testing section applicability
Query:
```prolog
answer(s1_pos, Result) :- 
    statute_1:applies(alice, 2017, Result).
```

Generate your response now."""

    def _generate_minimal_query_prompt(self) -> str:
        """Generate minimal query prompt to avoid safety filters"""
        return """Convert to Prolog answer/2 predicate.

FACTS: {facts}
QUESTION: {question}
CASE_ID: {case_id}

TASK: Create answer/2 predicate that computes the final result.

FORMAT:
Question Type: [CALCULATION or LOGIC]
Reasoning: [Brief explanation]
Query:
```prolog
answer({case_id}, Result) :- [predicate calls].
```

EXAMPLE:
Question Type: CALCULATION
Reasoning: Tax calculation
Query:
```prolog
answer(case1, Result) :- 
    statute_63:taxable_income(alice, case1, 2017, TI),
    statute_1:tax_imposed(single, TI, 2017, Result).
```

Generate response:"""

    def generate_question_analysis_prompt(self) -> str:
        """
        Generates the prompt for "Step 0": LLM-based question analysis and classification.
        This prompt instructs the LLM to return a structured JSON object containing the
        question type, the legal focus, and the ground truth answer.
        """
        return """You are a legal question analyzer. Your task is to analyze a natural language question from a U.S. federal tax law test case and classify it for our Prolog-based legal reasoning system.

**QUESTION TO ANALYZE:**
{question}

**ANALYSIS TASK:**
Analyze the question and provide a structured classification in the following JSON format. Provide ONLY the JSON object and no other text or explanation.

```json
{
    "question_type": "logic" | "calculation",
    "predicate_focus": "exemption" | "tax" | "standard_deduction" | "filing_status" | "dependency" | "employer" | "other",
    "ground_truth": "true" | "false" | number,
    "reasoning": "Brief explanation of your classification and how the ground truth was determined."
}
```

**CLASSIFICATION RULES:**

1. **"question_type":**
   - **"logic"**: For questions that test whether a statement is true or false. These typically contain "Entailment" or "Contradiction".
   - **"calculation"**: For questions that ask for a specific numerical value. These typically contain "How much tax..." or "What is the amount...".

2. **"predicate_focus":**
   - **"exemption"**: Questions about personal exemptions, section 151.
   - **"tax"**: Questions about final tax liability.
   - **"standard_deduction"**: Questions about standard deduction amounts.
   - **"dependency"**: Questions about dependents, qualifying children/relatives, section 152.
   - **"employer"**: Questions about employer status, FUTA, section 3306.
   - **"other"**: If none of the above categories fit.

3. **"ground_truth":**
   This is the most critical field. You must extract the correct, final answer from the question text.
   - For **"calculation"** questions, extract the final numerical value (e.g., for "...pay in 2017? $8710", the ground truth is 8710).
   - For **"logic"** questions, determine the expected boolean outcome:
     - If the question ends in "Entailment", the ground truth is true.
     - If the question ends in "Contradiction", the ground truth is false.

**EXAMPLES:**

**Example 1 (Logic - Contradiction):**
Question: "Alice's exemption amount under section 151(d)(1) is equal to $0. Contradiction"
Analysis:
```json
{
    "question_type": "logic",
    "predicate_focus": "exemption",
    "ground_truth": false,
    "reasoning": "The question asserts a statement and claims it's a 'Contradiction', so the expected final outcome of the test is false."
}
```

**Example 2 (Logic - Entailment):**
Question: "Section 3306(c)(5) applies to Alice employing Bob for the year 2017. Entailment"
Analysis:
```json
{
    "question_type": "logic",
    "predicate_focus": "employer",
    "ground_truth": true,
    "reasoning": "The question asserts a statement and claims it's an 'Entailment', so the expected final outcome of the test is true."
}
```

**Example 3 (Calculation):**
Question: "How much tax does Bob have to pay in 2017? $8710"
Analysis:
```json
{
    "question_type": "calculation",
    "predicate_focus": "tax",
    "ground_truth": 8710,
    "reasoning": "The question asks for a specific numerical calculation and provides the ground truth value at the end."
}
```

Provide ONLY the JSON analysis for the given question."""

    def generate_query_generation_prompt(self, mode: str = "full") -> str:
        """
        Gets the appropriate query generation prompt for the Method 2 codebase.
        This prompt instructs the LLM to generate a value-producing answer/2 predicate.
        The "fast" mode is a condensed version for quicker generation.
        """
        if mode == "fast":
            return """Convert the question to a value-producing answer/2 predicate for our Method 2 codebase.

FACTS: {facts}
QUESTION: {question}
CASE_ID: {case_id}

**Rules:**
1. The 'Result' variable must be unified with the final calculated value (a number or a boolean).
2. For tax questions, use get_taxable_income + statute_1:s1_calculate_tax_from_ti.
3. For logic questions, unify 'Result' with the boolean output of the relevant statute predicate.
4. The predicate must be a complete, valid Prolog clause with a non-empty body.

Generate ONLY the single, complete answer({case_id}, Result) :- ... . clause."""

        # This is the full, detailed prompt - use the structured format
        return self._generate_full_query_prompt()

# Global instance for backward compatibility
_prompt_generator = None

def get_dynamic_prompt_generator() -> DynamicPromptGenerator:
    """Get the global dynamic prompt generator instance for Stage 4"""
    global _prompt_generator
    if _prompt_generator is None:
        current_dir = os.path.dirname(os.path.abspath(__file__))
        codebase_dir = os.path.join(current_dir, "../prolog_codebase")
        _prompt_generator = DynamicPromptGenerator(codebase_dir)
    return _prompt_generator

def get_fact_extraction_prompt(mode: str = "full") -> str:
    """Get fact extraction prompt using actual predicates"""
    return get_dynamic_prompt_generator().generate_fact_extraction_prompt(mode)

def get_query_generation_prompt(mode: str = "full") -> str:
    """
    Gets the appropriate query generation prompt for the Method 2 codebase.
    This prompt instructs the LLM to generate a value-producing answer/2 predicate.
    The "fast" mode is a condensed version for quicker generation.
    """
    return get_dynamic_prompt_generator().generate_query_generation_prompt(mode)

if __name__ == "__main__":
    # Test the dynamic prompt generator
    logging.basicConfig(level=logging.INFO)
    
    current_dir = os.path.dirname(os.path.abspath(__file__))
    codebase_dir = os.path.join(current_dir, "../prolog_codebase")
    
    generator = DynamicPromptGenerator(codebase_dir)
    
    print("=== FACT EXTRACTION PROMPT ===")
    print(generator.generate_fact_extraction_prompt()[:500] + "...")
    
    print("\n=== QUERY GENERATION PROMPT ===")
    print(generator.generate_query_generation_prompt()[:500] + "...")