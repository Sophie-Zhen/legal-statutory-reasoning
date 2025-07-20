% Stage 2 Generated Facts
% Case: s152_b_1_pos
% Text: Alice has a son, Bob, who satisfies section 152(c)(1) for the year 2015. Bob has a son, Charlie, who satisfies section 152(c)(1) for the year 2015. Alice's income in 2015 was $504598. Bob had no income in 2015.
% Question: Section 152(b)(1) applies to Bob for the year 2015. Entailment

:- discontiguous s152_a/3.
:- discontiguous income_/1.
:- ['statutes/prolog/init'].
s152_a("Bob","Alice",2015).
s152_a("Charlie","Bob",2015).
son_(span("son",12,14)).
patient_(span("son",12,14),span("Alice",0,4)).
agent_(span("son",12,14),span("Bob",17,19)).
start_(span("son",12,14),span(2015,57,60)).
son_(span("son",75,77)).
patient_(span("son",75,77),span("Bob",65,67)).
agent_(span("son",75,77),span("Charlie",80,86)).
start_(span("son",75,77),span(2015,121,124)).
income_(span("income",135,140)).
agent_(span("income",135,140),span("Alice",127,131)).
amount_(span("income",135,140),span(504598,153,159)).
start_(span("income",135,140),span(2015,144,147)).
income_(span("income",176,181)).
agent_(span("income",176,181),span("Bob",165,167)).
amount_(span("income",176,181),span(0,173,174)).
start_(span("income",176,181),span(2015,185,188)).
