% Stage 2 Generated Facts
% Case: s68_b_1_C_neg
% Text: In 2016, Alice's income was $567192. Alice is a head of household for the year 2016.
% Question: Section 68(b)(1)(C) applies to Alice in 2016. Contradiction

:- discontiguous income_/1.
:- discontiguous agent_/2.
:- discontiguous amount_/2.
:- discontiguous start_/2.
:- discontiguous s2_b/3.
:- ['statutes/prolog/init'].
income_(span("income",17,22)).
agent_(span("income",17,22),span("Alice",9,13)).
amount_(span("income",17,22),span(567192,28,33)).
start_(span("income",17,22),span(2016,3,6)).
s2_b("Alice",_,2016).
