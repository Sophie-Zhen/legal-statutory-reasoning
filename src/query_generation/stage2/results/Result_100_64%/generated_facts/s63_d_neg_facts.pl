% Stage 2 Generated Facts
% Case: s63_d_neg
% Text: In 2017, Alice was paid $33200. She is allowed a deduction of $2000 for herself for the year 2017 under section 151(b).
% Question: Alice's deduction for 2017 falls under section 63(d). Contradiction

:- discontiguous s151_b_applies/2.
:- discontiguous s151_c/4.
:- ['statutes/prolog/init'].
payment_(span("paid",19,22)).
patient_(span("paid",19,22),span("Alice",9,13)).
amount_(span("paid",19,22),span(33200,24,29)).
start_(span("paid",19,22),span(2017,3,6)).
s151_b_applies("Alice",2017).
s151_c("Alice","Alice",2000,2017).
