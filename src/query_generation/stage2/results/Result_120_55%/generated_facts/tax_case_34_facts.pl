% Stage 2 Generated Facts
% Case: tax_case_34
% Text: Alice's gross income for the year 2017 is $22895. Alice takes the standard deduction.
% Question: How much tax does Alice have to pay in 2017? $2684

:- discontiguous s151_b_applies/2.
:- ['statutes/prolog/init'].
s151_b_applies("Alice",2017).
income_(span("gross income",8,19)).
agent_(span("gross income",8,19),span("Alice",0,4)).
amount_(span("gross income",8,19),span(22895,43,47)).
start_(span("gross income",8,19),span(2017,33,36)).
