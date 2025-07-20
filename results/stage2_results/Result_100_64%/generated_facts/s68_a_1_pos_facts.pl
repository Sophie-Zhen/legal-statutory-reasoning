% Stage 2 Generated Facts
% Case: s68_a_1_pos
% Text: In 2016, Alice's income was $310192. Alice is a surviving spouse for the year 2016. Alice is allowed itemized deductions of $60000 under section 63.
% Question: Section 68(a)(1) prescribes a reduction of Alice's itemized deductions for the year 2016 by $306. Entailment

:- discontiguous s2_a/3.
:- ['statutes/prolog/init'].
s2_a("Alice",_,2016).
income_(span("income",17,22)).
agent_(span("income",17,22),span("Alice",9,13)).
amount_(span("income",17,22),span(310192,28,35)).
start_(span("income",17,22),span(2016,3,6)).
payment_(span("itemized deductions",104,122)).
agent_(span("itemized deductions",104,122),span("Alice",85,89)).
amount_(span("itemized deductions",104,122),span(60000,127,133)).
beneficiary_(span("itemized deductions",104,122),span("Alice",85,89)).
start_(span("itemized deductions",104,122),span(2016,3,6)).
