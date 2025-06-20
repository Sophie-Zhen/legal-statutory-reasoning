% tax.pl

%% Scenario facts
status(alice, married_filing_jointly).
taxable_income(alice, 17330).

%% §1(a)(i) brackets for married filing jointly
bracket(married_filing_jointly,  0,     36900,   0,        0.15).
bracket(married_filing_jointly,  36900, 89150,   5535,     0.28).
bracket(married_filing_jointly,  89150, 140000,  20165,    0.31).
bracket(married_filing_jointly, 140000, 250000,  35928.5,  0.36).
bracket(married_filing_jointly, 250000, inf,     75528.5,  0.396).

%% Tax computation
tax_due(Person, Tax) :-
    status(Person, FS),
    taxable_income(Person, Inc),
    bracket(FS, Low, High, Base, Rate),
    Inc > Low,
    Inc =< High,
    TaxFloat is Base + (Inc - Low) * Rate,
    Tax is round(TaxFloat).

%% Entailment vs. Contradiction
decide(Person, Claimed, entailment) :-
    tax_due(Person, Computed),
    Computed =:= Claimed.

decide(Person, Claimed, contradiction) :-
    \+ decide(Person, Claimed, entailment).

run_check(Claimed) :-
    decide(alice, Claimed, entailment)
  -> format('Entailment: the claim of $~w is CORRECT~n', [Claimed])
  ;  format('Contradiction: the claim of $~w is INCORRECT~n', [Claimed]).