case_query(Result) :-
  payment_(P),
  agent_(P, A),
  string_chars(A, CharsA),
  append("United States Government", _, CharsA),
  Result = true.