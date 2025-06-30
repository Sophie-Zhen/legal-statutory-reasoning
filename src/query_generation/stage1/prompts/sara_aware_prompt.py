
def generate_sara_query_prompt(test_case):
    """Generate a prompt that understands SARA's structure."""
    
    # Analyze the case structure
    has_simple_facts = any('s7703(' in f or 's63(' in f for f in test_case.facts)
    has_span_facts = any('span(' in f for f in test_case.facts)
    
    examples = []
    
    # Add relevant examples based on question type
    if "section 1(d)(iv)" in test_case.question.lower():
        examples.append("""
For "Alice has to pay $5683 in taxes for the year 2017 under section 1(d)(iv). Contradiction":
answer('s1_d_iv_neg', Result) :-
    s1_d_iv(TaxableIncome, Tax),
    Result = (Tax \\= 5683).
""")
    
    elif "section 3306(c)" in test_case.question.lower():
        examples.append("""
For "Section 3306(c)(5) applies to Alice employing Bob for the year 2017. Entailment":
answer('s3306_c_5_pos', Result) :-
    (s3306_c_5(alice, bob, _, _, 2017) -> Result = true ; Result = false).
""")
    
    elif "how much tax" in test_case.question.lower():
        examples.append("""
For "How much tax does Alice have to pay in 2018? $0":
answer('tax_case_89', Result) :-
    income_tax(alice, 2018, Result).
""")
    
    prompt = f"""Generate ONLY the answer/2 predicate for this SARA test case.

Case: {test_case.case_id}
Question: {test_case.question}
Type: {test_case.question_type}

Available facts in case file:
{chr(10).join(test_case.facts[:5])}

Key points:
1. The case file already contains all necessary facts
2. Use predicates from the statutes (s1_X, s3306_X, income_tax, etc.)
3. For contradiction: Result = true if the statement is FALSE
4. For entailment: Result = true if the statement is TRUE

Examples:
{chr(10).join(examples)}

Generate ONLY the answer predicate in correct Prolog syntax:
"""
    
    return prompt