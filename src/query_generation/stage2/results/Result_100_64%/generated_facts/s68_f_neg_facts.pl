% Stage 2 Generated Facts
% Case: s68_f_neg
% Text: In 2014, Alice's income was $310192. Alice is a surviving spouse for the year 2014. Alice is allowed itemized deductions of $600 under section 63.
% Question: Section 68(f) applies to Alice for the year 2014. Contradiction

:- discontiguous s2_a/3.
:- ['statutes/prolog/init'].
income_(span("income",16,21)).
agent_(span("income",16,21),span("Alice",9,13)).
amount_(span("income",16,21),span(310192,26,32)).
start_(span("income",16,21),span(2014,3,6)).
s2_a("Alice",_,2014).
payment_(span("itemized deductions",99,117)).
agent_(span("itemized deductions",99,117),span("Alice",81,85)).
amount_(span("itemized deductions",99,117),span(600,122,125)).
start_(span("itemized deductions",99,117),span(2014,3,6)).
