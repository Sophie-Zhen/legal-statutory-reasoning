```prolog
case_query(Result) :-
    bagof(Year, (
        death_(Death),
        agent_(Death, Agent),
        Agent = span(_, _, "Bob"),
        start_(Death, Date),
        Date = span(DateAtom, _, _),
        atom_number(DateAtom, DateNum),
        DateNum // 10000 = Year
    ), Years),
    (Years = [] -> Result = false ; member(2014, Years), Result = true).
```