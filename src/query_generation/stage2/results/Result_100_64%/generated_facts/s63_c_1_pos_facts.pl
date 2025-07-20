% Stage 2 Generated Facts
% Case: s63_c_1_pos
% Text: In 2017, Alice was paid $33200. For the year 2017, Alice is allowed a basic standard deduction under section 63(c)(2) of $2000 and an additional standard deduction of $3000 under section 63(c)(3) for the year 2017.
% Question: Under section 63(c)(1), Alice's standard deduction in 2017 is equal to $5000. Entailment

:- discontiguous s63_c_2/3.
:- discontiguous s63_c_3/3.
:- ['statutes/prolog/init'].
payment_(span("paid",21,24)).
agent_(span("paid",21,24),span("Alice",10,14)).
amount_(span("paid",21,24),span(33200,26,32)).
start_(span("paid",21,24),span(2017,3,6)).
s63_c_2("Alice",2000,2017).
s63_c_3("Alice",3000,2017).
