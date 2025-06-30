case_query(Result) :-
  payment_(P),
  agent_(P, Agent),
  amount_(P, Amount),
  Amount > 30000,
  Result = true.