case_query(Result) :-
    is_child_of(span("Bob",112,114), span("Alice",95,99), _, _),
    Result = true.