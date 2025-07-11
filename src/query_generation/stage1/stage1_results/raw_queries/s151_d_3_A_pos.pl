case_query(Result):-
    s151_c_applies("Alice",2015),
    Result=true.
case_query(Result):-
    \+ s151_c_applies("Alice",2015),
    Result=false.