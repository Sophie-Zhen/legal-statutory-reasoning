```prolog
case_query(Result) :-
    tax("Alice", 2017, Tax),
    Tax =:= 2684,
    Result = true.
```