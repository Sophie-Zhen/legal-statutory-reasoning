case_query(Result) :-
    s151_c_applies("Bob", "Charlie", Year),
    Year >= 2015,
    Year =< 2019,
    Result = true.