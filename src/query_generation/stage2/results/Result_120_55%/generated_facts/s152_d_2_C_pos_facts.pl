% Stage 2 Generated Facts
% Case: s152_d_2_C_pos
% Text: Bob is Alice's son since April 15th, 2014.
% Question: Alice bears a relationship to Bob under section 152(d)(2)(C). Entailment

:- ['statutes/prolog/init'].
son_(span("son",16,18)).
agent_(span("son",16,18),span("Bob",0,2)).
patient_(span("son",16,18),span("Alice",7,11)).
start_(span("son",16,18),span(20140415,26,43)).
