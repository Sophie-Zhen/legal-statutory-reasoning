case_query(Result) :-
    is_child_of(span("Charlie",72,78),span("Alice",44,48),span("Bob",54,56),span(20001009,86,102)),
    Result = true.