% Stage 2 Generated Facts
% Case: s63_c_2_A_ii_pos
% Text: In 2017, Alice was paid $33200. Alice is a surviving spouse for 2017.
% Question: Section 63(c)(2)(A)(ii) applies to Alice in 2017. Entailment

:- discontiguous income_/1.
:- discontiguous s2_a/3.
:- ['statutes/prolog/init'].
income_(span("paid",19,22)).
agent_(span("paid",19,22),span("Alice",10,14)).
amount_(span("paid",19,22),span(33200,24,29)).
start_(span("paid",19,22),span(2017,3,6)).
s2_a("Alice",_,2017).
