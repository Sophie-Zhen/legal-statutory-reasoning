% Stage 2 Generated Facts
% Case: s68_a_1_neg
% Text: In 2016, Alice's income was $267192. Alice is a head of household for the year 2016. Alice is allowed itemized deductions of $60000 under section 63.
% Question: Section 68(a)(1) prescribes a reduction of Alice's itemized deductions for the year 2016 by $306. Contradiction

:- discontiguous s63/3.
:- discontiguous income_/1.
:- ['statutes/prolog/init'].
s63("Alice",2016,207192).
income_(span("income",17,22)).
agent_(span("income",17,22),span("Alice",10,14)).
amount_(span("income",17,22),span(267192,28,34)).
start_(span("income",17,22),span(2016,3,6)).
