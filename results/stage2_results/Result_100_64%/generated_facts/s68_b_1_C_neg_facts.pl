% Stage 2 Generated Facts
% Case: s68_b_1_C_neg
% Text: In 2016, Alice's income was $567192. Alice is a head of household for the year 2016.
% Question: Section 68(b)(1)(C) applies to Alice in 2016. Contradiction

:- discontiguous head_of_household_/1.
:- ['statutes/prolog/init'].
income_(span("income",17,22)).
agent_(span("income",17,22),span("Alice",9,13)).
amount_(span("income",17,22),span(567192,29,34)).
start_(span("income",17,22),span(2016,3,6)).
head_of_household_(span("head of household",48,64)).
agent_(span("head of household",48,64),span("Alice",37,41)).
start_(span("head of household",48,64),span(2016,79,82)).
