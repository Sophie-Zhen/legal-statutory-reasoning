% Stage 2 Generated Facts
% Case: s152_d_1_D_neg
% Text: In 2015, Alice's income was $312. The exemption amount for Alice under section 151(d) for the year 2015 was $2000. Alice is Bob's mother, and Bob is a dependent of Alice under 152(c) for the year 2015.
% Question: Section 152(d)(1)(D) applies to Bob for the year 2015. Contradiction

:- discontiguous s151_c/4.
:- discontiguous s152_a/3.
:- ['statutes/prolog/init'].
s151_c("Alice","Bob",2000,2015).
s152_a("Bob","Alice",2015).
income_(span("income",17,22)).
agent_(span("income",17,22),span("Alice",9,13)).
amount_(span("income",17,22),span(312,29,31)).
start_(span("income",17,22),span(2015,3,6)).
mother_(span("mother",133,138)).
agent_(span("mother",133,138),span("Alice",117,121)).
patient_(span("mother",133,138),span("Bob",126,128)).
