% Stage 2 Generated Facts
% Case: s152_d_1_D_pos
% Text: In 2015, Alice's income was $312. The exemption amount for Alice under section 151(d) for the year 2015 was $2000. Bob is Alice's father.
% Question: Section 152(d)(1)(D) applies to Bob for the year 2015. Entailment

:- discontiguous s151_c/4.
:- ['statutes/prolog/init'].
income_(span("income",18,23)).
agent_(span("income",18,23),span("Alice",10,14)).
amount_(span("income",18,23),span(312,29,31)).
start_(span("income",18,23),span(2015,3,6)).
s151_c("Bob","Alice",2000,2015).
father_(span("father",129,134)).
agent_(span("father",129,134),span("Bob",118,120)).
patient_(span("father",129,134),span("Alice",125,129)).
