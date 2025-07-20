% Stage 2 Generated Facts
% Case: s68_b_1_B_neg
% Text: In 2016, Alice's income was $567192. Alice is a surviving spouse for the year 2016.
% Question: Under section 68(b)(1)(B), Alice's applicable amount for 2016 is equal to $275000. Contradiction

:- discontiguous s2_a/3.
:- ['statutes/prolog/init'].
income_(span("income",20,25)).
agent_(span("income",20,25),span("Alice",10,14)).
amount_(span("income",20,25),span(567192,31,36)).
start_(span("income",20,25),span(2016,3,6)).
s2_a("Alice",_,2016).
