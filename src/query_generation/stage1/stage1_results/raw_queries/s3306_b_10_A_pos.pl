```prolog
case_query(Result):-
    s3306_b_10_(_,_,_,Agent,_,_),
    Agent == "Alice",
    Result = true.
case_query(Result):-
    \+ s3306_b_10_(_,_,_,Agent,_,_),
    Agent == "Alice",
    Result = false.
```