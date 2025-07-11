case_query(Result) :-
    s2_b(P,_,Y),
    payment_(Pay),
    patient_(Pay,P),
    amount_(Pay,A),
    A =:= 33200,
    Y =:= 2017,
    Result = true.