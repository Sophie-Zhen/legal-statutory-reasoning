% Stage 2 Generated Facts
% Case: s68_b_1_C_pos
% Text: In 2016, Alice's income was $567192. Alice is not married, is not a surviving spouse, and is not a head of household in 2016.
% Question: Section 68(b)(1)(C) applies to Alice in 2016 with the applicable amount equal to $250000. Entailment

:- discontiguous s68_b_1_C/3.
:- ['statutes/prolog/init'].
s68_b_1_C("Alice",2016,250000).
income_(span("income",21,26)).
agent_(span("income",21,26),span("Alice",10,14)).
amount_(span("income",21,26),span(567192,32,38)).
start_(span("income",21,26),span(2016,3,6)).
