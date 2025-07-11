case_query(Result) :-
    s2_a(Taxpayer, _, TaxYear),
    s63(Taxpayer, TaxYear, TaxableIncome),
    TaxableIncome > 600000,
    Result = true.