% §1. Tax imposed

% (a) Married individuals filing joint returns and surviving spouses

% (1) every married individual (as defined in section 7703) who makes a single return jointly with his spouse
s1_a_1(Event, TaxableIncome, Tax) :-
    agent_(Event, Person),
    married_individual_(Person),
    filed_joint_return(Event, Person),
    tax_s1_a_1(TaxableIncome, Tax).

% (2) every surviving spouse (as defined in section 2(a))
s1_a_2(Event, TaxableIncome, Tax) :-
    agent_(Event, Person),
    surviving_spouse_(Person),
    tax_s1_a_1(TaxableIncome, Tax).

% Tax calculation for married individuals filing jointly and surviving spouses
tax_s1_a_1(TaxableIncome, Tax) :-
    TaxableIncome =< 36900,
    Tax is 0.15 * TaxableIncome.
tax_s1_a_1(TaxableIncome, Tax) :-
    TaxableIncome > 36900,
    TaxableIncome =< 89150,
    Tax is 5535 + 0.28 * (TaxableIncome - 36900).
tax_s1_a_1(TaxableIncome, Tax) :-
    TaxableIncome > 89150,
    TaxableIncome =< 140000,
    Tax is 20165 + 0.31 * (TaxableIncome - 89150).
tax_s1_a_1(TaxableIncome, Tax) :-
    TaxableIncome > 140000,
    TaxableIncome =< 250000,
    Tax is 35928.50 + 0.36 * (TaxableIncome - 140000).
tax_s1_a_1(TaxableIncome, Tax) :-
    TaxableIncome > 250000,
    Tax is 75528.50 + 0.396 * (TaxableIncome - 250000).

% (b) Heads of households

% every head of a household (as defined in section 2(b))
s1_b(Event, TaxableIncome, Tax) :-
    agent_(Event, Person),
    head_of_household_(Person),
    tax_s1_b(TaxableIncome, Tax).

% Tax calculation for heads of households
tax_s1_b(TaxableIncome, Tax) :-
    TaxableIncome =< 29600,
    Tax is 0.15 * TaxableIncome.
tax_s1_b(TaxableIncome, Tax) :-
    TaxableIncome > 29600,
    TaxableIncome =< 76400,
    Tax is 4440 + 0.28 * (TaxableIncome - 29600).
tax_s1_b(TaxableIncome, Tax) :-
    TaxableIncome > 76400,
    TaxableIncome =< 127500,
    Tax is 17544 + 0.31 * (TaxableIncome - 76400).
tax_s1_b(TaxableIncome, Tax) :-
    TaxableIncome > 127500,
    TaxableIncome =< 250000,
    Tax is 33385 + 0.36 * (TaxableIncome - 127500).
tax_s1_b(TaxableIncome, Tax) :-
    TaxableIncome > 250000,
    Tax is 77485 + 0.396 * (TaxableIncome - 250000).

% (c) Unmarried individuals (other than surviving spouses and heads of households)

% every individual (other than a surviving spouse or the head of a household) who is not a married individual
s1_c(Event, TaxableIncome, Tax) :-
    agent_(Event, Person),
    \+ surviving_spouse_(Person),
    \+ head_of_household_(Person),
    \+ married_individual_(Person),
    tax_s1_c(TaxableIncome, Tax).

% Tax calculation for unmarried individuals
tax_s1_c(TaxableIncome, Tax) :-
    TaxableIncome =< 22100,
    Tax is 0.15 * TaxableIncome.
tax_s1_c(TaxableIncome, Tax) :-
    TaxableIncome > 22100,
    TaxableIncome =< 53500,
    Tax is 3315 + 0.28 * (TaxableIncome - 22100).
tax_s1_c(TaxableIncome, Tax) :-
    TaxableIncome > 53500,
    TaxableIncome =< 115000,
    Tax is 12107 + 0.31 * (TaxableIncome - 53500).
tax_s1_c(TaxableIncome, Tax) :-
    TaxableIncome > 115000,
    TaxableIncome =< 250000,
    Tax is 31172 + 0.36 * (TaxableIncome - 115000).
tax_s1_c(TaxableIncome, Tax) :-
    TaxableIncome > 250000,
    Tax is 79772 + 0.396 * (TaxableIncome - 250000).

% (d) Married individuals filing separate returns

% every married individual who does not make a single return jointly with his spouse
s1_d(Event, TaxableIncome, Tax) :-
    agent_(Event, Person),
    married_individual_(Person),
    \+ filed_joint_return(Event, Person),
    tax_s1_d(TaxableIncome, Tax).

% Tax calculation for married individuals filing separately
tax_s1_d(TaxableIncome, Tax) :-
    TaxableIncome =< 18450,
    Tax is 0.15 * TaxableIncome.
tax_s1_d(TaxableIncome, Tax) :-
    TaxableIncome > 18450,
    TaxableIncome =< 44575,
    Tax is 2767.50 + 0.28 * (TaxableIncome - 18450).
tax_s1_d(TaxableIncome, Tax) :-
    TaxableIncome > 44575,
    TaxableIncome =< 70000,
    Tax is 10082.50 + 0.31 * (TaxableIncome - 44575).
tax_s1_d(TaxableIncome, Tax) :-
    TaxableIncome > 70000,
    TaxableIncome =< 125000,
    Tax is 17964.25 + 0.36 * (TaxableIncome - 70000).
tax_s1_d(TaxableIncome, Tax) :-
    TaxableIncome > 125000,
    Tax is 37764.25 + 0.396 * (TaxableIncome - 125000).