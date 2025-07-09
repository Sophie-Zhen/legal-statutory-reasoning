"""
Stage 2 Prompts - Teaching LLM the exact SARA dataset format
No hardcoding - LLM generates everything based on examples
"""

FACT_EXTRACTION_PROMPT_FULL = """You are a legal fact extractor for the SARA dataset. Convert natural language into Prolog facts.

TEXT TO ANALYZE: {text}

SARA DATASET FORMAT RULES:
1. Every event/action becomes a predicate with span: payment(span("paid",10,13)).
2. Properties are separate facts: agent_, patient_, amount_, start_, end_
3. Names in spans MUST have quotes: span("Alice",0,5)
4. Numbers/dates have NO quotes: span(39212,16,20) or span(20170203,25,33)
5. Find the EXACT character position in the text (count from 0)

EXAMPLES FROM ACTUAL SARA CASES:

Example 1 - Payment (from tax_case_31):
Text: "In 2017, Alice was paid $39212"
Facts:
payment(span("paid",19,22)).
start(span("paid",19,22),span(20170101,3,6)).
patient(span("paid",19,22),span("Alice",9,13)).
amount(span("paid",19,22),span(39212,25,29)).

Example 2 - Income (from tax_case_34):
Text: "Alice's gross income for the year 2017 is $22895"
Facts:
income(span("income",14,19)).
agent(span("income",14,19),span("Alice",0,4)).
start(span("income",14,19),span(20170101,34,37)).
amount(span("income",14,19),span(22895,43,47)).

Example 3 - Marriage (from tax_case_31):
Text: "Alice and Bob have been married since Feb 3rd, 2017"
Facts:
marriage(span("married",24,30)).
agent(span("married",24,30),span("Alice",0,4)).
agent(span("married",24,30),span("Bob",10,12)).
start(span("married",24,30),span(20170203,38,49)).

Example 4 - Service with University (from s3306_c_10_A_i_neg):
Text: "Alice was paid $3200 in 2017 for services performed for Johns Hopkins University"
Facts:
payment(span("paid",10,13)).
service(span("services",33,40)).
educationalinstitution(span("University",70,79)).
agent(span("paid",10,13),span("Johns Hopkins University",56,79)).
patient(span("paid",10,13),span("Alice",0,4)).
amount(span("paid",10,13),span(3200,16,19)).
start(span("paid",10,13),span(20170101,24,27)).
purpose(span("paid",10,13),span("services",33,40)).
agent(span("services",33,40),span("Alice",0,4)).
patient(span("services",33,40),span("Johns Hopkins University",56,79)).

Example 5 - Enrollment:
Text: "Alice was enrolled at Johns Hopkins University and attending classes"
Facts:
enrollment_(span("enrolled",10,17)).
agent(span("enrolled",10,17),span("Alice",0,4)).
patient(span("enrolled",10,17),span("Johns Hopkins University",22,45)).
attendingclasses(span("attending",51,59)).
agent(span("attending",51,59),span("Alice",0,4)).
location(span("attending",51,59),span("Johns Hopkins University",22,45)).

CRITICAL:
- Count character positions starting from 0
- Use EXACT predicates from examples (payment, income, marriage, service, etc.)
- NO predicates like: filing_status_, takes_standard_deduction_, deduction_
- Each main event needs multiple supporting facts

Generate ONLY Prolog facts in SARA format:"""

FACT_EXTRACTION_PROMPT_FAST = """Convert text to SARA format Prolog facts.

TEXT: {text}

Key rules:
- Events: payment(span("paid",X,Y)).
- Properties: agent_, patient_, amount_, start_
- Names quoted: span("Alice",X,Y)
- Numbers unquoted: span(12345,X,Y)

Generate facts:"""

EMERGENCY_EXTRACTION_PROMPT = """Extract basic SARA format facts.

TEXT: {text}

Extract payment/income/marriage facts with correct spans:"""

def get_fact_extraction_prompt(mode="full"):
    """Get the appropriate fact extraction prompt"""
    if mode == "fast":
        return FACT_EXTRACTION_PROMPT_FAST
    elif mode == "emergency":
        return EMERGENCY_EXTRACTION_PROMPT
    return FACT_EXTRACTION_PROMPT_FULL

def get_query_generation_prompt(mode="full"):
    """Get query generation prompt from Stage 1"""
    return """Convert this question to a Prolog query using the given facts.

Question: {question}

Available facts:
{facts}

Examples:
- "How much tax does Alice have to pay in 2017?" → tax("Alice",2017,Amount)
- "Section 63(c)(2) applies to Alice in 2017" → s63_c_2("Alice",2017,_)

Generate ONLY the Prolog query:"""