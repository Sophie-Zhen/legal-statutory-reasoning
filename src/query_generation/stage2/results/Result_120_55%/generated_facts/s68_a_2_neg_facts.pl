% Stage 2 Generated Facts
% Case: s68_a_2_neg
% Text: In 2016, Alice's income was $295192. Alice is a surviving spouse for the year 2016. Alice is allowed itemized deductions of $60000 under section 63.
% Question: Section 68(a)(2) prescribes a reduction of Alice's itemized deductions for the year 2016 by $47000. Contradiction

:- discontiguous s2_a/3.
:- ['statutes/prolog/init'].
income_(span("income",16,21)).
agent_(span("income",16,21),span("Alice's",8,14)).
amount_(span("income",16,21),span(295192,26,32)).
start_(span("income",16,21),span(2016,3,6)).
s2_a("Alice",_,2016).
payment_(span("itemized deductions",110,127)).
agent_(span("itemized deductions",110,127),span("Alice",93,97)).
amount_(span("itemized deductions",110,127),span(60000,132,137)).
start_(span("itemized deductions",110,127),span(2016,3,6)).
