case_query(Result) :-
    s7703("Alice",_,_,Year),
    s63("Alice",Year,Amount),
    Amount > 500000,
    Result = true.
case_query(false).