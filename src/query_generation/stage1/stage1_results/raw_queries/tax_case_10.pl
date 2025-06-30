```prolog
case_query(Result) :-
    s152_a(Taxpayer, Year, _),
    Taxpayer = span("Alice", 0, 4),
    Year = 2017,
    Result = true.
```