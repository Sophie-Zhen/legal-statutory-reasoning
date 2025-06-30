case_query(Result) :-
  marriage_(E),
  agent_(E, Agent1),
  agent_(E, Agent2),
  Agent1 \= Agent2,
  start_(E, Date),
  year_from_date(Date, Year),
  Year =:= 2017,
  Result = true.