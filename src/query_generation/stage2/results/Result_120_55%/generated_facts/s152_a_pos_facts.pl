% Stage 2 Generated Facts
% Case: s152_a_pos
% Text: Alice has a son, Bob, who satisfies section 152(c)(1) for the year 2015.
% Question: Under section 152(a), Bob is a dependent of Alice for the year 2015. Entailment

:- discontiguous s152_a/3.
:- ['statutes/prolog/init'].
son_(span("son",12,14)).
patient_(span("son",12,14),span("Alice",0,4)).
agent_(span("son",12,14),span("Bob",17,19)).
s152_a("Bob","Alice",2015).
