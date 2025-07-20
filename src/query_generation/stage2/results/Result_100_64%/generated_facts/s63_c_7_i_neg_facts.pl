% Stage 2 Generated Facts
% Case: s63_c_7_i_neg
% Text: In 2019, Alice was paid $33200. Alice is a head of household for 2019.
% Question: Under section 63(c)(7)(i), Alice's basic standard deduction in 2019 is equal to $4400. Contradiction

:- discontiguous s2_b/2.
:- ['statutes/prolog/init'].
income_(span("paid",19,22)).
agent_(span("paid",19,22),span("Alice",9,13)).
amount_(span("paid",19,22),span(33200,24,29)).
start_(span("paid",19,22),span(2019,3,6)).
s2_b("Alice",2019).
