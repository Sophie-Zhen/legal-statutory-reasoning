% Stage 2 Generated Facts
% Case: s68_b_1_B_pos
% Text: In 2016, Alice's income was $567192. Alice is a head of household for the year 2016.
% Question: Under section 68(b)(1)(B), Alice's applicable amount for 2016 is equal to $275000. Entailment

:- discontiguous s2_b/3.
:- ['statutes/prolog/init'].
income_(span("income",22,27)).
agent_(span("income",22,27),span("Alice",9,13)).
amount_(span("income",22,27),span(567192,34,39)).
start_(span("income",22,27),span(2016,3,6)).
s2_b("Alice",_,2016).
