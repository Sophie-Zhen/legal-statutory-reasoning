```prolog
case_query(Result) :-
    s152_c_1(_, _, _, 2017, TaxCredit),
    TaxCredit > 0,
    Result = true ;
    Result = false.
```