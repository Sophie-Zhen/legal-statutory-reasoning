% Stage 2 Generated Facts
% Case: s68_f_pos
% Text: In 2018, Alice's income was $310192. Alice is a surviving spouse for the year 2018. Alice is allowed itemized deductions of $600 under section 63.
% Question: Section 68(f) applies to Alice for the year 2018. Entailment

:- discontiguous s2_a/3.
:- ['statutes/prolog/init'].
income_(span("income",16,21)).
agent_(span("income",16,21),span("Alice",9,13)).
amount_(span("income",16,21),span(310192,27,34)).
start_(span("income",16,21),span(2018,3,6)).
s2_a("Alice",_,2018).
payment_(span("itemized deductions",108,126)).
agent_(span("itemized deductions",108,126),span("Alice",91,95)).
amount_(span("itemized deductions",108,126),span(600,131,134)).
start_(span("itemized deductions",108,126),span(2018,82,85)).
