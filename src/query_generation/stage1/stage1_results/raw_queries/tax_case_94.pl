case_query(Result) :-
  payment_(P1),
  agent_(P1, A),
  A = span("Alice", _, _),
  patient_(P1, Pt),
  plan_(Pt),
  amount_(P1, Amt),
  number(Amt),
  Amt > 5000,
  Result = true.