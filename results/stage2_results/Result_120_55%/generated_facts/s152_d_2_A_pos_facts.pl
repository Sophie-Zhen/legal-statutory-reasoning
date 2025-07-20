% Stage 2 Generated Facts
% Case: s152_d_2_A_pos
% Text: Bob is Alice's father since April 15th, 2014.
% Question: Alice bears a relationship to Bob under section 152(d)(2)(A). Entailment

:- ['statutes/prolog/init'].
father_(span("father",15,20)).
agent_(span("father",15,20),span("Bob",0,2)).
patient_(span("father",15,20),span("Alice",7,11)).
start_(span("father",15,20),span(20140415,28,45)).
