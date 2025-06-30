case_query(Result) :-
    s151("Alice",_,_,_,2017),
    s63_c_1("Alice",2017,Threshold),
    s63_b("Alice",2017,Amount,_),
    Amount > Threshold,
    Result = true.
case_query(false).