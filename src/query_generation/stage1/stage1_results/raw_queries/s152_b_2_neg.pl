case_query(Result) :-
    marriage_(Marriage),
    agent_(Marriage,Agent1),
    agent_(Marriage,Agent2),
    Agent1 = span("Alice",_,_),
    Agent2 = span("Bob",_,_),
    start_(Marriage,Date),
    Date = span(20150101,_,_),
    Result = true.