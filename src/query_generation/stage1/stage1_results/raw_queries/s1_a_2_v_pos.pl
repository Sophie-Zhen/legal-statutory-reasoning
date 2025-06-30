case_query(Result) :-
    s2_a(Taxpayer, _, TaxYear),
    s63(Taxpayer, TaxYear, TI),
    TI > 500000,
    Result = true.