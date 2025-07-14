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
    """Generates prompts dynamically based on actual Method 2 codebase"""
    
    def __init__(self, codebase_dir: str):
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

**EXAMPLES BASED ON ACTUAL PREDICATES:**

**Example 1 (Section 151 exemption):**
Text: "Alice is entitled to an exemption under section 151(b) for the year 2015."
Facts:
fact(s151_example, personal_exemption_deduction(alice, s151_example, 2015, Amount)).

**Example 2 (Tax calculation):**
Text: "Bob had taxable income of $50000 in 2019 and filed as single."
Facts:
fact(tax_example, tax_imposed(bob, tax_example, 2019, Tax)).

**Example 3 (Standard deduction):**
Text: "Carol took the standard deduction in 2018."
Facts:
fact(std_example, standard_deduction(carol, std_example, 2018, Amount)).

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

    def generate_query_generation_prompt(self, mode: str = "full") -> str:
        """Generate query generation prompt with actual predicates"""
        if mode == "fast":
            return self._generate_fast_query_prompt()
        else:
            return self._generate_full_query_prompt()
    
    def _generate_full_query_prompt(self) -> str:
        """Generate comprehensive query generation prompt with Step 0 question classification"""
        predicate_vocab = self.analyzer.generate_prompt_vocabulary()
        examples = self.analyzer.generate_examples()
        
        return f"""You are a Prolog test case generator. Your task is to convert a natural language question into the final `answer(CaseID, Result)` predicate for our test suite.

**CASE FACTS (already generated):**
{{facts}}

**QUESTION TO CONVERT:**
{{question}}

**METHOD 2 CODEBASE CONTEXT:**
Here is our actual system codebase with available predicates and their usage:

{{codebase}}

**AVAILABLE PREDICATES:**
Our system has these ACTUAL predicates (extracted from the codebase):

{predicate_vocab}

**STEP 0: QUESTION CLASSIFICATION (MANDATORY FIRST STEP)**

Before generating any query, you MUST first analyze and classify the question type:

**Question Types:**
- **CALCULATION**: Questions asking "how much", "what is the amount", "calculate", seeking a computed numerical result
- **LOGIC**: Questions testing truth/falsehood of statements, containing "entailment", "contradiction", "applies", "is true/false"

**Classification Rules:**
1. If the question asks for a specific amount or calculation → CALCULATION
2. If the question tests whether a statement is true/false → LOGIC
3. Look for keywords:
   - CALCULATION: "how much", "amount", "calculate", "what is"
   - LOGIC: "entailment", "contradiction", "applies", "true", "false"

**STEP 1: QUERY GENERATION BASED ON CLASSIFICATION**

After classification, generate the appropriate query structure:

**For CALCULATION Questions:**
- Use predicates that return numerical values
- Structure: `answer({{case_id}}, Result) :- section_module:predicate(..., Result).`

**For LOGIC Questions:**
- Use predicates that test conditions and return true/false
- Structure: `answer({{case_id}}, Result) :- condition_check, (condition -> Result = true ; Result = false).`
- For contradiction testing: `(ActualValue =:= ClaimedValue -> Result = false ; Result = true)`
- For entailment testing: `(condition_holds -> Result = true ; Result = false)`

**QUERY GENERATION RULES:**
1. The predicate must be `answer({{case_id}}, Result).`
2. Use ONLY the predicates listed in the AVAILABLE PREDICATES section
3. Pay attention to arity (number of arguments) for each predicate
4. Use proper module prefixes (e.g., `section151:`, `knowledge_base:`, `helpers:`)
5. Match query structure to the question type identified in Step 0

**EXAMPLES BASED ON ACTUAL PREDICATES:**
{examples}

**REQUIRED OUTPUT FORMAT:**

You MUST provide your response in exactly this format:

```
Question Type: [CALCULATION or LOGIC]
Reasoning: [Brief explanation of why you classified it this way]
Query: answer({{case_id}}, Result) :- [your complete Prolog clause body].
```

**CRITICAL SYNTAX REQUIREMENTS:**

Your single most important task is to generate a **complete and syntactically valid Prolog clause**.

**CORRECT FORMAT (WHAT YOU MUST GENERATE):**
A complete rule with a head and a non-empty body, terminated by a period.
Example: `answer({{case_id}}, Result) :- knowledge_base:exemption_amount(2015, Result).` ✅

**INCORRECT FORMATS (WHAT YOU MUST AVOID):**
- `answer({{case_id}}, Result) :-.` ❌ (Empty body - syntax error)
- `answer({{case_id}}, Result).` ❌ (Fact, not a rule)
- `answer({{case_id}}, Result) :- nonexistent_predicate(...)` ❌ (Using predicates not in our codebase)

**CRITICAL:**
- The case ID must be `{{case_id}}`
- Use ONLY predicates from the AVAILABLE PREDICATES section above
- Always include proper module prefixes
- The clause MUST have a non-empty body after the ':-' symbol
- ALWAYS follow the required output format with Question Type, Reasoning, and Query

Generate your response following the REQUIRED OUTPUT FORMAT above."""

    def _generate_fast_query_prompt(self) -> str:
        """Generate fast query generation prompt with question classification"""
        return """Convert question to answer/2 predicate using ACTUAL Method 2 predicates.

FACTS: {facts}
QUESTION: {question}
CASE_ID: {case_id}

**STEP 0: CLASSIFY QUESTION TYPE**
- CALCULATION: "how much", "amount", "calculate" → seeks numerical result
- LOGIC: "entailment", "contradiction", "true/false" → tests statement truth

**STEP 1: GENERATE QUERY BASED ON TYPE**

Use actual predicates:
- knowledge_base:exemption_amount/2 - for exemption amounts
- section151:personal_exemption_deduction/4 - for exemption calculations
- section1:tax_imposed/4 - for tax calculations
- section63:standard_deduction/4 - for standard deductions
- helpers:calculate_tax_from_brackets/3 - for tax bracket calculations

**REQUIRED OUTPUT FORMAT:**
```
Question Type: [CALCULATION or LOGIC]
Reasoning: [Brief explanation]
Query: answer({case_id}, Result) :- [complete Prolog clause body].
```

CRITICAL: Generate a complete Prolog rule with a non-empty body after ':-'.
NEVER generate incomplete rules like 'answer({case_id}, Result) :-.'
Follow the REQUIRED OUTPUT FORMAT exactly."""

    def generate_question_analysis_prompt(self) -> str:
        """Generate prompt for LLM-based question analysis and classification"""
        return """You are a legal question analyzer. Your task is to analyze a natural language question and classify it for our Prolog-based legal reasoning system.

**QUESTION TO ANALYZE:**
{question}

**ANALYSIS TASK:**
Analyze the question and provide a structured classification in the following JSON format:

```json
{
    "question_type": "entailment_contradiction" | "computation",
    "predicate_focus": "exemption" | "tax" | "standard_deduction" | "filing_status" | "dependency" | "employer" | "other",
    "claimed_value": number | null,
    "comparison_type": "entailment" | "contradiction" | "unknown",
    "reasoning": "Brief explanation of your classification"
}
```

**CLASSIFICATION RULES:**

**Question Type:**
- **"entailment_contradiction"**: Questions that test whether a statement is true/false, typically containing words like "entailment", "contradiction", "applies", or making claims about specific values
- **"computation"**: Questions asking for calculated values, typically containing "how much", "what is", "calculate", "amount"

**Predicate Focus:**
- **"exemption"**: Questions about personal exemptions, exemption amounts, section 151
- **"tax"**: Questions about tax liability, tax imposed, tax owed
- **"standard_deduction"**: Questions about standard deduction amounts
- **"filing_status"**: Questions about filing status determination
- **"dependency"**: Questions about dependent relationships, qualifying children/relatives
- **"employer"**: Questions about employer status, FUTA, employment relationships
- **"other"**: If none of the above categories fit

**Claimed Value:**
- Extract any specific numerical value being claimed or tested (e.g., "$0", "2000", "$50,000")
- Set to null if no specific value is mentioned

**Comparison Type:**
- **"entailment"**: If the question asks whether something follows/is true
- **"contradiction"**: If the question asks whether something is false/contradicted
- **"unknown"**: If unclear or not applicable

**EXAMPLES:**

**Example 1:**
Question: "Alice's exemption amount under section 151(d)(1) is equal to $0. Contradiction"
Analysis:
```json
{
    "question_type": "entailment_contradiction",
    "predicate_focus": "exemption",
    "claimed_value": 0,
    "comparison_type": "contradiction",
    "reasoning": "Tests whether the claim that exemption amount equals $0 is a contradiction"
}
```

**Example 2:**
Question: "How much tax does Alice have to pay in 2018?"
Analysis:
```json
{
    "question_type": "computation",
    "predicate_focus": "tax",
    "claimed_value": null,
    "comparison_type": "unknown",
    "reasoning": "Asks for calculation of tax amount, no specific claim to test"
}
```

**Example 3:**
Question: "Alice is an employer under section 3306(a)(1) for the year 2018. Entailment"
Analysis:
```json
{
    "question_type": "entailment_contradiction",
    "predicate_focus": "employer",
    "claimed_value": null,
    "comparison_type": "entailment",
    "reasoning": "Tests whether Alice being an employer is an entailment (follows from the facts)"
}
```

Provide ONLY the JSON analysis for the given question."""

    def get_fact_extraction_prompt(self, mode: str = "full") -> str:
        """Get fact extraction prompt (compatible with existing interface)"""
        return self.generate_fact_extraction_prompt(mode)
    
    def get_query_generation_prompt(self, mode: str = "full") -> str:
        """Get query generation prompt (compatible with existing interface)"""
        return self.generate_query_generation_prompt(mode)

    def get_question_analysis_prompt(self) -> str:
        """Get question analysis prompt (compatible with existing interface)"""
        return self.generate_question_analysis_prompt()

# Global instance for backward compatibility
_prompt_generator = None

def get_dynamic_prompt_generator() -> DynamicPromptGenerator:
    """Get the global dynamic prompt generator instance"""
    global _prompt_generator
    if _prompt_generator is None:
        current_dir = os.path.dirname(os.path.abspath(__file__))
        codebase_dir = os.path.join(os.path.dirname(current_dir), "prolog_codebase")
        _prompt_generator = DynamicPromptGenerator(codebase_dir)
    return _prompt_generator

def get_fact_extraction_prompt(mode: str = "full") -> str:
    """Get fact extraction prompt using actual predicates"""
    return get_dynamic_prompt_generator().get_fact_extraction_prompt(mode)

def get_query_generation_prompt(mode: str = "full") -> str:
    """Get query generation prompt using actual predicates"""
    return get_dynamic_prompt_generator().get_query_generation_prompt(mode)

if __name__ == "__main__":
    # Test the dynamic prompt generator
    logging.basicConfig(level=logging.INFO)
    
    current_dir = os.path.dirname(os.path.abspath(__file__))
    codebase_dir = os.path.join(os.path.dirname(current_dir), "prolog_codebase")
    
    generator = DynamicPromptGenerator(codebase_dir)
    
    print("=== FACT EXTRACTION PROMPT ===")
    print(generator.generate_fact_extraction_prompt()[:500] + "...")
    
    print("\n=== QUERY GENERATION PROMPT ===")
    print(generator.generate_query_generation_prompt()[:500] + "...") 