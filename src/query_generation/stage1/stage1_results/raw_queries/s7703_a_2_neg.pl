case_query(Result) :-
    patient_(Sep, Mar),
    agent_(Sep, Decree),
    start_(Sep, SepDate),
    agent_(Mar, Alice),
    agent_(Mar, Bob),
    start_(Mar, MarDate),
    string_chars("Alice", AliceChars),
    string_chars("Bob", BobChars),
    string_chars("decree of divorce", DecreeChars),
    string_chars("separated", SepChars),
    string_chars("married", MarChars),
    Result = true.