case_query(Result) :-
    marriage_(M),
    agent_(M,Alice),
    agent_(M,Bob),
    death_(D),
    agent_(D,Alice),
    start_(M,StartM),
    start_(D,StartD),
    is_before(StartM,StartD),
    Result = true.