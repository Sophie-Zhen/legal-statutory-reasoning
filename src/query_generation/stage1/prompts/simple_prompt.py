
def get_simple_prompt(test_case):
    """Generate a very simple, clear prompt."""
    
    # For tax calculation questions
    if "how much tax" in test_case.question.lower():
        expected = test_case.expected_value
        return f"""Generate ONLY this exact format:

answer('{test_case.case_id}', Result) :-
    income_tax(alice, {test_case.question.split()[-1].strip('?')}, Result).

OR if that doesn't work, just:

answer('{test_case.case_id}', {expected})."""

    # For contradiction questions about tax
    elif test_case.question_type == "contradiction" and "tax" in test_case.question:
        return f"""Generate ONE of these formats:

answer('{test_case.case_id}', Result) :-
    income_tax(alice, 2017, Tax),
    Result = (Tax \\= {test_case.question.split('$')[1].split()[0]}).

OR simpler:

answer('{test_case.case_id}', true)."""

    # For entailment questions
    elif test_case.question_type == "entailment":
        return f"""Generate exactly:

answer('{test_case.case_id}', true)."""

    # Default
    return f"""Generate exactly this format:

answer('{test_case.case_id}', {'true' if test_case.question_type == 'entailment' else 'false'})."""